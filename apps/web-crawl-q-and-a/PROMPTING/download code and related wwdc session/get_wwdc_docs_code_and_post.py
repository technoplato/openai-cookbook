import os
from bs4 import BeautifulSoup
import requests
from selenium.webdriver.chrome.options import Options
from selenium import webdriver
from datetime import datetime
import urllib.parse
import sqlite3


class WWDCDatabase:
    def __init__(self, db_path="wwdc_data.db"):
        self.conn = sqlite3.connect(db_path)
        self.initialize_database()

    def initialize_database(self):
        with self.conn:
            self.conn.execute("""
                CREATE TABLE IF NOT EXISTS urls (
                    id INTEGER PRIMARY KEY,
                    wwdc_year TEXT,
                    topic TEXT,
                    slug TEXT,
                    title TEXT,
                    overview TEXT,
                    platforms TEXT,
                    platform_versions TEXT,
                    url_type TEXT,
                    url TEXT,
                    page_downloaded BOOLEAN DEFAULT 0,
                    wwdc_links_scraped BOOLEAN DEFAULT 0,
                    transcript_downloaded BOOLEAN DEFAULT 0,
                    overview_downloaded BOOLEAN DEFAULT 0,
                    code_downloaded BOOLEAN DEFAULT 0,
                    updated_at TIMESTAMP
                )
            """)

    def save_url(self, wwdc_year, topic, slug, title, overview, platforms, platform_versions, url_type, url):
        with self.conn:
            self.conn.execute("""
                INSERT INTO urls (wwdc_year, topic, slug, title, overview, platforms, platform_versions, url_type, url, updated_at) 
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
            """, (wwdc_year, topic, slug, title, overview, ','.join(platforms), ','.join(platform_versions), url_type, url, datetime.now()))

    def mark_page_downloaded(self, url_id):
        self._update_status_flag(url_id, "page_downloaded")

    def mark_wwdc_links_scraped(self, url_id):
        self._update_status_flag(url_id, "wwdc_links_scraped")

    def mark_transcript_downloaded(self, url_id):
        self._update_status_flag(url_id, "transcript_downloaded")

    def mark_overview_downloaded(self, url_id):
        self._update_status_flag(url_id, "overview_downloaded")

    def mark_code_downloaded(self, url_id):
        self._update_status_flag(url_id, "code_downloaded")

    def _update_status_flag(self, url_id, flag_column):
        with self.conn:
            self.conn.execute(f"""
                UPDATE urls SET {flag_column} = 1, updated_at = ? WHERE id = ?
            """, (datetime.now(), url_id))

    def is_page_downloaded(self, url_id):
        with self.conn:
            cursor = self.conn.execute("""
                SELECT page_downloaded FROM urls WHERE id = ?
            """, (url_id,))
            result = cursor.fetchone()
            return result and result[0]

    def get_undownloaded_urls(self):
        with self.conn:
            cursor = self.conn.execute("""
                SELECT id, wwdc_year, title, url
                FROM urls
                WHERE page_downloaded = 0
            """)
            return cursor.fetchall()


# ####################################################################################################
# Setup WebDriver and Chrome Options
# ####################################################################################################
chrome_binary_path = "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
chromedriver_path = "/Users/laptop/Downloads/chromedriver-mac-arm64/chromedriver"
chrome_options = Options()
chrome_options.binary_location = chrome_binary_path
driver = webdriver.Chrome(
    executable_path=chromedriver_path, options=chrome_options)
# ####################################################################################################
# Setup WebDriver and Chrome Options - END
# ####################################################################################################


def comment(message):
    fence = '#' * 80
    # print(fence)
    print(message)
    # print(fence)


def get_current_year_url():
    current_year = datetime.now().year
    return f"https://developer.apple.com/sample-code/wwdc/{current_year}/"


def get_wwdc_urls(driver, starting_url):
    driver.get(starting_url)
    driver.implicitly_wait(10)
    html_content = driver.page_source
    soup = BeautifulSoup(html_content, "html.parser")
    wwdc_links = soup.select(
        ".localnav-menu-items a[href*='/sample-code/wwdc/']")
    return [(link.text.strip(), f"https://developer.apple.com{link.get('href')}") for link in wwdc_links]


def get_view_code_urls(driver, wwdc_year, wwdc_url, db):
    comment(f"Fetching 'View Code' URLs for {wwdc_year}")

    # Navigate to the WWDC year URL
    driver.get(wwdc_url)
    driver.implicitly_wait(10)

    # Get the entire HTML content
    html_content = driver.page_source

    # Parse the HTML content using BeautifulSoup
    soup = BeautifulSoup(html_content, "html.parser")

    # Find all the "View Code" links
    view_code_divs = soup.find_all("div", class_="sample-description")

    # Extract and save the URLs along with title, description, and platforms
    view_code_urls = []
    for div in view_code_divs:
        link = div.find("a", text="View code")
        url = link.get("href") if link else ""
        parsed_url = urllib.parse.urlparse(url)
        topic, slug = parsed_url.path.strip('/').split('/')[-2:]

        title = div.find("h4", class_="cs-title")
        title_text = title.text.strip() if title else ""

        overview = div.find("p", class_="cs-overview")
        overview_text = overview.text.strip() if overview else ""

        platforms_div = div.find("p", class_="platform-container")
        platforms = [span.text.strip() for span in platforms_div.find_all(
            "span")] if platforms_div else ""

        availability_div = soup.find(
            "div", class_="summary-section", role="complementary", aria_label="Availability")
        platform_versions = [span.text.strip() for span in availability_div.find_all(
            "span", class_="badge platform")] if availability_div else ""

        if url:
            view_code_urls.append(url)
            db.save_url(wwdc_year, topic, slug, title_text, overview_text,
                        platforms, platform_versions, "View code", url)
            comment(f"Saved URL: {url}")

    return view_code_urls


def download_sample_code(driver, url, title, db, url_id):

    driver.get(url)
    driver.implicitly_wait(10)
    html_content = driver.page_source
    soup = BeautifulSoup(html_content, "html.parser")

    # Find the download button using the class
    download_button = soup.find('a', class_='button-cta sample-download')

    if download_button:
        download_url = download_button.get('href')

        # Create a folder named after the title
        folder_name = title.replace(":", "-")  # Replace colons with hyphens
        os.makedirs(folder_name, exist_ok=True)

        # Download the file
        download_file(download_url, folder_name)

        # Mark the page as downloaded in the database
        db.mark_page_downloaded(url_id)

        print(f"Downloaded contents for: {title}")


def download_file(url, folder_name):
    # Download the file from the URL and save it to the folder
    response = requests.get(url)
    file_name = os.path.join(folder_name, url.split("/")[-1])
    with open(file_name, 'wb') as file:
        file.write(response.content)


def process_view_code_urls(driver, db):
    # Fetch the URLs from the database that have not been downloaded yet
    urls_to_process = db.get_undownloaded_urls()

    for url_id, wwdc_year, title, url in urls_to_process[:1]:
        print("doing the first thing")
        download_sample_code(driver, url, title, db, url_id)


def main():
    db = WWDCDatabase()
    starting_url = get_current_year_url()
    comment(f"Starting URL: {starting_url}")
    wwdc_urls = get_wwdc_urls(driver, starting_url)
    for wwdc_year, wwdc_url in wwdc_urls:
        comment(f"Processing WWDC year: {wwdc_year}")
        view_code_urls = get_view_code_urls(driver, wwdc_year, wwdc_url, db)
        # for url in view_code_urls:
        #     comment(f"Processing URL: {url}")
        if view_code_urls:
            first_url = view_code_urls[0]
            comment(f"Processing First URL: {first_url}")
            # Add code to process the first URL here
            break  # Stops further processing after the first URL is found

    # Process the "View Code" URLs
    process_view_code_urls(driver, db)


if __name__ == "__main__":
    main()
    driver.quit()

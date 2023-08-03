from bs4 import BeautifulSoup
from selenium.webdriver.chrome.options import Options
from selenium import webdriver
from datetime import datetime

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

    def save_url(self, wwdc_year, url_type, url):
        with self.conn:
            self.conn.execute("""
                INSERT INTO urls (wwdc_year, url_type, url, updated_at) VALUES (?, ?, ?, ?)
            """, (wwdc_year, url_type, url, datetime.now()))

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
    print(fence)
    print(f"##### {message}")
    print(fence)


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
    url_id = db.save_url(wwdc_year, "View code", wwdc_url)
    if not db.is_page_downloaded(url_id):
        comment("Downloading the page")
        # Code to download the page
        db.mark_page_downloaded(url_id)
    comment("Code to process the page if needed")
    # Code to process the page if needed
    # ...


def main():
    db = WWDCDatabase()
    starting_url = get_current_year_url()
    comment(f"Starting URL: {starting_url}")
    wwdc_urls = get_wwdc_urls(driver, starting_url)
    for wwdc_year, wwdc_url in wwdc_urls:
        comment(f"Processing WWDC year: {wwdc_year}")
        view_code_urls = get_view_code_urls(driver, wwdc_year, wwdc_url, db)
        for url in view_code_urls:
            comment(f"Processing URL: {url}")
            # get_view_code_urls(driver, url, db)


if __name__ == "__main__":
    main()
    driver.quit()

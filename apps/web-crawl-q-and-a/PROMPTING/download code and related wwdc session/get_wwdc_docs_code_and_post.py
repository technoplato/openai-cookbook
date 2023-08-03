from bs4 import BeautifulSoup
from selenium.webdriver.chrome.options import Options
from selenium import webdriver
from datetime import datetime

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
# Get the Current Year and Construct the Starting URL
# ####################################################################################################
current_year = datetime.now().year
starting_url = f"https://developer.apple.com/sample-code/wwdc/{current_year}/"
print(f"Starting URL: {starting_url}")

# ####################################################################################################
# Function to Get "View Code" URLs
# ####################################################################################################


def get_view_code_urls(soup):
    view_code_urls = []
    view_code_links = soup.find_all("a", string="View code")
    for link in view_code_links:
        url = link.get("href")
        if url:
            view_code_urls.append(url)
    return view_code_urls


# ####################################################################################################
# Navigate to the Starting URL and Extract WWDC Full URLs
# ####################################################################################################
driver.get(starting_url)
driver.implicitly_wait(10)
html_content = driver.page_source
soup = BeautifulSoup(html_content, "html.parser")
wwdc_links = soup.select(".localnav-menu-items a[href*='/sample-code/wwdc/']")
for link in wwdc_links:
    wwdc_text = link.text.strip()
    if wwdc_text in ["WWDC23", "WWDC22", "WWDC21", "WWDC20"]:
        wwdc_href = link.get("href")
        full_url = f"https://developer.apple.com{wwdc_href}"
        print(f"Processing {wwdc_text}: {full_url}")

        # Navigate to the WWDC year's URL
        driver.get(full_url)
        driver.implicitly_wait(10)
        year_html_content = driver.page_source
        year_soup = BeautifulSoup(year_html_content, "html.parser")

        # Get and print the "View Code" URLs
        view_code_urls = get_view_code_urls(year_soup)
        print(f"Found {len(view_code_urls)} 'View Code' URLs for {wwdc_text}")
        for url in view_code_urls:
            print(url)

# ####################################################################################################
# Close WebDriver
# ####################################################################################################
driver.quit()

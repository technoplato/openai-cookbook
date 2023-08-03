from datetime import datetime
from bs4 import BeautifulSoup
from selenium.webdriver.chrome.options import Options
from selenium import webdriver

# ####################################################################################################
# Setup WebDriver and Chrome Options
# ####################################################################################################
# Path to your Chrome binary
chrome_binary_path = "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"

# Path to your ChromeDriver
chromedriver_path = "/Users/laptop/Downloads/chromedriver-mac-arm64/chromedriver"

# Set Chrome options
chrome_options = Options()
chrome_options.binary_location = chrome_binary_path

# Initialize the WebDriver
driver = webdriver.Chrome(
    executable_path=chromedriver_path, options=chrome_options)

# ####################################################################################################
# Navigate to Sample Code Page and Extract "View Code" URLs
# ####################################################################################################
# Navigate to the sample code page
base_url = "https://developer.apple.com/sample-code/wwdc/2023/"
driver.get(base_url)

# Wait for the page to load
driver.implicitly_wait(10)

# Get the entire HTML content
html_content = driver.page_source

# Parse the HTML content using BeautifulSoup
soup = BeautifulSoup(html_content, "html.parser")

# ####################################################################################################
# Function to Get "View Code" URLs
# ####################################################################################################


# def get_view_code_urls(soup):
#     view_code_urls = []
#     view_code_links = soup.find_all("a", string="View code")
#     for link in view_code_links:
#         url = link.get("href")
#         if url:
#             view_code_urls.append(url)
#     return view_code_urls


# # Get the "View Code" URLs
# view_code_urls = get_view_code_urls(soup)

# # ####################################################################################################
# # Visit First "View Code" URL and Extract Title, Description, Platforms, and WWDC Sessions
# # ####################################################################################################

# # Visit the first "View code" URL
# first_view_code_url = view_code_urls[0]
# driver.get(first_view_code_url)

# # Extract the title, description, and platforms
# title = driver.find_element_by_css_selector(".cs-title").text
# description = driver.find_element_by_css_selector(".cs-overview").text
# platforms = [span.text for span in driver.find_elements_by_css_selector(
#     ".platform-container span")]

# # Find and print the linked WWDC sessions
# wwdc_session_links = driver.find_elements_by_partial_link_text("WWDC")
# wwdc_session_urls = [link.get_attribute("href") for link in wwdc_session_links]

# # Print the extracted information
# print("Title:", title)
# print("Description:", description)
# print("Platforms:", platforms)
# print("WWDC Sessions:", wwdc_session_urls)

# # ####################################################################################################
# # Close WebDriver
# # ####################################################################################################
# # Close the WebDriver
# driver.quit()

# ####################################################################################################
# Function to Get "View Code" URLs
# ####################################################################################################
# def get_view_code_urls(soup):
#     view_code_urls = []
#     view_code_links = soup.find_all("a", string="View code")
#     for link in view_code_links:
#         url = link.get("href")
#         if url:
#             view_code_urls.append(url)
#     return view_code_urls


# # ####################################################################################################
# # Navigate to Sample Code Page and Extract Available Years
# # ####################################################################################################
# base_url = "https://developer.apple.com/sample-code/wwdc/2023"
# driver.get(base_url)
# driver.implicitly_wait(10)
# html_content = driver.page_source
# soup = BeautifulSoup(html_content, "html.parser")
# years_links = soup.select(".localnav-menu-items .localnav-menu-link")
# years_urls = [link.get("href") for link in years_links]

# # ####################################################################################################
# # Iterate Through Available Years and Navigate to Sample Code Page for Each Year
# # ####################################################################################################
# for year_url in years_urls:
#     print(f"Processing {year_url}")
#     driver.get(base_url + year_url)
#     driver.implicitly_wait(10)
#     html_content = driver.page_source
#     soup = BeautifulSoup(html_content, "html.parser")
#     view_code_urls = get_view_code_urls(soup)
#     print(f"Found {len(view_code_urls)} 'View Code' URLs for {year_url}")

#     # You can add more code here to visit each "View code" URL and extract information for the year

# # ####################################################################################################
# # Close WebDriver
# # ####################################################################################################
# driver.quit()


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
# Navigate to the Starting URL and Extract WWDC Hrefs
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
        print(f"{wwdc_text}: {wwdc_href}")

# ####################################################################################################
# Close WebDriver
# ####################################################################################################
driver.quit()

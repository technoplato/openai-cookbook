from collections import deque
from selenium import webdriver
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.common.action_chains import ActionChains
import selenium
import time
from urllib.parse import urlparse
import os


# Path to your Chrome binary
chrome_binary_path = "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"

# Path to your ChromeDriver
chromedriver_path = "/Users/laptop/Downloads/chromedriver-mac-arm64/chromedriver"

# Set Chrome options
chrome_options = Options()
chrome_options.add_argument("--headless")
chrome_options.binary_location = chrome_binary_path

# Initialize the WebDriver
driver = None
try:
    driver = webdriver.Chrome(
        executable_path=chromedriver_path, options=chrome_options)
    print("Successfully created a WebDriver instance.")
except Exception as e:
    print("ERROR: Couldn't create a WebDriver instance.")
    print("Detailed error: ", e)
    exit(1)

# Navigate to the specified page
base_url = "https://developer.apple.com/documentation"
driver.get(base_url)

# Wait for the page to load
driver.implicitly_wait(10)  # wait up to 10 seconds


def create_directory_path(url, subdirectory):
    parsed_url = urlparse(url)
    domain_name = parsed_url.netloc.replace('.', '_')
    path = parsed_url.path.strip('/').replace('/', '_')

    # Create the directory path including domain name, subdirectory, and path
    directory_path = os.path.join('.', subdirectory, domain_name, path)

    # Create the directory if it doesn't exist
    if not os.path.exists(directory_path):
        os.makedirs(directory_path)

    return directory_path


def save_text_to_file(url, driver):
    directory_path = create_directory_path(url, 'text')

    # Define the file path to save the text
    file_path = os.path.join(directory_path, 'page.txt')

    # Check if the file already exists (content already downloaded)
    if os.path.exists(file_path):
        print(f"Already downloaded: {url}. Skipping...")
        return

    # Load the page with the driver
    print(f"Loading {url}")
    driver.get(url)
    driver.implicitly_wait(10)
    time.sleep(.4)

    # Extract the text content from the page
    text_content = driver.find_element_by_tag_name('body').text

    # Write the text content to the file
    with open(file_path, 'w', encoding='utf-8') as file:
        file.write(text_content)
        file.write("\n\n")  # Separate content of different pages


def main():
    print("Starting to download all pages...")

    # Read URLs from the file
    with open('urls.txt', 'r', encoding='utf-8') as file:
        urls = file.readlines()

    # Iterate over the URLs and download them
    for url in urls:
        url = url.strip()  # Remove any leading/trailing whitespace
        save_text_to_file(url, driver)

    print("Downloading completed.")


if __name__ == "__main__":
    main()

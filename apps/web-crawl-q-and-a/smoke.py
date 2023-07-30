from collections import deque
from selenium import webdriver
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.common.keys import Keys
from urllib.parse import urldefrag
from selenium.webdriver.common.by import By  # new import here
from selenium.webdriver.common.action_chains import ActionChains
from urllib.parse import urljoin

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
base_url = "https://developer.apple.com/documentation/visionos"
driver.get(base_url)

# Wait for the page to load
driver.implicitly_wait(10)  # wait up to 10 seconds


def save_html_to_file(url, driver):
    # Parse the domain name and path from the URL
    parsed_url = urlparse(url)
    domain_name = parsed_url.netloc.replace('.', '_')
    path = parsed_url.path.strip('/').replace('/', '_')

    # Create the directory path including domain name and path
    directory_path = os.path.join('./html', domain_name, path)

    # Create the directory if it doesn't exist
    if not os.path.exists(directory_path):
        os.makedirs(directory_path)

    # Define the file path to save the HTML
    file_path = os.path.join(directory_path, 'page.html')

    # Get the entire HTML content
    html_content = driver.page_source

    # Write the HTML content to the file
    with open(file_path, 'w', encoding='utf-8') as file:
        file.write(html_content)


def save_text_to_file(url, text):
    # Parse the domain name and path from the URL
    parsed_url = urlparse(url)
    domain_name = parsed_url.netloc.replace('.', '_')
    path = parsed_url.path.strip('/').replace('/', '_')

    # Create the directory path including domain name and path
    directory_path = os.path.join('./text', domain_name, path)

    # Create the directory if it doesn't exist
    if not os.path.exists(directory_path):
        os.makedirs(directory_path)

    # Define the file path to save the text
    file_path = os.path.join(directory_path, 'page_text.txt')

    # Write the text content to the file
    with open(file_path, 'a') as file:
        file.write(text)
        file.write("\n\n")  # Separate content of different pages


def collect_links(driver, url):
    print(f"Crawling {url}")
    driver.get(url)
    # Wait for the page to fully load
    driver.implicitly_wait(10)
    links_elements = driver.find_elements(By.TAG_NAME, "a")
    print(f"Found {len(links_elements)} anchor tags.")
    links = [urldefrag(urljoin(url, link.get_attribute("href")))[
        0] for link in links_elements if "developer.apple.com/documentation" in link.get_attribute("href")]
    print(
        f"Collected {len(links)} links containing 'developer.apple.com/documentation'.")
    return links


def main():
    visited = set()
    url = 'https://developer.apple.com/documentation'
    urls = deque([url])

    while urls:
        print(len(urls))
        url = urls.popleft()
        if url not in visited:
            print(f"Visiting {url}")  # Debug statement

            visited.add(url)
            links = collect_links(driver, url)
            # Debug statement
            print(f"Adding {len(links)} links to the queue.")

            urls.extend(link for link in links if link not in visited)

            # Save the entire HTML content to a file
            save_html_to_file(url, driver)

            print("Content of the page:")
            # Print the text content of the page
            text_content = driver.find_element(By.TAG_NAME, "body").text
            # print(text_content)

            # Save the text content to a file
            save_text_to_file(url, text_content)

            print("Images on the page:")
            images = driver.find_elements(By.TAG_NAME, "img")
            for img in images:
                # Print the source URL of each image
                print(img.get_attribute("src"))


if __name__ == "__main__":
    main()

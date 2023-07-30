from collections import deque
from selenium import webdriver
from selenium.webdriver.chrome.options import Options
from urllib.parse import urldefrag, urljoin
from selenium.webdriver.common.by import By  # new import here
from urllib.parse import urlparse
from multiprocessing import Pool, Manager

import os


# Path to your Chrome binary
chrome_binary_path = "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"

# Path to your ChromeDriver
chromedriver_path = "/Users/laptop/Downloads/chromedriver-mac-arm64/chromedriver"

# Set Chrome options
chrome_options = Options()
chrome_options.add_argument("--headless")
chrome_options.binary_location = chrome_binary_path


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


def process_url(url, visited, urls, driver):
    if url not in visited:
        visited[url] = True
        links = collect_links(driver, url)
        for link in links:
            if link not in visited:
                urls.append(link)  # Add the link to the global URL queue

        print("Content of the page:")
        text_content = driver.find_element(By.TAG_NAME, "body").text
        save_text_to_file(url, text_content)

        print("Images on the page:")
        images = driver.find_elements(By.TAG_NAME, "img")
        for img in images:
            print(img.get_attribute("src"))


def worker(args):
    url, visited, urls = args
    driver = webdriver.Chrome(
        executable_path=chromedriver_path, options=chrome_options)
    process_url(url, visited, urls, driver)
    driver.quit()


def process_urls(visited, urls):
    with Pool(5) as pool:
        pool.map(worker, [(url, visited, urls) for url in urls])


def main():
    manager = Manager()
    visited = manager.dict()  # Change to a dict
    urls = manager.list()
    urls.append('https://developer.apple.com/documentation')
    process_urls(visited, urls)


if __name__ == "__main__":
    main()

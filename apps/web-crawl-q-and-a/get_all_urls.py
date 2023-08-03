from collections import deque
from selenium import webdriver
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.common.keys import Keys
from urllib.parse import urldefrag
from selenium.webdriver.common.by import By  # new import here
from selenium.webdriver.common.action_chains import ActionChains
from urllib.parse import urljoin
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


def save_urls_to_file(urls):
    """
    Save the given URLs to a text file at the root.

    :param urls: List of URLs to save.
    """
    file_path = 'urls.txt'

    # Write the URLs to the file
    with open(file_path, 'w', encoding='utf-8') as file:
        file.write('\n'.join(urls))


def collect_links(driver, url):
    print(f"Crawling {url}")
    driver.get(url)
    # Wait for the page to fully load
    driver.implicitly_wait(10)

    time.sleep(.4)

    """
    TODO
    https://developer.apple.com/airplay/
    https://developer.apple.com/shareplay/
    https://developer.apple.com/documentation/GroupActivities/
    https://developer.apple.com/documentation/soundanalysis/
    https://developer.apple.com/documentation/multipeerconnectivity
    https://developer.apple.com/documentation/xcode
    https://developer.apple.com/documentation/xcode/configuring-app-groups
    
    """

    # Execute JavaScript to retrieve all href attributes of anchor tags containing specified substrings
    js_script = """
    var specificUrls = [
        "https://developer.apple.com/documentation/swiftdata",
        "https://developer.apple.com/documentation/coreml",
        "https://developer.apple.com/documentation/speech",
        "https://developer.apple.com/documentation/vision", 
        "https://developer.apple.com/documentation/createml",
        // "https://developer.apple.com/documentation/arkit",
        // "https://developer.apple.com/documentation/combine"
        // "https://developer.apple.com/documentation/swift",
        // "https://developer.apple.com/documentation/swiftui", // ✅
        // "https://developer.apple.com/documentation/visionos", // ✅.
        // "https://developer.apple.com/documentation/realitykit" // ✅.
    ];
    var links = document.querySelectorAll('a');
    console.log(document)
    var hrefs = [];
    for (var link of links) {
        var href = link.href;
        if (href) {
            href = href.toLowerCase();
            for (var specificUrl of specificUrls) {
                if (href.includes(specificUrl)) {
                    hrefs.push(href);
                }
            }
        }
    }
    return hrefs;
    """
    hrefs = driver.execute_script(js_script)

    links = [urldefrag(urljoin(url, href))[0] for href in hrefs]
    # print(f"Collected {len(links)} specific links:")
    for link in links:
        print(link)

    return links


def main():
    visited = set()
    starting_urls = [
        "https://developer.apple.com/documentation/swiftdata",
        "https://developer.apple.com/documentation/coreml",
        "https://developer.apple.com/documentation/speech/",
        "https://developer.apple.com/documentation/vision",
        "https://developer.apple.com/documentation/createml",
        # "https://developer.apple.com/documentation/swiftui",
        # "https://developer.apple.com/documentation/arkit",
        # "https://developer.apple.com/documentation/combine",
        # "https://developer.apple.com/documentation/swift"
        # "https://developer.apple.com/documentation/visionos",
        # "https://developer.apple.com/documentation/realitykit",
    ]
    urls = starting_urls  # Using a list as a stack

    while urls:
        print(len(urls))
        url = urls.pop()  # Popping from the end for LIFO behavior
        if url not in visited:
            print(f"Visiting {url}")  # Debug statement
            try:
                visited.add(url)
                links = collect_links(driver, url)
                # Debug statement
                print(f"Adding {len(links)} links to the stack.")
                # Extend the stack with links not already visited
                urls.extend(link for link in links if link not in visited)
            except selenium.common.exceptions.WebDriverException as e:
                print(f"An error occurred while processing {url}: {e}")
                continue

            # This is going to slowER than it could be
            text_content = driver.find_element(By.TAG_NAME, "body").text

    print("Crawling completed.")
    print("Saving URL hrefs to file...")

    save_urls_to_file(visited)


if __name__ == "__main__":
    main()

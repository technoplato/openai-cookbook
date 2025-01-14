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
   TODO: Sample code 
   https://developer.apple.com/sample-code/wwdc/2023/
   https://developer.apple.com/sample-code/wwdc/2022/
   https://developer.apple.com/sample-code/wwdc/2021/
   https://developer.apple.com/sample-code/wwdc/2020/

   All of the linked pages should be similar to:

   <Download Button>

   Overview

   Note: 
   This sample code project is associated with WWDC\d\d sesssion: <HREF>

    ---

    We want to visit that WWDC Session via href attribute

    https://developer.apple.com/videos/play/wwdc2020/10052/

    That page should have around three "tabs"

    ---

    Overview | Transcript | Code

    ---

    The code part is the most interesting

    https://developer.apple.com/videos/play/wwdc2020/10052/?time=274

    Fortunately, Apple's website currently allows a ?time=\d parameter to deeplink to a video.
    
    The transcript is also a series of links that include the timestamp at which that text was spoken. 

    We can cross reference that transcript in order to grab some surrounding context for the code snippets from the "Code" tab. 

    For videos that don't list a "Code" tab explicitly, we can OCR 2hz frames from the video and run some kind of simple analysis to 
    determine if code is being shown on screen, check the surrounding transcript, and embed that code (fullest example we can gather)
    with the surrounding spoken explanations. 

    

    """

    """
    TODO: more interesting docs we want
    https://developer.apple.com/documentation/replaykit
    https://developer.apple.com/documentation/visionkit
    https://developer.apple.com/documentation/screencapturekit
    https://developer.apple.com/documentation/sharedwithyou
    https://developer.apple.com/documentation/usernotifications
    https://developer.apple.com/documentation/RoomPlan
    https://developer.apple.com/documentation/authenticationservices
    https://developer.apple.com/documentation/ActivityKit
    https://developer.apple.com/documentation/app_clips
    https://developer.apple.com/documentation/GroupActivities/
    https://developer.apple.com/documentation/soundanalysis/
    https://developer.apple.com/documentation/multipeerconnectivity
    https://developer.apple.com/documentation/widgetkit/ 
    https://developer.apple.com/documentation/xcode/configuring-app-groups
    https://developer.apple.com/documentation/usernotificationsui/
    https://developer.apple.com/documentation/nearbyinteraction/
    https://developer.apple.com/documentation/watchconnectivity
    https://developer.apple.com/documentation/watchos-apps
    https://developer.apple.com/documentation/AppIntents
    https://developer.apple.com/documentation/docc
    https://developer.apple.com/documentation/naturallanguage
    https://developer.apple.com/documentation/MusicKit
    https://developer.apple.com/documentation/Observation
    https://developer.apple.com/documentation/PackageDescription
    https://developer.apple.com/documentation/passkit
    https://developer.apple.com/documentation/phase
    https://developer.apple.com/documentation/preferencepanes
    https://developer.apple.com/documentation/pushtotalk
    https://developer.apple.com/documentation/pushkit
    https://developer.apple.com/documentation/sensorkit
    https://developer.apple.com/documentation/sirikit
    https://developer.apple.com/documentation/sign_in_with_apple
    https://developer.apple.com/documentation/shazamkit
    https://developer.apple.com/documentation/TipKit
    https://developer.apple.com/documentation/workoutkit
    https://developer.apple.com/documentation/xctest

https://developer.apple.com/documentation/swift-playgrounds
    https://developer.apple.com/documentation/playgroundsupport
    https://developer.apple.com/documentation/playgroundbluetooth
    https://developer.apple.com/documentation/RegexBuilder
    https://developer.apple.com/documentation/walletpasses
    https://developer.apple.com/documentation/watchkit

https://developer.apple.com/documentation/visionos-release-notes
https://developer.apple.com/documentation/Xcode-Release-Notes
https://developer.apple.com/documentation/Xcode/Xcode-Cloud
https://developer.apple.com/documentation/watchos-release-notes
    https://developer.apple.com/documentation/photokit
    https://developer.apple.com/documentation/systemconfiguration
    https://developer.apple.com/documentation/quicklook
    https://developer.apple.com/documentation/Updates
    https://developer.apple.com/documentation/symbols
    https://developer.apple.com/documentation/quicklookthumbnailing
    https://developer.apple.com/documentation/Xcode/swift-packages
    https://developer.apple.com/airplay/
    https://developer.apple.com/documentation/ProximityReader
    https://developer.apple.com/documentation/linkpresentation
    https://developer.apple.com/documentation/macos-release-notes
    https://developer.apple.com/documentation/mailkit
    https://developer.apple.com/documentation/safariservices/safari_app_extensions
    https://developer.apple.com/documentation/matter
    https://developer.apple.com/shareplay/
    https://developer.apple.com/documentation/ios-ipados-release-notes
    https://developer.apple.com/documentation/installer_js
    https://developer.apple.com/documentation/appstoreconnectapi
    https://developer.apple.com/documentation/eventkit
    https://developer.apple.com/documentation/appstorereceipts
    https://developer.apple.com/documentation/xcode
    https://developer.apple.com/documentation/uikit/keyboards_and_input/
    https://developer.apple.com/documentation/quicklook
    https://developer.apple.com/library/archive/documentation/General/Conceptual/ExtensibilityPG
    https://developer.apple.com/documentation/corespotlight/
    https://developer.apple.com/documentation/applearchive
    https://developer.apple.com/documentation/accelerate
https://developer.apple.com/documentation/apple-silicon/
https://developer.apple.com/documentation/scenekit
https://developer.apple.com/documentation/appstoreservernotifications
https://developer.apple.com/documentation/appstoreserverapi
https://developer.apple.com/documentation/applemusicapi
https://developer.apple.com/documentation/CryptoKit
https://developer.apple.com/documentation/automator
https://developer.apple.com/documentation/avfoundation
https://developer.apple.com/documentation/avkit
https://developer.apple.com/documentation/AVRouting
https://developer.apple.com/documentation/carplay
https://developer.apple.com/documentation/backgroundtasks
https://developer.apple.com/documentation/backgroundassets
https://developer.apple.com/documentation/cktooljs
https://developer.apple.com/documentation/clockkit
https://developer.apple.com/documentation/Combine
https://developer.apple.com/documentation/corelocation
https://developer.apple.com/documentation/coremotion
https://developer.apple.com/documentation/coremedia/
https://developer.apple.com/documentation/CoreTransferable
https://developer.apple.com/documentation/corevideo
https://developer.apple.com/documentation/CreateMLComponents
https://developer.apple.com/documentation/DeviceActivity
https://developer.apple.com/documentation/devicecheck
https://developer.apple.com/documentation/foundation
https://developer.apple.com/documentation/security
https://developer.apple.com/documentation/sensitivecontentanalysis
https://developer.apple.com/documentation/uikit
https://developer.apple.com/documentation/swift/
https://docs.swift.org/swift-book/documentation/
https://developer.apple.com/documentation/Updates/
https://developer.apple.com/documentation/localauthentication
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

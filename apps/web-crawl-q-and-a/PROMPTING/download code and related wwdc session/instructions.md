### 1. Web Scraping
#### 1.1. Starting Page: WWDC Sample Code
✅ - Start with the WWDC page for the given year, e.g., `https://developer.apple.com/sample-code/wwdc/2023/`.
✅ - Find all other listed years and iterate through those pages to find all "View code" links for all years
✅ - Save all urls found to a database if they haven't been already
#### 1.2. Code Sample Page
- Download the contents behind the download button on each code sample page.
- If present, follow the WWDC session link.
- Save files in a folder named after the title, e.g., "Backyard Birds: Building an app with SwiftData and widgets".
### 2. WWDC Session Page
#### 2.1. Overview Tab
- Click the Overview tab.
- Download the SD Video.
- Download all text along with their links from the Overview.
#### 2.2. Transcript Tab
- Extract all the text from the transcript along with the FULL href that the sentence points to.
- Format: 
deeplink: URL
text: Sentence
### 3. File Organization and Content Formatting
#### 3.1. Folder Structure
- For a sample titled "Backyard Birds: Building an app with SwiftData and widgets", the folder should contain:
- description.txt: Description of the app.
- platforms.txt: Supported platforms, e.g., "iOS macOS watchOS Xcode iPadOS".
- post.<Title>.txt: Extracted body of the code sample page, with code samples fenced and URLs maintained.
- Platforms State of the Union.<Title>.<video file extension>: Downloaded video from the session.
- overview.<Title>.txt: Overview from the session page.
- transcript.<Title>.txt: Transcript from the session page.
- code_links.<Title>.txt: Code links if present on the session page.
### 4. Additional Requirements
- Maintain URLs within the document by replacing plain text with the text (URL).
- Surround code samples with code fences: \`\`\`code\`\`\`.
- URLs for links within the document should be maintained by simply replacing the plain text with the text (URL).
- Ensure the proper naming of folders and files, using safe characters and replacing any colons with hyphens.
### 5. Final Summary
- All the operations should result in appropriately named files and folders based on the title from the original link.
- The extraction should encompass code samples, videos, transcripts, overviews, and any associated links from WWDC session pages.
- The organization should be coherent and consistent, allowing for easy navigation and understanding of the downloaded contents.
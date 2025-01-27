#!/usr/bin/env python3

# Prerequisites
# pip install requests beautifulsoup4

import os
import re
import sys
import requests
from bs4 import BeautifulSoup
from urllib.parse import urljoin, urlparse

BASE_URL = "https://www.mangaread.org/manga"

def download_images_from_chapters(url_suffix):
    # 1. Get the main page content
    manga_url = f"{BASE_URL}/{url_suffix}"
    print(f"Fetching chapter links for {manga_url}")
    try:
        response = requests.get(manga_url)
        response.raise_for_status()
    except requests.exceptions.RequestException as e:
        print(f"Error fetching {manga_url}: {e}")
        return

    soup = BeautifulSoup(response.text, 'html.parser')

    # 2. Find chapter links: pattern [manga_url]/chapter_[CHAPTER_NUMBER]/
    #    We'll use a regex to capture the chapter number from the href attribute.
    chapter_pattern = re.compile(rf'^{re.escape(manga_url.rstrip("/"))}/chapter-(\d+)/?$')
    chapter_links = []

    for a_tag in soup.find_all('a', href=True):
        href = a_tag['href']
        match = chapter_pattern.search(href)
        if match:
            chapter_number = int(match.group(1))
            chapter_links.append((chapter_number, href))

    # 3. Sort links by chapter number
    chapter_links.sort(key=lambda x: x[0])

    if not chapter_links:
        print("No chapter links found. Make sure the base URL is correct and the page uses the expected format.")
        return

    print(f"Found {len(chapter_links)} chapters. Starting download...")

    # 4. Visit each chapter page and download images
    for chapter_number, chapter_url in chapter_links:
        print(f"Processing Chapter {chapter_number} => {chapter_url}")

        # Create a directory named by the chapter number if it doesn't exist
        chapter_dir = f"{url_suffix}/chapter_{chapter_number}"
        os.makedirs(chapter_dir, exist_ok=True)

        # Fetch the chapter page
        try:
            chapter_response = requests.get(chapter_url)
            chapter_response.raise_for_status()
        except requests.exceptions.RequestException as e:
            print(f"Error fetching {chapter_url}: {e}")
            continue

        chapter_soup = BeautifulSoup(chapter_response.text, 'html.parser')

        # Find all images with class 'wp-manga-chapter-img'
        images = chapter_soup.find_all('img', class_='wp-manga-chapter-img')

        if not images:
            print(f"No images found for Chapter {chapter_number}.")
            continue

        for idx, img_tag in enumerate(images, start=1):
            # Some sites use data-src for lazy loading. If 'src' is missing, try 'data-src'.
            image_url = img_tag.get('src') or img_tag.get('data-src')

            # If image_url is relative, convert to absolute using urljoin
            image_url = urljoin(chapter_url, image_url)

            # Generate a filename from the image URL or just use a counter
            # For a more robust approach, parse out the actual filename:
            parsed = urlparse(image_url)
            filename = os.path.basename(parsed.path)
            if not filename:  # fallback if URL has no basename
                filename = f"image_{idx}.jpg"

            save_path = os.path.join(chapter_dir, filename)

            #print(f"  Downloading {image_url} -> {save_path}")
            try:
                img_data = requests.get(image_url).content
                with open(save_path, 'wb') as f:
                    f.write(img_data)
            except requests.exceptions.RequestException as e:
                print(f"  Error downloading {image_url}: {e}")

    print("Download complete!")

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print(f"Usage: python {os.path.basename(__file__)} <BASE_URL>")
        sys.exit(1)

    for url_suffix_arg in sys.argv[1:]:
        download_images_from_chapters(url_suffix_arg)


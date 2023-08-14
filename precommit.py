#!/usr/bin/env python3

import requests
import sys
import os
import json
from dotenv import load_dotenv

load_dotenv()

API_KEY = os.getenv("PASTEBIN_API_KEY")
GITHUB_USERNAME = os.getenv("GITHUB_USERNAME")
GITHUB_REPO = os.getenv("GITHUB_REPO")
GITHUB_BRANCH = os.getenv("GITHUB_BRANCH")
COMPUTERCRAFT_DIR = os.getenv("COMPUTERCRAFT_DIR")

def create_manifest(directory):
    manifest = {}

    for root, dirs, files in os.walk(directory):
        for filename in files:
            path = os.path.relpath(os.path.join(root, filename), directory)
            url = f"https://raw.githubusercontent.com/{GITHUB_USERNAME}/{GITHUB_REPO}/{GITHUB_BRANCH}/{COMPUTERCRAFT_DIR}/{directory}/{path}"
            manifest[path] = {"url": url}

    with open("manifest.json", "w") as outfile:
        json.dump(manifest, outfile, indent=4)

    return "manifest.json"

def modify_and_upload(filename, api_key):
    with open(filename, 'r') as file:
        file_content = file.read()

    file_content = file_content.replace("%%GITHUB_USERNAME%%", GITHUB_USERNAME)
    file_content = file_content.replace("%%GITHUB_REPO%%", GITHUB_REPO)
    file_content = file_content.replace("%%GITHUB_BRANCH%%", GITHUB_BRANCH)
    file_content = file_content.replace("%%COMPUTERCRAFT_DIR%%", COMPUTERCRAFT_DIR)

    url = "https://pastebin.com/api/api_post.php"
    data = {
        'api_dev_key': api_key,
        'api_option': 'paste',
        'api_paste_code': file_content,
        'api_paste_private': '1',
        'api_paste_name': filename,
        'api_paste_expire_date': '10M',
    }

    response = requests.post(url, data=data)

    
    if "pastebin.com" in response.text:
        pastebin_id = response.text.split('/')[-1]
        record = {
            "pastebin_link": response.text,
            "pastebin_run_command": f"pastebin run {pastebin_id}",
            "wget_run_command:": f"wget run https://raw.githubusercontent.com/{GITHUB_USERNAME}/{GITHUB_REPO}/{GITHUB_BRANCH}/downloader.lua"
        }

        with open("pastebin_record.json", "w") as file:
            json.dump(record, file, indent=4)

        return response.text
    else:
        wgetRecord = {
            "wget_run_command:": f"wget run https://raw.githubusercontent.com/{GITHUB_USERNAME}/{GITHUB_REPO}/{GITHUB_BRANCH}/git.downloader.lua"
        }
        with open("pastebin_record.json", "w") as file:
            json.dump(wgetRecord, file, indent=4)

        with open("git.downloader.lua", "w+") as file:
            file.write(file_content)

        return response.text
    
    
    
if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python upload_to_pastebin.py <filename>")
        sys.exit(1)

    filename = sys.argv[1]
    create_manifest(COMPUTERCRAFT_DIR)
    result = modify_and_upload(filename, API_KEY)

    if "pastebin.com" in result:
        print(f"File uploaded successfully! URL: {result}")
    else:
        print(f"Failed to upload. Error: {result}")

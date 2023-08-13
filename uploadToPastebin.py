import requests
import sys
import os
from dotenv import load_dotenv

load_dotenv()

API_KEY = os.getenv("PASTEBIN_API_KEY")  # Replace this with your API key or use an environment variable

def upload_to_pastebin(filename, api_key):
    with open(filename, 'r') as file:
        file_content = file.read()

    url = "https://pastebin.com/api/api_post.php"
    data = {
        'api_dev_key': api_key,
        'api_option': 'paste',
        'api_paste_code': file_content,
        'api_paste_private': '1',  # 0=public, 1=unlisted, 2=private
        'api_paste_name': filename,  # Name of the paste on Pastebin
        'api_paste_expire_date': '10M',  # Expires in 10 minutes, change as per your requirement
    }

    response = requests.post(url, data=data)
    return response.text

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python upload_to_pastebin.py <filename>")
        sys.exit(1)

    filename = sys.argv[1]


    result = upload_to_pastebin(filename, API_KEY)
    if "pastebin.com" in result:
        print(f"File uploaded successfully! URL: {result}")
    else:
        print(f"Failed to upload. Error: {result}")


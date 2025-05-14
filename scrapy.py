#!/usr/local/bin/python3.11
import os
from selenium import webdriver
from selenium.webdriver.chrome.service import Service
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.common.by import By
import time

if __name__ == '__main__':
    # Create a directory for downloaded files
    download_dir = os.path.join('tmp')
    os.makedirs(download_dir, exist_ok=True)

    # Set Chrome options
    print(download_dir)

    chrome_options = Options()
      # Enable headless mode
    chrome_options.add_argument("--headless=new")  # Use the 'new' headless mode for modern versions
    chrome_options.add_argument("--no-sandbox")
    chrome_options.add_argument("--disable-dev-shm-usage")
    chrome_options.add_argument("--disable-gpu")  # Disable GPU in headless mode for stability
    chrome_options.add_argument("--window-size=1920x1080")  # Set a default window size for the headless browser

    prefs = {
        "profile.default_content_settings.popups": 0,
        "download.default_directory": download_dir,  # Set download location
        "download.prompt_for_download": False,       # Disable download prompt
        "download.directory_upgrade": True,          # Allow directory upgrade
        "safebrowsing.enabled": True,                # Enable safe browsing (optional)
        "profile.default_content_setting_values.automatic_downloads": 1
    }
    chrome_options.add_experimental_option("prefs", prefs)

    # Initialize WebDriver with options
    # service = Service("/Users/juntaoduan/Applications/opt/chromedriver/chromedriver-mac-x64/chromedriver")  # Update with your chromedriver path
    # driver = webdriver.Chrome(service=service, options=chrome_options)
    driver = webdriver.Chrome(options=chrome_options)

    # Initialize WebDriver
    driver = webdriver.Chrome()
    try:
        # Navigate to the URL
        # imgurl='https://scontent-ord5-1.cdninstagram.com/v/t51.2885-19/118982623_353024589077161_7490638455124782637_n.jpg?stp=dst-jpg_e0_s150x150&_nc_ht=scontent-ord5-1.cdninstagram.com&_nc_cat=1&_nc_ohc=pw1Epfx4TJQQ7kNvgG2MRvm&_nc_gid=23c19670cd8b470f94369b1b84cce4e0&edm=AOQ1c0wBAAAA&ccb=7-5&oh=00_AYAh6CkqoBLfYM1606qmEFWLzdRYiFI547O72FkVCo9HOg&oe=66F56AE8&_nc_sid=8b3546'
        # imgurl='https://pbs.twimg.com/profile_images/1815749056821346304/jS8I28PL_400x400.jpg'
        imgurl='https://scontent-lis1-1.cdninstagram.com/v/t51.2885-19/452737457_1313286386312102_744138929735022550_n.jpg?stp=dst-jpg_s150x150&_nc_ht=scontent-lis1-1.cdninstagram.com&_nc_cat=102&_nc_ohc=GPbJ_SH5OtwQ7kNvgGxvZZc&_nc_gid=17f9b35e71c542dcb73aea25ef1833c3&edm=APs17CUBAAAA&ccb=7-5&oh=00_AYCWAFH8zB6aH5NP0RslE755ub999cVgrDt-jm3HVf1fZg&oe=66F59BCE&_nc_sid=10d13b'
        driver.get(imgurl)
        imgName = f'test_image_0030'

        js_script = f"""
            const images = document.querySelectorAll('img');
            images.forEach((img, index) => {{
                const canvas = document.createElement('canvas');
                const context = canvas.getContext('2d');
                canvas.width = img.naturalWidth;
                canvas.height = img.naturalHeight;
                context.drawImage(img, 0, 0);

                const base64String = canvas.toDataURL('image/png').split(',')[1];

                const payload = {{
                  cmd: 'imgupload',
                  p: {{
                    imgName: '{imgName}',
                    imgBase64Content: base64String
                  }}
                }};

                console.log('Image uploaded successfully:', payload);

                fetch('https://game.answerai.pro/api/backend', {{
                  method: 'POST',
                  headers: {{
                    'Content-Type': 'application/json'
                  }},
                  body: JSON.stringify(payload)
                }}).then(response => {{
                  if (response.ok) {{
                    return response.json();
                  }} else {{
                    console.error('Failed to upload image:', response.statusText);
                  }}
                }}).then(data => {{
                  if (data) {{
                    console.log('Image uploaded successfully:', data);
                  }}
                }}).catch(error => {{
                  console.error('Error:', error);
                }});
            }});
        """

        # Execute the JS script to trigger image downloads
        driver.execute_script(js_script)

        # Allow time for downloads to complete
        time.sleep(5000)

        print(f"Image downloaded to: {download_dir}")
    finally:
        driver.quit()
    pass

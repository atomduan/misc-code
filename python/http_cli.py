#!/usr/bin/env python
import requests
import urllib3
urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)

def foo_fetch():
    url = 'http://www.baidu.com'
    headers = {
        'Connection': 'keep-alive',
        'Cache-Control': 'max-age=0',
        'Upgrade-Insecure-Requests': '1',
        'User-Agent': 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.77 Safari/537.36',
        'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9',
        'Accept-Language': 'en-US,en;q=0.9',
        'Cookie': 'JSESSIONID=aaay0dAOL165Pde_JCVNx',
    }
    try:
        r = requests.get(url, headers=headers, verify=False, timeout=3)
        print(r.text())
    except Exception as e:
        return e

if __name__ == '__main__':
    foo_fetch()

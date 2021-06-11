#!/usr/bin/env python
import requests


def baidu_fetch():
    url = 'https://www.baidu.com'
    headers = {
        'Connection': 'keep-alive',
        'Cache-Control': 'max-age=0',
        'sec-ch-ua': '" Not;A Brand";v="99", "Google Chrome";v="91", "Chromium";v="91"',
        'Upgrade-Insecure-Requests': '1',
        'User-Agent': 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.77 Safari/537.36',
        'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9',
        'Sec-Fetch-Site': 'none',
        'Sec-Fetch-Mode': 'navigate',
        'Sec-Fetch-Dest': 'document',
        'Accept-Language': 'en-US,en;q=0.9',
        'Cookie': 'BIDUPSID=1C53EF5A7BE9CD22CBFF942B6180B01F; PSTM=1619750897; BAIDUID=1C53EF5A7BE9CD22061063A502B90353:FG=1; BD_UPN=123353; __yjs_duid=1_017713a33693b01e57f0d15fcdcc64931620278793043; BAIDUID_BFESS=1C53EF5A7BE9CD22061063A502B90353:FG=1; COOKIE_SESSION=3_1_7_2_41_55_0_0_7_7_0_14_0_0_0_4_1622787109_1622807233_1622807229%7C9%232427226_3_1622807229%7C2; BDORZ=B490B5EBF6F3CD402E515D22BCDA1598; BD_HOME=1; H_PS_PSSID=34100_33848_33855_33607_34111_26350; BA_HECTOR=2481a02l00al2ga0po1gc60rp0q',
    }
    try:
        r = requests.get(url, headers=headers, verify=False, timeout=3)
        print(r)
    except Exception as e:
        return e

if __name__ == '__main__':
    baidu_fetch()

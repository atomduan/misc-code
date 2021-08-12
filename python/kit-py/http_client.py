#!/usr/bin/env python
# -*- coding: utf-8 -*-

import urllib3
import requests
import base64
import time

Headers = {}
if __name__ == '__main__':
    try:
        payload = "/index.php"
        url = "http://www.baidu.com"
        payload_url = url+payload
        Headers['Sec-Fetch-Mode']='navigate'
        Headers['Sec-Fetch-User']='?1'
        Headers['Accept']='text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3'
        Headers['Sec-Fetch-Site']='none'
        Headers['accept-charset']="utf-8"
        resp = requests.get(payload_url,headers=Headers, timeout=5, verify=False)
        print(resp.text())
    except Exception as e:
        print(e)


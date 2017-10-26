#!/usr/bin/env python
#-*-coding:utf-8-*-

import sys
reload(sys)
sys.setdefaultencoding("utf-8")
import requests 
import urllib
import json
def main():
    data = "[{\"phone\":\"13800000000\",\"name\":\"xxx\",\"city\":\"北京\"}]"
    parameters = {
       "uid":"bd_jrsc",
       "token":"2df4121b541f961f20dbda02cf9158b5",
       "product_type":2,
       "origin":"...",
       "market_channel":"...",
       "data":data
    }
    print parameters

    paras =urllib.urlencode(parameters)
    url="https://qxy.yxapp.co/api/clues"
    response = requests.post(url, params=parameters, verify=False)
    print response.status_code
    print response.content

if __name__ == "__main__":
    main()

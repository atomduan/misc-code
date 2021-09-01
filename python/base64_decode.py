#!/usr/bin/env python
import os
import sys
import base64

if __name__ == '__main__':
    with open('/dev/stdin') as f:
        for line in iter(f):
            params = line.strip().split(' ');
            suid = params[0].strip()
            iddc = base64.b64decode(params[1].strip())
            print(suid+" "+iddc[6:14])

#!/usr/bin/env python

import sys
import re

def process_line(line):
    res = ''.join(x.capitalize() or '' for x in line.split('_'))
    print(res)

if __name__ == '__main__':
    with open('/dev/stdin') as f:
        for line in iter(f):
            process_line(line.strip())

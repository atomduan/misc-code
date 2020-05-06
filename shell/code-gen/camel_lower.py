#!/usr/bin/env python

import sys
import re

lower_func = lambda s: s[:1].lower() + s[1:] if s else ''

def process_line(line):
    res = ''.join(x.capitalize() or '' for x in line.split('_'))
    print(lower_func(res))

if __name__ == '__main__':
    with open('/dev/stdin') as f:
        for line in iter(f):
            process_line(line.strip())

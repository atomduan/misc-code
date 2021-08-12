#!/usr/local/bin/python3

import sys
import re

dict={}

def process(line):
    # process logic
    pass

if __name__ == '__main__':
    with open('/dev/stdin') as f:
        for line in iter(f):
            process(line.strip())

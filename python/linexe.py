#!/usr/bin/python
import sys

def process_line(line):
    print line

if __name__ == '__main__':
    for line in sys.stdin.readlines():
        process_line(line.strip())

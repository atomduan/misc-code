#!/usr/bin/python
import sys

def process_line(line):
    ps = line.split(' ')
    if ps[2] == ps[1]:
        print line

if __name__ == '__main__':
    f = open('/dev/stdin')
    for l in f.readlines():
        process_line(l.rstrip())
    f.close()

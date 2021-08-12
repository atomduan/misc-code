#!/usr/bin/python3
import sys

def process(argv):
    s = argv[1]
    h = 0
    for c in s:
        h = 31 * h + ord(c)
    if h < 2147483647:  
        shard = h % 100
    else:
        h = (~h) + 1
        print(str(bytes(h)))
        shard = h % 100
    print("shard index is : " + str(shard))

if __name__ == '__main__':
    sys.exit(process(sys.argv))

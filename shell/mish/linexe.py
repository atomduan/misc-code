#!/usr/bin/python
import sys

order_dict=[]

def process_line(line):
    ps = line.split(' ')
    pr = int(ps[1])
    if pr > 100:
        score = ((pr-100)/100+1)*50
    else:
        score = 50
    print line+" "+str(score)

if __name__ == '__main__':
    f = open('/dev/stdin')
    for l in f.readlines():
        process_line(l.rstrip())
    f.close()

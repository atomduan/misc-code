#!/usr/bin/env python
import sys

pd = []

def is_prime(n):
    for k in range(2,n-1):
        if n % k == 0:
            return False
    return True
        

def check(ntar):
    res = []
    for line in range(49999,99999):
        if ntar % line == 0:
            res.append(line);
    if len(res) == 2:
        if is_prime(res[0]) and is_prime(res[1]):
            print(str(ntar)+"-->"+str(res));

if __name__ == '__main__':
    f = open('/home/juntaoduan/prime.list','r')
    for p in f.readline():
        p = p.strip()
        if len(p) > 0:
            pd.append(int(p.strip()))
    
    tar=6541367
    for k in range (1,999):
        ntar = tar*1000+k
        check(ntar);

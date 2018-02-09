#!/usr/bin/python

def main(argv):
    f = open('/dev/stdin')
    for l in f.readlines():
        ps = l.rstrip().split(' ')
        if ps[2] == ps[1]:
                print l

if __name__ == '__main__':
    import sys
    sys.exit(main(sys.argv))

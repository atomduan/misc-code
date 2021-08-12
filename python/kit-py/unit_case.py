#!/usr/local/bin/python3

import sys
import re

dict={}

def trans_cap(s):
    #return None
    return s.capitalize()

def process(argv):
    # process logic
    sample = 'abc_1ad_2qq_3sk'
    '''
    res = ''.join(s.capitalize() for s in sample.split('_'))
    '''
    res = ''.join(None or 'aaa' for s in sample.split('_'))
    print(res)
    pass

if __name__ == '__main__':
    sys.exit(process(sys.argv))

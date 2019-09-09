#!/bin/env python
#-*-coding:utf-8-*-

import sys
import re
from datetime import datetime

def process_line(line):
    params = line.split('\t');
    create_time = to_date(long(params[16]))
    can_settle = to_cansettle(int(params[18]))
    print create_time 

def to_date(timestamp):
    ts = datetime.fromtimestamp(timestamp/1000)
    return ts.strftime('%Y-%m-%d_%H:%M:%S')

def to_cansettle(cs):
    return 'YES' if cs==1 else 'NO'

if __name__ == '__main__':
    file = '~/tmp/res.list.unic'
    with open(file) as f:
        for line in iter(f):
            process_line(line.strip());

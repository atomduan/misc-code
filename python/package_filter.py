#!/bin/env python

import sys
import re

#按照顺序读取多个文件，并根据第一列进行去重，去重的优先级是前文件出现的key的优先级高于后文件
#之前用list[]实现，他的is in非常慢。改用set()方法，速度快了非常多

base_file_dir = "/home/rd/huqian/data/push/test"
file_list = base_file_dir+"/file.list"
separator = ' '

pkg_dict = set()

def process_file(file_name):
    global pkg_dict
    count = 0
    file_path = base_file_dir+"/"+file_name
    rf = open(file_path)
    wf = open(file_path+".out.txt",'w')
    print "try to filter "+file_path+" now ......"
    for record in rf.readlines():
        count += 1
        try:
            params = record.split(separator)
            key = params[0].strip()
            if key not in pkg_dict:
                pkg_dict.add(key)
                wf.write(record)
        except Exception,msg:
            print("Error occure while parsing "+record.rstrip()+" msg:"+str(msg))
        if count % 10000 == 0:
            print str(count)+" records processed ......"
    wf.close()
    rf.close()

if __name__ == '__main__':
    f = open(file_list)
    for l in f.readlines():
        process_file(l.strip())
    f.close()

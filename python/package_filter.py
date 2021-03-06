#!/bin/env python

import sys
import re

#按照顺序读取多个文件，并根据第一列进行去重，去重的优先级是前文件出现的key的优先级高于后文件
#之前用list[]实现，他的is in非常慢。改用set()方法，速度快了非常多
#file.list中每行是一个文件名字，考前的文件名字有较高的优先级

base_file_dir = "/home/rd/huqian/data/push/test"
file_list = base_file_dir+"/file.list"
separator = ' '

pkg_dict = set()

def process_file(file_name):
    count = 0
    file_path = base_file_dir+"/"+file_name
    with open(file_path) as rf:
        with open(file_path+".out.txt",'w') as wf:
            print "try to filter %s now ......" % (file_path)
            for record in iter(rf):
                count += 1
                try:
                    params = record.split(separator)
                    key = params[0].strip()
                    if key not in pkg_dict:
                        pkg_dict.add(key)
                        wf.write(record)
                except Exception,msg:
                    print "error occure while parsing: %s , msg: %s" % (record.rstrip(),str(msg))
                if count % 10 == 0:
                    print "%d records processed ......" % (count)

if __name__ == '__main__':
    with open(file_list) as f:
        for line in iter(f):
            file_name = line.strip()
            if len(file_name) > 0:
                process_file(file_name)

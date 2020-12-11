#!/usr/bin/env python
import os
import sys
import argparse

# 输入数据格式 -> 同mvn dependency:tree 的输出数据的整理
#     org.apache.httpcomponents:httpasyncclient:jar:4.1.3:compile
#     org.apache.httpcomponents:httpcore:jar:4.4.6:compile
#     org.apache.httpcomponents:httpcore-nio:jar:4.4.6:compile
#     org.apache.httpcomponents:httpclient:jar:4.5.3:compile
if __name__ == '__main__':
    with open('/dev/stdin') as f:
        for line in iter(f):
            record = line.strip()
            if len(record) > 0:
                params = record.split(':')
                groupId = params[0]
                artifactId = params[1]
                version = params[3]
                res =     '<dependency>\n'
                res = res+'    <groupId>'+groupId+'</groupId>\n'
                res = res+'    <artifactId>'+artifactId+'</artifactId>\n'
                res = res+'    <version>'+version+'</version>\n'
                res = res+'</dependency>'
                print(res)

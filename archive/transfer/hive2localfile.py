#!/usr/bin/python
# -*- coding: UTF-8 -*-
import sys
import os
import datetime
import time
import re
import subprocess
import shlex
import json
import hashlib

def get_argv(args):
    if len(args) == 6:
        return True
    else:
        print "PLEASE PATH,DATE,SYS,TABLENAME,SQL  , THEN RE-RUN THE SCRIPT."
        return False

def get_argv_scurity(args):
    if len(args) == 6:
        return True
    else:
        print "PLEASE PATH,DATE,SYS,TABLENAME,SQL  , THEN RE-RUN THE SCRIPT."
        return False

def execcmd(cmdlist):
    res = 0
    print cmdlist
    cmd = shlex.split(cmdlist.encode('ascii'))
    #print cmd,type(cmd)
    res = subprocess.call(cmdlist,shell=True)
    return res

def buildcmdForExportHive2Local(path,date,sys,hql):
    finalhql = hql%(date,)
    print finalhql
    cmdstr = "hive -e \"insert overwrite local directory '%s/%s/%s_tmp/' %s\" " %(path,date,sys ,finalhql)
    print "load hive data  into local directory cmd is :%s"%(cmdstr,)
    return cmdstr

def generateMd5(srcfile,md5destfile):
    md5file=open(srcfile,"rb")
    md5=hashlib.md5(md5file.read()).hexdigest()
    md5file.close()
    print(md5)
    cmdStr = "echo %s > %s"%(md5,md5destfile)
    return execcmd(cmdStr)

# copy hdfs files of hive table to local files
def execExportHiveData2LocalFiles(params):
    path = params[0]
    date = params[1]
    sys = params[2]
    tablename = params[3]
    sql = params[4]
    cmdstr = buildcmdForExportHive2Local(path,date,sys,sql)
    execcmd(cmdstr)

    deleteTmpFilesStr = "rm -rf  %s/%s/%s"%(path,date,sys)
    execcmd(deleteTmpFilesStr)
    mkdirStr = "mkdir -p  %s/%s/%s"%(path,date ,sys)
    execcmd(mkdirStr)
    mergefilesStr = "cat %s/%s/%s_tmp/*>%s/%s/%s/%s_%s.dat"%(path,date,sys,path,date,sys,tablename,date)
    execcmd(mergefilesStr)
    deleteTmpFilesStr = "rm -rf  %s/%s/%s_tmp"%(path,date,sys)
    execcmd(deleteTmpFilesStr)
    destfile = "%s/%s/%s/%s_%s.dat"%(path,date,sys,tablename,date)
    destmd5file = "%s/%s/%s/%s_%s.md5"%(path,date,sys,tablename,date)

    flag =  generateMd5(destfile,destmd5file)    
    print flag  
  
if __name__ == "__main__":
     if not get_argv(sys.argv):
        sys.exit(1)
     flag = execExportHiveData2LocalFiles(sys.argv[1:])
     exit(flag)

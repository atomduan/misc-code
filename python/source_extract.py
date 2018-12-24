#!/usr/bin/python
import os
import shutil
from subprocess import call

m2_repo = '/home/hexie/.m2'
repo_path_prefix = m2_repo+'/repository'
source_path_prefix = m2_repo+'/repository_source'

#specified you repo source.jar path 
repo_path = repo_path_prefix


def extract_src_jar(jar_path):
    if len(jar_path) == 0:
        return
    if os.path.isfile(jar_path):
        #clean dictionaries in jar_dir
        jar_dir = os.path.dirname(jar_path)
        dirs = [jar_dir+'/'+d for d in os.listdir(jar_dir) if os.path.isdir(jar_dir+'/'+d)]
        for d in dirs:
            if len(source_path_prefix)>0 and source_path_prefix in d:
                os.rmdir(d)
        #extract jar_path in jar_dir
        jar_name = os.path.basename(jar_path)
        cmd = 'cd %s; jar -xf %s;'%(jar_dir,jar_name)
        try:
            res = os.system(cmd)
            if res != 0:
                print '[WARN] cmd %s excute return abnormal, code %d'%(cmd,res)
        except Exception,msg:
            print '[ERROR] extracting fail jar_path: %s , msg: %s'%(jar_path,str(msg))
            print '[ERROR] relevant cmd is: %s'%(cmd)


def extract_source_from_repo():
    if not os.isdir(repo_path):
        print '[ERROR] repo_path %s is not a dir or exsited...'%(repo_path)
        return
    for root,dirs,files in os.walk(repo_path):
        for f in files:
            if os.path.splitext(f)[1] == '.jar':
                src_jar_path=root+'/'+str(f)
                if 'sources.jar' in src_jar_path and os.path.isfile(src_jar_path):
                    des_dir = root.replace(repo_path_prefix,source_path_prefix)
                    des_jar_path = des_dir+'/'+str(f)
                    if not os.path.exists(des_dir):
                        os.makedirs(des_dir)
                    shutil.copyfile(src_jar_path,des_jar_path)
                    extract_src_jar(des_jar_path);


if __name__ == '__main__':
    extract_source_from_repo()

#!/usr/bin/python
import os
import shutil

m2_repo = '/home/hexie/.m2'
repo_path_prefix = m2_repo+'/repository'
source_path_prefix = m2_repo+'/repository_source'

repo_path = repo_path_prefix
src_path = source_path_prefix


def extract_src_jar(jar_path):
    print jar_path
    if os.path.isfile(jar_path):
        #clean dictionaries in jar_dir
        jar_dir = os.path.dirname(jar_path)
        dirs = [jar_dir+'/'+d for d in os.listdir(jar_dir) if os.path.isdir(jar_dir+'/'+d)]
        for d in dirs:
            if len(source_path_prefix)>0 and source_path_prefix in d:
                os.rmdir(d)
        #extract source.jar


def extract_source_from_repo():
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

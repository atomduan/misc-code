#!/usr/bin/env python
import os
import shutil

m2_repo = '/home/mi/.m2'
repo_path_prefix = m2_repo+'/repository'
source_path_prefix = m2_repo+'/repository_source'

#specified you repo source.jar path 
repo_path = repo_path_prefix

package_filter = [];
#package_filter = ['hadoop'];
#package_filter = ['antlr'];
#package_filter = ['unirest-java'];


def extract_src_jar(jar_path):
    if len(jar_path) == 0:
        return
    if os.path.isfile(jar_path):
        #clean dictionaries in jar_dir
        jar_dir = os.path.dirname(jar_path)
        dirs = [jar_dir+'/'+d for d in os.listdir(jar_dir) if os.path.isdir(jar_dir+'/'+d)]
        for d in dirs:
            if len(source_path_prefix)>0 and source_path_prefix in d:
                print('[INFO] path:%s not empty, try to rmtree'%(d))
                shutil.rmtree(d,ignore_errors=True)
        #extract jar_path in jar_dir
        jar_name = os.path.basename(jar_path)
        cmd = 'cd %s; jar -xf %s;'%(jar_dir,jar_name)
        try:
            print('os.system exec cmd: %s'%(cmd))
            res = os.system(cmd)
            if res != 0:
                print('[WARN] cmd %s excute return abnormal, code %d'%(cmd,res))
            else:
                print('SUCCESS......')
        except Exception as msg:
            print('[ERROR] extracting fail jar_path: %s , msg: %s'%(jar_path,str(msg)))
            print('[ERROR] relevant cmd is: %s'%(cmd))


def process_single_source_pkg(root,dirs,f,src_jar_path):
    des_dir = root.replace(repo_path_prefix,source_path_prefix)
    des_jar_path = des_dir+'/'+str(f)
    if not os.path.exists(des_dir):
        os.makedirs(des_dir)
    shutil.copyfile(src_jar_path,des_jar_path)
    extract_src_jar(des_jar_path);


def extract_source_from_repo():
    if not os.path.isdir(repo_path):
        print('[ERROR] repo_path %s is not a dir or exsited...'%(repo_path))
        return
    for root,dirs,files in os.walk(repo_path):
        for f in files:
            if os.path.splitext(f)[1] == '.jar':
                src_jar_path=root+'/'+str(f)
                if 'sources.jar' in src_jar_path and os.path.isfile(src_jar_path):
                    if len(package_filter) > 0:
                        for fig in package_filter:
                            if fig in src_jar_path:
                                print('[INFO] filter hitted %s, processe this package'%(fig))
                                process_single_source_pkg(root,dirs,f,src_jar_path)
                                break;
                    else:
                        print('[INFO] no filter processe ALL package')
                        process_single_source_pkg(root,dirs,f,src_jar_path)


if __name__ == '__main__':
    extract_source_from_repo()

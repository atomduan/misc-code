#!/bin/env python
#A python 2.X code

"""Read a config.yaml and
1. Download
2. extract
3. copy and create symlinks in the target directories
If anything wrong during the process, it'll quit with non-zero.

"""
import urllib2
import yaml
from subprocess import Popen, PIPE
import os
import shutil

def extract(tarball, target_dir, strip=0):
    """Return a list of extracted files/folders"""

    if os.path.exists(target_dir):
        shutil.rmtree(target_dir)

    os.mkdir(target_dir)
    tar = Popen("tar xzf %s -C %s --strip=%d" % (tarball, target_dir, strip), shell=True, stdin=PIPE, stdout=PIPE, stderr=PIPE)
    output, err = tar.communicate()
    ret = tar.wait()
    print("Extract tarball output: " + output)
    print("tar command returns "+str(ret))
    print("Error message: "+err)
    assert ret == 0, "tar returns non-zero"
    #return map(lambda x: "%s/%s" % (target_dir, x), os.listdir(target_dir))
    return target_dir


def download(url, rename):
    filename = 'foobar.tgz'
    if rename is None:
        #do not rename
        filename = os.path.split(url)[-1]
    else:
        filename = rename

    f = urllib2.urlopen(url)
    print("download from "  + url)
    with open(filename, "wb") as code:
        code.write(f.read())

    return filename

def compile(file, args):
    pass

def install(target_dir, tmp_dir, symlinks=None):
    #copy the files from TMPDIR to the target folder
    #create a symlink
    if not os.path.isdir(target_dir):
        os.mkdir(target_dir)
    for f in os.listdir(tmp_dir):
        print("move %s to %s" % (tmp_dir + "/" + f, target_dir))
        if os.path.exists(target_dir + "/" + f):
            if os.path.isdir(target_dir + "/" + f):
                shutil.rmtree(target_dir + "/" + f)
            else:
                os.remove(target_dir + "/" + f)
        shutil.move(tmp_dir + "/" + f, target_dir)
    
    #replace the default env
    if os.path.isdir(target_dir+"/bin"):
        if os.path.isfile("deploy/resources/env"):
            if os.path.isfile(target_dir+"/bin/env"):
                os.remove(target_dir+"/bin/env")
            shutil.copy("deploy/resources/env", target_dir+"/bin/")

    os.chdir(target_dir)
    if symlinks is not None:
        for (link, src) in symlinks:
            print("create sym link %s -> %s" % (link, src))
            if os.path.exists(link):
                os.unlink(link)
            os.symlink(src, link)
    print("new version deploy success......")

def main(argv):

    argv.append("config.yaml") # it is the default argument
    config_file = argv[1]
    with open(config_file) as cf:
        config = yaml.load(cf)

    if os.environ.has_key("SCRIPT_DIR"):
        cwd = os.environ["SCRIPT_DIR"]
        os.chdir(cwd)

    filename = download(config['GIT_URL'], None)
    tmp_dir = extract(filename, config['TMPDIR'], config.get('DIR_STRIP_LEVEL', 0))
    #print("get files: " + str(entries))
    install(config['INSTALL_TO'], tmp_dir, symlinks=config['SYMLINKS'])


if __name__ == '__main__':
    import sys
    sys.exit(main(sys.argv))


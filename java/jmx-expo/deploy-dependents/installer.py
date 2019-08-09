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
import ConfigParser

def extract(tarball, target_dir, strip='0'):
    """Return a list of extracted files/folders"""

    if os.path.exists(target_dir):
        shutil.rmtree(target_dir)

    os.mkdir(target_dir)
    cmd = "tar xzf %s -C %s --strip-components=%s" % (tarball, target_dir, strip)
    print(cmd)
    tar = Popen(cmd, shell=True, stdin=PIPE, stdout=PIPE, stderr=PIPE)
    output, err = tar.communicate()
    ret = tar.wait()
    print("Extract tarball output: " + output)
    print("tar command returns "+str(ret))
    print("Error message: "+err)
    assert ret == 0, "tar returns non-zero"
    #return map(lambda x: "%s/%s" % (target_dir, x), os.listdir(target_dir))
    os.system("ls -l %s" % target_dir)
    os.system("rm -rf %s" % tarball )
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

    print("download the file:")
    os.system("ls -l %s" % filename)

    return filename


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

    old_dir = os.path.abspath(os.curdir)
    os.chdir(target_dir)
    if symlinks:
        (link, src) = symlinks.split(',')
        print("create sym link %s -> %s" % (link, src))
        if os.path.exists(link):
            os.unlink(link)
        os.symlink(src, link)
        assert os.path.isdir(src), "%s is not a directory." % src
        assert os.path.exists(link), "a broken symlink to %s" % src
    
    os.chdir(old_dir)

def get_config(config_file):
    config = ConfigParser.ConfigParser()
    config.read(config_file)
    return config

def main(argv):
    argv.append("software.conf") # it is the default argument
    config_file = argv[1]
    #if os.environ.has_key("SCRIPT_DIR"):
    #    cwd = os.environ["SCRIPT_DIR"]
    #    os.chdir(cwd)
    configs = get_config(config_file)
    config_options = configs.options('software')
    software_installs = []
    for software_name in config_options:
        software_install = software_name + '-' + configs.get('software', software_name)
        software_installs.append(software_install)

    software_configs = get_config('deploy-dependents/software_installer.conf')
    for software_install in software_installs:
        install_configs = dict(software_configs.items(software_install))
        filename = download(install_configs['git_url'], None)
        tmp_dir = extract(filename, install_configs['tmpdir'], install_configs.get('dir_strip_level', '0'))
        symlinks=install_configs.get(('symlinks'),None)
        print(symlinks)
        install(install_configs['install_to'], tmp_dir, symlinks=install_configs['symlinks'])

if __name__ == '__main__':
    import sys
    sys.exit(main(sys.argv))

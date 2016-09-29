#!/usr/bin/python2.6
import pexpect
import os, sys, getpass


def get_argv(args):
    if len(args) == 7:
        return True
    else:
        print "PLEASE INPUT PARAMETERS LIKE THESE, EX: IP, PORT, USERNAME, PASSWORD, DST_PATH, FILENAME . THEN RE-RUN THE SCRIPT."
        return False

def scp(ip, port, user, passwd, dst_path, filename):
    passwd_key = '.*assword.*'
    if os.path.isdir(filename):
        cmdline = 'scp -P %s -r %s %s@%s:%s' % (port, filename, user, ip, dst_path)
    else:
        cmdline = 'scp -P %s %s %s@%s:%s' % (port, filename, user, ip, dst_path)
    try:
        print "cmdline %s" % cmdline
        child = pexpect.spawn(cmdline)
        child.expect(passwd_key)
        child.sendline(passwd)
        child.expect(pexpect.EOF)
        print "UPLOADING"
    except:
        print "UPLOAD FAILD!"
        sys.exit(1) 

if __name__ == "__main__":
    if not get_argv(sys.argv):
     	sys.exit(1)
    ip = sys.argv[1]
    port = sys.argv[2]
    user = sys.argv[3]
    passwd = sys.argv[4]
    dst_path = sys.argv[5]
    filename = sys.argv[6]
    scp(ip, port, user, passwd, dst_path, filename)

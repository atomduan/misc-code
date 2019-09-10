#!/usr/bin/env python
# -*- coding: utf-8 -*-

import os
import fcntl
import socket
import re
import sys
import time
import json
import commands
import argparse
import requests

class LockFile:

    def __init__(self, filename, timeout=1):
        self.filename = filename
    
    def __enter__(self):
        self.f=open(self.filename, "w")
        fcntl.flock(self.f, fcntl.LOCK_NB | fcntl.LOCK_EX)
        return(self)

    def __exit__(self, type, value, traceback):
        fcntl.flock(self.f, fcntl.LOCK_NB | fcntl.LOCK_UN)
        self.f.close()
        os.remove(self.filename)
        if value:
            #got exceptions
            print(type, value, traceback)

    def __str__(self):
        return(self.filename)

def wait_for_lock(lock_file):
    pass

def flatten_dict(data):
    new_data = {}
    for k in data.keys():
        for k_k in data[k]:
            new_data["%s_%s" % (k, k_k)] = data[k][k_k]
    return new_data

def send_to_falcon_transfer(ep, data, tags="", counter_type="GAUGE"):
    data = flatten_dict(data)
    ts = int(time.time())
    d = []
    for metric in data.keys():
        d.append({"endpoint":ep, "metric":metric, "tags":tags, "timestamp":ts, \
            "value":float(data[metric]['value']), "step":60, \
            "counterType":counter_type})

    r = requests.post("http://localhost:1988/v1/push", data=json.dumps(d))
    print(r.text)

def jmx_update(srv, host, port):

    java_home = os.environ.get("JAVA_HOME")
    if not java_home:
        print "ERROR: Please set JAVA_HOME"
        sys.exit(1)

    if os.path.exists("%s/jre/lib/management/jmxremote.password" % java_home):
        jmx_role = "monitorRole"
        cmd = "awk '{if($1==\"%s\") print $2}' %s/jre/lib/management/jmxremote.password" % (jmx_role, java_home)
        jmx_password = os.popen(cmd).read().strip('\n')
    else:
        jmx_role = ""
        jmx_password = ""

    jmx_info = {}
    jvm_key = ""
    run_lock = "/dev/shm/jmxmonitor_" + srv + ".lock"
    with LockFile(run_lock) as lock:
        cmd = "%s/bin/java -classpath .:../lib/dependency/*:../lib/jmxMonitor-0.0.1-SNAPSHOT.jar com.lolo.sre.jmxmonitor.common.jmxCollClient %s %s %s %s" % (java_home, host, port, jmx_role, jmx_password)
        jvm_key = os.popen(cmd).read()

    if re.match('ERROR', jvm_key):
        print jvm_key.strip()
    else:
        json_info = json.load(file('../conf/collectConf.json'))
        for key in jvm_key.strip('\n').split('\n'):
            json_info[key.split(':')[0]][key.split(':')[1]]['value'] = key.split(':')[2]
            del json_info[key.split(':')[0]][key.split(':')[1]]['Name']
            del json_info[key.split(':')[0]][key.split(':')[1]]['Attribute']
            del json_info[key.split(':')[0]][key.split(':')[1]]['Methods']
            del json_info[key.split(':')[0]][key.split(':')[1]]['ClassName']
            del json_info[key.split(':')[0]][key.split(':')[1]]['Parameter']

        for key in json_info.keys():
            for item in json_info[key].keys():
                if "value" not in json_info[key][item].keys():
                    del json_info[key][item]
            if key in jvm_key:
                jmx_info[key] = json_info[key]
        endpoint = socket.gethostname()
        send_to_falcon_transfer(endpoint, jmx_info, tags="service={0}".format(srv))

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='collect the jvm status by querying the JMX of a specified jvm.')
    parser.add_argument('--host', default="localhost", help="which host the jvm is running on.")
    parser.add_argument('--port', help='the jmx port.')
    parser.add_argument("service_name", help="the service name")
    args = parser.parse_args()

    time.sleep(hash(args.port) % 10)
    jmx_update(args.service_name, args.host, args.port)



#!/usr/bin/env python
# -*- coding: utf-8 -*-

import commands, json, os, os.path, re, socket, time, urllib2

# falcon sample data
sam = {
    "Metric": "",
    "Endpoint": socket.gethostname(),
    "Timestamp": int(time.time()),
    "Step": 60,
    "Value": 0,
    "CounterType": "GAUGE",
    "TAGS": "",
}

jps = "/opt/jdk/bin/jps"
java = "/opt/jdk/bin/java"

## set Java CLASSPATH
curdir = os.path.dirname(os.path.realpath(__file__))
repo = "%s/repo" % (curdir)
if not os.path.exists(repo):
    os._exit(0)
jars = os.listdir(repo)
classpath = "/opt/soft/jdk/lib/tools.jar"
for jar in jars:
    if classpath == "":
        classpath = "%s/%s" % (repo, jar)
    else:
        classpath += ":%s/%s" % (repo, jar)
if classpath == None or classpath == "":
    os._exit(0)

## find JVMs
jvms = {}
status, output = commands.getstatusoutput("%s -v | grep -v Jps" % (jps))
lines = re.split("\n|\r|\r\n", output)
for line in lines:
    line = line.strip()
    pid = re.match("^([0-9]+)", line)
    if pid == None:
        continue
    pid = pid.groups()[0]
    if not jvms.has_key(pid):
        jvms[pid] = {}
    jvms[pid]["pid"] = pid

status, output = commands.getstatusoutput("%s -m | grep -v Jps" % (jps))
lines = re.split("\n|\r|\r\n", output)
for line in lines:
    line = line.strip()
    pid = re.match("^([0-9]+)", line)
    if pid == None:
        continue
    pid = pid.groups()[0]
    if not jvms.has_key(pid):
        continue
    service = None
    if re.match("^[0-9]+\s+Resin", line):
        service = re.findall("-server\s+([A-Za-z-.]+)", line)
        if service == None or len(service) <= 0:
            continue
        service = service[0]
    else:
        record = line.split()
        if record == None or len(record) < 2:
            continue
        service = record[1]
        service = re.sub("(Service)?Main$", "", service)
    if service == None or service == "":
        del jvms[pid]
    jvms[pid]["service"] = service

status, output = commands.getstatusoutput("god status | sed $'s,\x1b\\[[0-9;]*[a-zA-Z],,g'")
lines = re.split("\n|\r|\r\n", output)
for line in lines:
    line = line.strip()
    pid = re.match("^([^_]+)_.*\[([0-9]+)", line)
    if pid == None:
        continue
    service = pid.group(1)
    pid = pid.group(2)
    if not jvms.has_key(pid):
        continue
    jvms[pid]["service"] = service

if len(jvms) <= 0:
    os._exit(0)

falcon_data = []
for pid, jvm in jvms.items():
    cmd = "%s -cp %s com.kali.sre.JMXMonitor %s %s monitorRole passw0rd" % (java, classpath, "by_pid", jvm["pid"])
    status, output = commands.getstatusoutput(cmd)
    if output == None or output == "":
        continue
    beans = json.loads(output)
    beans = beans["beans"]
    for b in beans:
        if re.match("^java.lang:type=MemoryPool", b["name"]):
            memtype = re.findall("name=(.*)$", b["name"])
            if memtype == None or len(memtype) <= 0:
                continue
            memtype = memtype[0]
            memtype = memtype.replace(" ", "-")
            if b.has_key("CollectionUsage") and b["CollectionUsage"] != None:
                q = {}
                q.update(sam)
                q["Metric"] = "CollectionUsage"
                q["TAGS"] = "service=%s,MemoryType=%s" % (jvm["service"], memtype)
                q["Value"] = b["CollectionUsage"]["used"]
                falcon_data.append(q)
                q = {}
                q.update(sam)
                q["Metric"] = "CollectionUseRate"
                q["TAGS"] = "service=%s,MemoryType=%s" % (jvm["service"], memtype)
                q["Value"] = b["CollectionUsage"]["used"] / float(b["CollectionUsage"]["max"]) * 100
                falcon_data.append(q)
            if b.has_key("Usage") and b["Usage"] != None:
                q = {}
                q.update(sam)
                q["Metric"] = "Usage"
                q["TAGS"] = "service=%s,MemoryType=%s" % (jvm["service"], memtype)
                q["Value"] = b["Usage"]["used"]
                falcon_data.append(q)
                q = {}
                q.update(sam)
                q["Metric"] = "UseRate"
                q["TAGS"] = "service=%s,MemoryType=%s" % (jvm["service"], memtype)
                q["Value"] = b["Usage"]["used"] / float(b["Usage"]["max"]) * 100
                falcon_data.append(q)
            if b.has_key("PeakUsage") and b["PeakUsage"] != None:
                q = {}
                q.update(sam)
                q["Metric"] = "PeakUsage"
                q["TAGS"] = "service=%s,MemoryType=%s" % (jvm["service"], memtype)
                q["Value"] = b["PeakUsage"]["used"]
                falcon_data.append(q)
                q = {}
                q.update(sam)
                q["Metric"] = "PeakUseRate"
                q["TAGS"] = "service=%s,MemoryType=%s" % (jvm["service"], memtype)
                q["Value"] = b["PeakUsage"]["used"] / float(b["PeakUsage"]["max"]) * 100
                falcon_data.append(q)
        elif re.match("^java.lang:type=Memory", b["name"]):
            if b.has_key("HeapMemoryUsage") and b["HeapMemoryUsage"] != None:
                q = {}
                q.update(sam)
                q["Metric"] = "HeapMemoryUsage"
                q["TAGS"] = "service=%s" % (jvm["service"])
                q["Value"] = b["HeapMemoryUsage"]["used"]
                falcon_data.append(q)
                q = {}
                q.update(sam)
                q["Metric"] = "HeapMemoryUseRate"
                q["TAGS"] = "service=%s" % (jvm["service"])
                q["Value"] = b["HeapMemoryUsage"]["used"] / float(b["HeapMemoryUsage"]["max"]) * 100
                falcon_data.append(q)
            if b.has_key("NonHeapMemoryUsage") and b["NonHeapMemoryUsage"] != None:
                q = {}
                q.update(sam)
                q["Metric"] = "NonHeapMemoryUsage"
                q["TAGS"] = "service=%s" % (jvm["service"])
                q["Value"] = b["HeapMemoryUsage"]["used"]
                falcon_data.append(q)
                q = {}
                q.update(sam)
                q["Metric"] = "NonHeapMemoryUseRate"
                q["TAGS"] = "service=%s" % (jvm["service"])
                q["Value"] = b["NonHeapMemoryUsage"]["used"] / float(b["NonHeapMemoryUsage"]["max"]) * 100
                falcon_data.append(q)
        elif re.match("^java.lang:type=ClassLoading", b["name"]):
            q = {}
            q.update(sam)
            q["Metric"] = "LoadedClassCount"
            q["TAGS"] = "service=%s" % (jvm["service"])
            q["Value"] = b["LoadedClassCount"]
            falcon_data.append(q)
            q = {}
            q.update(sam)
            q["Metric"] = "UnloadedClassCount"
            q["TAGS"] = "service=%s" % (jvm["service"])
            q["Value"] = b["UnloadedClassCount"]
            falcon_data.append(q)
            q = {}
            q.update(sam)
            q["Metric"] = "TotalLoadedClassCount"
            q["TAGS"] = "service=%s" % (jvm["service"])
            q["Value"] = b["TotalLoadedClassCount"]
            falcon_data.append(q)
        elif re.match("^java.lang:type=Threading", b["name"]):
            q = {}
            q.update(sam)
            q["Metric"] = "DaemonThreadCount"
            q["TAGS"] = "service=%s" % (jvm["service"])
            q["Value"] = b["DaemonThreadCount"]
            falcon_data.append(q)
            q = {}
            q.update(sam)
            q["Metric"] = "PeakThreadCount"
            q["TAGS"] = "service=%s" % (jvm["service"])
            q["Value"] = b["PeakThreadCount"]
            falcon_data.append(q)
            q = {}
            q.update(sam)
            q["Metric"] = "ThreadCount"
            q["TAGS"] = "service=%s" % (jvm["service"])
            q["Value"] = b["ThreadCount"]
            falcon_data.append(q)
            q = {}
            q.update(sam)
            q["Metric"] = "TotalStartedThreadCount"
            q["TAGS"] = "service=%s" % (jvm["service"])
            q["Value"] = b["TotalStartedThreadCount"]
            falcon_data.append(q)
        elif re.match("^java.lang:type=OperatingSystem", b["name"]):
            q = {}
            q.update(sam)
            q["Metric"] = "OpenFileDescriptorCount"
            q["TAGS"] = "service=%s" % (jvm["service"])
            q["Value"] = b["OpenFileDescriptorCount"]
            falcon_data.append(q)
        elif re.match("^java.lang:type=GarbageCollector", b["name"]):
            gctype = re.findall("name=(.*)$", b["name"])
            if gctype == None or len(gctype) <= 0:
                continue
            gctype = gctype[0]
            gctype = gctype.replace(" ", "-")
            q = {}
            q.update(sam)
            q["Metric"] = "CollectionCount"
            q["TAGS"] = "service=%s,GCType=%s" % (jvm["service"], gctype)
            q["Value"] = b["CollectionCount"]
            q["CounterType"] = "COUNTER"
            falcon_data.append(q)
            q = {}
            q.update(sam)
            q["Metric"] = "CollectionTime"
            q["TAGS"] = "service=%s,GCType=%s" % (jvm["service"], gctype)
            q["Value"] = b["CollectionTime"]
            q["CounterType"] = "COUNTER"
            falcon_data.append(q)
            if not b.has_key("LastGcInfo") or b["LastGcInfo"] == None:
                continue
            q = {}
            q.update(sam)
            q["Metric"] = "GcThreadCount"
            q["TAGS"] = "service=%s,GCType=%s" % (jvm["service"], gctype)
            q["Value"] = b["LastGcInfo"]["GcThreadCount"]
            falcon_data.append(q)
            q = {}
            q.update(sam)
            q["Metric"] = "duration"
            q["TAGS"] = "service=%s,GCType=%s" % (jvm["service"], gctype)
            q["Value"] = b["LastGcInfo"]["duration"]
            falcon_data.append(q)
            for mem in b["LastGcInfo"]["memoryUsageAfterGc"]:
                gc_memtype = mem["key"].replace(" ", "-")
                q = {}
                q.update(sam)
                q["Metric"] = "memoryUsageAfterGc"
                q["TAGS"] = "service=%s,GCType=%s,MemoryType=%s" % (jvm["service"], gctype, gc_memtype)
                q["Value"] = mem["value"]["used"]
                falcon_data.append(q)
            for mem in b["LastGcInfo"]["memoryUsageBeforeGc"]:
                gc_memtype = mem["key"].replace(" ", "-")
                q = {}
                q.update(sam)
                q["Metric"] = "memoryUsageBeforeGc"
                q["TAGS"] = "service=%s,GCType=%s,MemoryType=%s" % (jvm["service"], gctype, gc_memtype)
                q["Value"] = mem["value"]["used"]
                falcon_data.append(q)

method = "POST"
handler = urllib2.HTTPHandler()
opener = urllib2.build_opener(handler)
url = 'http://127.0.0.1:8888/push'
request = urllib2.Request(url, data=json.dumps(falcon_data))
request.add_header("Content-Type",'application/json')
request.get_method = lambda: method
try:
    connection = opener.open(request)
except urllib2.HTTPError,e:
    connection = e

# check. Substitute with appropriate HTTP code.
if connection.code == 200:
    print connection.read()
else:
    print '{"err":1,"msg":"%s"}' % connection

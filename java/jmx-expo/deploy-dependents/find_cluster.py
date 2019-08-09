#!/bin/env python
import sys
#print(sys.argv)
def usage():
    print("find_cluster.py service.abc_cluster.staging [cluster/service/... | --gen-tags]")

if len(sys.argv) == 1:
    usage()
    sys.exit(-1)

tag_str = sys.argv[1]

tags_map = {"cop":"kali", "owt":"kalo", "pdl":"cash",
        "servicegroup":"default", 
        "jobgroup":"default","cluster":"staging"}

tags_order = ['job', 'jobgroup', 'service', 'servicegroup', 'cluster', 'pdl', 'owt', 'cop']

#parse the tag string
for tags in tag_str.split('_'):
    k, v = tags.split('.')
    tags_map[k] = v
#print(tags_map)

field = 'cluster'
if len(sys.argv) >=3:
    field = sys.argv[2]

if field == '--gen-tags':
    assert("service" in tags_map)
    assert("job" in tags_map)
    assert("cluster" in tags_map)
    tags_list = []
    for t in tags_order:
        if t == 'servicegroup' or t == 'jobgroup':
            if tags_map[t] == 'default': continue

        tags_list.append(t + "." + tags_map.get(t, 'default'))

    print("_".join(tags_list))
else:
    print(tags_map[field])

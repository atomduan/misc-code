#!/usr/bin/python
import base64
dict = {}

if __name__=='__main__':
    with open('./result.txt') as f:
        for line in iter(f):
            record = line.strip()
            if len(record) > 0:
                    params = record.split(' ')
                    s = int(params[2].strip())
                    id = params[0]
                    if id not in dict:
                        dict[id] = record
                    else:
                        r = dict[id]
                        ps = r.split(' ')
                        sc = int(ps[2].strip()) + s
                        r = str(ps[0])+' '+str(ps[1])+' '+str(sc)
                        dict[id] = r

    for k in dict:
        r = (dict[k])
        ps = r.split(' ')
        r = str(ps[0])+' '+str(base64.b64decode(ps[0]))+' '+str(ps[1])+' '+str(ps[2])
        print(r)

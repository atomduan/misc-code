#!/usr/bin/python

import sys
db_dict = {
    "app"            : 22,
    "bi_push"        : 23,
    "bi_view"        : 24,
    "dim"            : 25,
    "dm"             : 26,
    "dw"             : 27,
    "fso_dm"         : 28,
    "mart_carloan"   : 29,
    "mart_cityloan"  : 30,
    "mart_houseloan" : 31,
    "upload"         : 32,
}

fields = []
table_name = ''
table_dict = {}

def process(db_name, op):
    if op == 'table':
        print 'INSERT INTO data_table (db_id, name) VALUES ('+str(db_dict[db_name])+', \''+table_name+'\');'
    else:
        for f in fields:
            try:
                if len(f) == 3:
                    print 'INSERT INTO data_field (name, field_type, table_id, comments) VALUES (\''+str(f[0])+'\', \''+str(f[1])+'\', '+table_dict[table_name]+', \''+str(f[2])+'\');'
                else:
                    print 'INSERT INTO data_field (name, field_type, table_id) VALUES (\''+str(f[0])+'\', \''+str(f[1])+'\', '+table_dict[table_name]+');'
            except Exception:
                print f
                pass

if __name__=='__main__':
    dbname = sys.argv[1]
    op = sys.argv[2]
    d = open('./tables.dict')
    for t in d.readlines():
        t = ' '.join(t.split())
        ts = t.split()
        tbn = str(ts[0])
        tid = str(ts[1])
        table_dict[tbn] = tid
    f = open('/dev/stdin')
    for l in f.readlines():
        l = l.strip()
        l = ' '.join(l.split())
        if l == '----':
            process(dbname, op)
            fields = []
            table_name = ''
        else:
            if l.find('TT_tableName') >= 0:
                table_name = l.split(':')[1]
            else:
                ls = l.split(' ')
                fields.append(ls)

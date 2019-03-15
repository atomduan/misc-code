#!/bin/bash -

mysql --default-character-set=utf8 -h10.38.161.32 -umifi_admin -pmf123 -e 'use mip; show processlist;' | \
    grep payment | grep rw

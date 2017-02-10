#!/bin/bash -
curr_path=$(cd `dirname $(which $0)`; pwd)
kill $(ps -ef | grep 'dds_keep_alive/dds_keep_alive.sh' | grep -v grep | awk '{print $2}')

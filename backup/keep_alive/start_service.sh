#!/bin/bash -
curr_path=$(cd `dirname $(which $0)`; pwd)

log_path="${curr_path}/logs"
log_file="${log_path}/dds_keep_alive.log"

nohup ${curr_path}/dds_keep_alive.sh >> $log_file 2>&1 &

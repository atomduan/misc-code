#!/bin/bash -
#currentTime="`date +%s`000"
currentTime=`date +'%Y-%m-%d %H:%M:%S'`
echo "select  * from table_name where status = 1 and begin_time <= '$currentTime' and end_time >= '$currentTime' order by create_time desc;"

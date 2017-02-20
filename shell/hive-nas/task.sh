#!/bin/bash -
curr_path=$(cd `dirname $(which $0)`; pwd)
cd $curr_path
echo "========BEGIN ROUTINE `date`========="
export JAVA_HOME="/usr/local/java/jdk1.8.0_51"
perl ./wcc_exp.pl >> ./log/task.log 2>&1
echo "========FINISH ROUTINE `date`========="

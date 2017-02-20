#!/bin/bash -

task_name=$1
shift
if [ -z "${task_name}" ]; then
	echo "ERROR: task_name should not empty!"
	exit 1
fi

month=$1
shift
if [ -z "${month}" ]; then
	echo "ERROR: month should not empty!"
	exit 0
fi

# Topic to consume
topic=da_eva_fin

# Zookeeper home
zookeeper="10.21.131.3:2181/kafka/testing"

cmd="./kafka_client -P -k ${zookeeper} -t ${topic} -n ${task_name} -m ${month} -E"
echo $cmd
eval ${cmd}

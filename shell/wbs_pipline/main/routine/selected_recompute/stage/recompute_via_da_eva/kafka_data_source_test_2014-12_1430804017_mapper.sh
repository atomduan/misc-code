#!/bin/bash -
# kafka_data_source.sh
# produce kafka messages of weibo items from hadoop streaming
# yanging5
# 2015-04-27
#

#current_path=$(cd `dirname $(which $0)`; pwd)

#key=$1
#shift

#if [ -z "${key}" ]; then
#	key="default_key"
#	echo "WARN: no key given, default one will be given!!!"
#fi

# Topic to consume
topic=da_eva_fin

# Zookeeper home
zookeeper="10.21.131.3:2181/kafka/testing"

cmd="cat < /dev/stdin | ./kafka_client -P -k ${zookeeper} -t ${topic} -n test -m 2014-12"
echo $cmd
eval ${cmd}

#!/bin/bash -
#

current_path=$(cd `dirname $(which $0)`; pwd)

if [ $# != 2 ]; then
cat << EOF
Usage: $0 <task_name> <month>
EOF
	exit 1
fi

task_name=$1
shift
month=$1
shift
mapper_script_file_name=""

if [ -n "${task_name}" ] && [ -n "${month}" ]; then
	cur_time=`date +%s`
	mapper_script_file_name=kafka_data_source_${task_name}_${month}_${cur_time}_mapper.sh
    cat ${current_path}/kafka_data_source.template | \
        sed -r "s/\\$\{task_name\}/${task_name}/g" | \
        sed -r "s/\\$\{month\}/${month}/g" > ${current_path}/${mapper_script_file_name}
    chmod +x ${mapper_script_file_name}
else
	echo "[ERROR] no key given"
	exit 1
fi



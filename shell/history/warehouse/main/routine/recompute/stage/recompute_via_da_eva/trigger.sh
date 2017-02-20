#!/bin/bash -

project_home=/data1/warehouse
source ${project_home}/main/env.sh
source ${project_home}/main/util.sh
current_path=$(cd `dirname $(which $0)`; pwd)
stage_home=$(cd ${current_path}; cd ../.; pwd)

task_name="$1"
shift 1
if [ -z "${task_name}" ]; then
	echo "[${current_path}]: task_name can not be EMPTY! exit."
	exit 1
fi

month="$1"
shift 1
if [ -z "${month}" ]; then
    echo "[${current_path}]: month can not be EMPTY! exit."
    exit 1
fi
source ${stage_home}/stage.ini "${task_name}" "${month}"


cmd="(cd ${current_path}; ${current_path}/map_job_emit.sh ${task_name} ${month})"
r_log "${cmd}"
eval ${cmd}

cmd="(cd ${current_path}; ${current_path}/task_end_message.sh ${task_name} ${month})"
r_log "${cmd}"
eval ${cmd}

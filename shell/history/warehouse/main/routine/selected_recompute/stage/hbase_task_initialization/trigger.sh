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

cmd="${BCMD_HADOOP} fs -mkdir -p ${HDFS_RECOMPUTE_TASK_BASE_HOME}"
r_log "${cmd}"
eval ${cmd}

cmd="${BCMD_HADOOP} fs -chmod 777 ${HDFS_RECOMPUTE_TASK_BASE_HOME}"
r_log "${cmd}"
eval ${cmd}


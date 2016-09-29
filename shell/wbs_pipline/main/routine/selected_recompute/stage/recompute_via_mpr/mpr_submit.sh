#!/bin/bash -
project_home=/data1/warehouse
source ${project_home}/main/cluster.ini ${project_home}
current_path=$(cd `dirname $(which $0)`; pwd)
stage_home=$(cd ${current_path}; cd ../.; pwd)

task_name="$1"
shift 1

time_tag="$1"
shift

if [ -z "${task_name}" ]; then
	echo "[${current_path}]: task_name can not be EMPTY! exit."
	exit 1
fi
source ${stage_home}/stage.ini "${task_name}"

BCMD_HADOOP="${SH_CDH4}/bin-mapreduce1/hadoop"

########################  ONE  TASK  DEFINITION  #############################

job_type="EVENT" #for example EVENT task.
job_name=HISTORY_RECOMPUTE_VIA_MPR_${job_type}

start_time="${time_tag}-01"
end_time="${time_tag}-31"

project_prefix="${ST_RECOMPUTE_VIA_MPR}/${job_type}"
resource_hdfs_path=/tmp/bar/foo.tar
cleanup_wait_second=30

_SEP_="@_@"
task_name="ShCdh4HBaseServiceEmbedTask"
hadoop_payload="${start_time}$_SEP_${end_time}$_SEP_${project_prefix}"
hadoop_payload="${hadoop_payload}$_SEP_${resource_hdfs_path}$_SEP_${job_name}"
hadoop_payload="${hadoop_payload}$_SEP_${cleanup_wait_second}"

hadoop_opts="-submitByName ${task_name}"

if [ -n "${hadoop_reduce_num:-}" ]; then
    hadoop_opts="${hadoop_opts} -reducerNum ${hadoop_reduce_num}"
fi

if [ -n "${hadoop_payload:-}" ]; then
    hadoop_opts="${hadoop_opts} -payLoad ${hadoop_payload}"
fi

cmd="${BCMD_HADOOP} jar ${CLIENT_JAR} $hadoop_opts"
echo ${cmd}
eval ${cmd}
##############################################################################


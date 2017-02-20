#!/bin/bash -

project_home=/data1/warehouse
source ${project_home}/main/env.sh
source ${project_home}/main/util.sh
current_path=$(cd `dirname $(which $0)`; pwd)
stage_home=$(cd ${current_path}; cd ../.; pwd)

task_name="$1"
shift
month="$1"
shift

if [ -z "${task_name}" ]; then
	r_log "ERROR: task_name should not empty!"
	exit 1
fi

if [ -z "${month}" ]; then
	r_log "ERROR: month should not empty!"
	exit 1
fi

source ${stage_home}/stage.ini "${task_name}" "${month}"

function task_check_exist() {
	cmd="${BCMD_HADOOP} fs -ls ${HBASE_HISTORY_IMAGE_TARGET}/${task_name} 2>/dev/null | grep ${HBASE_HISTORY_IMAGE_TASK_HOME}"
	ls_result=`eval ${cmd}`
	if echo "${ls_result}" | grep "${HBASE_HISTORY_IMAGE_TASK_HOME}" > /dev/null; then
		msg="[hbase_task_initialization]:Related task name [${task_name}] has been already"
		msg="${msg} existed under hdfs:${HBASE_HISTORY_IMAGE_TARGET}/"
		r_log "${msg}"
		exit 1
	fi	
}

task_check_exist

#Init stage target
cmd="${BCMD_HADOOP} fs -mkdir -p ${HBASE_HISTORY_IMAGE_TASK_HOME}"
r_log "${cmd}"
eval ${cmd}

function do_one_routine() {
	#Config mpr payload
	task_class="ShCdh4HbaseExportTask"
	start_time="$1"
	shift
	end_time="$1"
	shift

	if [ -n "${start_time}" ] && [ -n "${end_time}" ]; then
		shard_dir="${start_time}_${end_time}"
		output_path="${HBASE_HISTORY_IMAGE_TASK_HOME}"
		_SEP_="@_@"
		hadoop_payload="${start_time}$_SEP_${end_time}$_SEP_${output_path}"
		hadoop_opts="-submitByName ${task_class}"
		hadoop_opts="${hadoop_opts} -payLoad ${hadoop_payload}"
	
		#Run mpr job
		jar_path=${current_path}/mapreduce-client.jar
		cmd="${BCMD_HADOOP} jar ${jar_path} ${hadoop_opts} 2>&1 | grep -v 'DNS name not found'"
		r_log "${cmd}"
		eval ${cmd}
	else
		r_log "ERROR: start_name or end_time should not empty!"
		exit 1
	fi
}

start_time="${month}-01"
last_month_first_day=`date -d "${start_time} +1 month" +%Y-%m-01`
end_time=`date -d "${last_month_first_day} -1 day" +%Y-%m-%d`
do_one_routine ${start_time} ${end_time}

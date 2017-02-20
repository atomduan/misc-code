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

start_time="${month}-01"
last_month_first_day=`date -d "${start_time} +1 month" +%Y-%m-01`
end_time=`date -d "${last_month_first_day} -1 day" +%Y-%m-%d`

#Init stage target
cmd="${BCMD_HADOOP} fs -mkdir -p ${ST_HBASE_EXPORT_FIELDS_COMPARE_SNAPSHOT}"
r_log "${cmd}"
eval ${cmd}

shard_dir="${start_time}_${end_time}"
output_path="${ST_HBASE_EXPORT_FIELDS_COMPARE_SNAPSHOT}/datas/${shard_dir}"

#Config mpr payload
task_class="ShCdh4HbaseFieldsSnapshot"
	
_SEP_="@_@"
hadoop_payload="${input_path}$_SEP_${output_path}"
hadoop_opts="-submitByName ${task_class}"
hadoop_opts="${hadoop_opts} -payLoad ${hadoop_payload}"

#Run mpr job
jar_path=${current_path}/mapreduce-client.jar
cmd="${BCMD_HADOOP} jar ${jar_path} ${hadoop_opts} 2>&1 | grep -v 'DNS name not found'"
r_log "${cmd}"
eval ${cmd}

#Mark mpr job complete
cmd="${BCMD_HADOOP} fs -touchz ${ST_HBASE_EXPORT_FIELDS_COMPARE_SNAPSHOT}/_COMPLETE"
r_log "${cmd}"
eval ${cmd}

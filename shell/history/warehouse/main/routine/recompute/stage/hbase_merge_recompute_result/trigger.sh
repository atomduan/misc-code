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
shift
if [ -z "${month}" ]; then
	echo "[${current_path}]: month can not be EMPTY! exit."
	exit 1
fi

source ${stage_home}/stage.ini "${task_name}" "${month}"

#Init stage target
cmd="${BCMD_HADOOP} fs -mkdir -p ${ST_HBASE_MERGE_RECOMPUTE_RESULT}"
r_log "${cmd}"
eval ${cmd}

task_class="ShCdh4HbaseMergeResult"
fan_in=${ST_TRANS_BACK_OUTTER_RESULT}
fan_in="${fan_in},${ST_RECOMPUTE_VIA_MPR}"
fan_in="${fan_in},${ST_HBASE_EXPORT_FIELDS_COMPARE_SNAPSHOT}"
merge_qi_valid=${MERGE_QI_VALID}
output_path=${ST_HBASE_MERGE_RECOMPUTE_RESULT}/merged_result
reducer_num=600
_SEP_="@_@"
hadoop_payload="${fan_in}$_SEP_${merge_qi_valid}$_SEP_${output_path}"
hadoop_opts="-submitByName ${task_class} -reducerNum ${reducer_num}"
hadoop_opts="${hadoop_opts} -payLoad ${hadoop_payload}"

#Run mpr job
jar_path=${current_path}/mapreduce-client.jar
cmd="${BCMD_HADOOP} jar ${jar_path} ${hadoop_opts} 2>&1 | grep -v 'DNS name not found'"
r_log "${cmd}"
eval ${cmd}

#Mark mpr job complete
cmd="${BCMD_HADOOP} fs -touchz ${ST_HBASE_MERGE_RECOMPUTE_RESULT}/_COMPLETE"
r_log "${cmd}"
eval ${cmd}


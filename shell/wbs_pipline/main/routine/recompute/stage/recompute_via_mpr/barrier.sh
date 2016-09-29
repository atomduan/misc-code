#!/bin/bash -

stage_name=recompute_via_mpr
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

#0->true, 1->false
function is_stage_completed() {
	completed=0
	cmd="${BCMD_HADOOP} fs -ls ${ST_RECOMPUTE_VIA_MPR} 2>&1"
	r_log "[recompute_via_mpr_barrier_command] ${cmd}"
	result=$(eval ${cmd})
	if ! echo ${result} | grep -o _COMPLETE > /dev/null; then
		msg="[recompute_via_mpr_barrier_command]"
		msg="${msg} Complete condition not met yet."
		msg="${msg} Barrier until '_COMPLETE' file found under hdfs:${ST_RECOMPUTE_VIA_MPR}/"
		r_log "${msg}"
		completed=1
	fi
	return ${completed}
}

check_interval=3
while ! is_stage_completed 
do
	sleep ${check_interval}
done
r_log "[recompute_via_mpr_barrier_command] Complete condition is met. Pass this barrier."


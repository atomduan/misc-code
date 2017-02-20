#!/bin/bash -

project_home=/data1/warehouse
source ${project_home}/main/env.sh
source ${project_home}/main/util.sh
current_path=$(cd `dirname $(which $0)`; pwd)
stage_home=$(cd ${current_path}; cd ../stage; pwd)

# check arguments
if [ "$#" -lt 2 ]; then
	cat <<EOF
invalid params number.
	$0 <task_name> <month> 
	<tag>			used for identify the current recompute routine.
	<month>		used to specify the month to recompute, format"+%Y-%m"
EOF
	exit 1
fi

task_name="$1"
shift
month="$1"
shift

echo "task_name: [${task_name}, ${month}]"
source ${stage_home}/stage.ini "${task_name}" "${month}"

function barrier() {
	task_name="$1"
	shift
	month="$1"
	shift
	stage_name="$1"
	shift

	if [ -n "${task_name}" ] && [ -n "${month}" ] && [ -n "${stage_name}" ]; then
		cmd="${stage_home}/${stage_name}/barrier.sh ${task_name} ${month}"
		r_log "${cmd}"
		eval ${cmd}
	else
		r_log "ERROR: stage_name, task_name or month should not empty!"
        exit 1
	fi
}

function trigger() {
	task_name="$1"
	shift
	month="$1"
	shift
	stage_name="$1"
	shift

	if [ -n "${task_name}" ] && [ -n "${month}" ] && [ -n "${stage_name}" ]; then
		cmd="${stage_home}/${stage_name}/trigger.sh ${task_name} ${month}"
		r_log "${cmd}"
		eval ${cmd}
	else
		r_log "ERROR: stage_name, task_name or month should not empty!"
		exit 1
	fi
}

function trigger_routine() {
	task_name="$1"
	shift
	month="$1"
	shift
	task_existence_check
	if [ -n "${task_name}" ] &&  [ -n "${month}" ]; then
		trigger "${task_name}" "${month}" "hbase_task_initialization"
		trigger "${task_name}" "${month}" "hbase_export_fields_compare_snapshot" &
		trigger "${task_name}" "${month}" "recompute_via_mpr" &
		trigger "${task_name}" "${month}" "recompute_via_da_eva" &
		
		barrier "${task_name}" "${month}" "recompute_via_mpr"		
		barrier "${task_name}" "${month}" "hbase_export_fields_compare_snapshot"
		barrier "${task_name}" "${month}" "recompute_via_da_eva"

		trigger "${task_name}" "${month}" "hbase_merge_recompute_result"
	else
		r_log "ERROR: task_name or month should not empty!"
        exit 1
	fi
}

trigger_routine "${task_name}" "${month}"

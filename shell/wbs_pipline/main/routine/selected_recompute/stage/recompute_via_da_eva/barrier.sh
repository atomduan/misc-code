#!/bin/bash -i

stage_name=recompute_via_da_eva
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

# unit: seconds
COMPLETE_TIME_INTERVAL=300

target_path="${ST_TRANS_BACK_OUTTER_RESULT}"
last_count=0
last_time_stamp=`date +%s`

#0->true, 1->false
function is_completed() {
	completed=1

	cmd="${BCMD_HADOOP} fs -ls ${target_path} 2>&1"
	r_log "[${stage_name}_barrier_command] ${cmd}"

	count=echo $(eval ${cmd}) | grep -E 'Found [0-9]+ items' | awk '{print $2}'
	if ${count}; then
		cur_time=`date +%s`
		if [ "${count}" != "${last_count}" ]; then
			last_time_stamp=${cur_time}
			last_count=${count}
		else
			time_interval=$(($cur_time - $last_time_stamp))
			if [ ${time_interval} -ge ${COMPLETE_TIME_INTERVAL} ]; then
				completed=0
			fi
		fi
	fi
		
	return ${completed}
}

check_interval=10
while ! is_completed 
do
	sleep ${check_interval}
done
r_log "[${stage_name}_barrier]: Barrier condition is met. Pass this barrier."


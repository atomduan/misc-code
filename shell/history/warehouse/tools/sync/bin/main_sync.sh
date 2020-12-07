#! /bin/bash -
current_path=$(cd `dirname $(which $0)`; pwd)
project_home=$(cd $current_path; cd ..; pwd)
source ${project_home}/cluster.ini ${project_home}

#PATH INITIALIZATION
current_script_path=${current_path}/`basename $0`
current_script_magic='c362a8c67daf1790dd987f7808038174'

#LOG PATH INITIALIZATION
if [ -n "${LOG_HOME}" ]; then
	if ! [ -d "${LOG_HOME}" ]; then
		mkdir -p ${LOG_HOME}
	fi
fi
main_sync_update_log="${LOG_HOME}/main_sync_update_info.log"

#SERVER CONFIG INITIALIZATION
server_arr_G=()
server_arr_size_G=0


function main_sync_update_sync_log() {
	echo `date +'%Y/%m/%d %H:%M:%S'` > ${main_sync_update_log}
}


function main_sync_initialize() {
	#INITIALIZE DEPLOY_LIST ARRAY
	index=0
	for ipaddr in ${DEPLOY_LIST}
	do
		server_arr_G[index]=${ipaddr}
		index=$(( ${index} + 1 ))	
	done
	server_arr_size_G=${index}
}


function main_sync_target_server() {
	address=$@
	if [ -n "${address}" ]; then
		#Deploy control resource sync
		if [ -n "${MAIN_HOME}" ]; then
			#Test whether the target dir exsit.
			cmd="ssh -nt ${address} 'if ! [ -d ${MAIN_HOME} ]; then mkdir -p ${MAIN_HOME}; fi'"
			echo ${cmd}
			eval ${cmd}
			#Main resource synchronization
			cmd="rsync -a -l -e ssh --delete --exclude 'log' --exclude '.git' ${MAIN_HOME}/ ${address}:${MAIN_HOME}"
			echo ${cmd}
			eval ${cmd}
		fi
		 #KAFKA cluster resouce sync
		if [ -n "${KAFKA_RESOURCE}" ]; then
			#Test whether the target dir exsit.
			cmd="ssh -nt ${address} 'if ! [ -d ${KAFKA_RESOURCE} ]; then mkdir -p ${KAFKA_RESOURCE}; fi'"
			echo ${cmd}
			eval ${cmd}
			#Main resource synchronization
			cmd="rsync -a -l -e ssh --delete --exclude 'log' --exclude 'logs' \
				--exclude 'data' --exclude '.git' --exclude 'tmp' --exclude 'pids' \
				--exclude 'server.properties' \
				${KAFKA_RESOURCE}/ ${address}:${KAFKA_RESOURCE}"
			echo ${cmd}
			eval ${cmd}
		fi
		#STATIC_CACHE cluster resouce sync
		if [ -n "${STATIC_CACHE_RESOURCE}" ]; then
			#Main resource synchronization
			cmd="rsync -a -l -e ssh --delete --exclude 'log' --exclude 'logs' \
				--exclude 'data' --exclude '.git' --exclude 'tmp' --exclude 'pids' \
				${STATIC_CACHE_RESOURCE}/ ${address}:${STATIC_CACHE_RESOURCE}"
			echo ${cmd}
			eval ${cmd}
		fi
                # DA_EVA cluster resource sync
		if [ -n "${DA_EVA_RESOURCE}" ]; then
                        #Main resource synchronization
                        cmd="rsync -a -l -e ssh --delete --exclude 'log' --exclude 'logs' \
                                --exclude '.git' --exclude 'tmp' --exclude 'pids' \
                                ${DA_EVA_RESOURCE}/ ${address}:${DA_EVA_RESOURCE}"
                        echo ${cmd}
                        eval ${cmd}
                fi

		# DATA_SINK cluster resource sync
                if [ -n "${DATA_SINK_RESOURCE}" ]; then
                        #Main resource synchronization
                        cmd="rsync -a -l -e ssh --delete --exclude 'log' --exclude 'logs' \
                                --exclude '.git' --exclude 'tmp' --exclude 'pids' \
                                ${DATA_SINK_RESOURCE}/ ${address}:${DATA_SINK_RESOURCE}"
                        echo ${cmd}
                        eval ${cmd}
                fi
		echo "rsync to child ${address} finished......"
	fi
}


function main_sync_child_server_logic() {
	child_index=$@
	if [ -n "${child_index}" ] && [ ${server_arr_size_G} -gt ${child_index} ]; then
		child_address=${server_arr_G[child_index]}
		if [ -n "${child_address}" ]; then
			main_sync_target_server ${child_address}
			#CALL CHILD ROUTINE RECURSIVELY
			if [ 0 -eq "$?" ]; then
				ssh -n ${child_address} ${current_script_path} ${current_script_magic} ${child_index}
			fi
		fi
	fi
}


function main_sync_child_server() {
	child_index=$@
	if [ -n "${child_index}" ]; then
		#THE LOGIC MUST PARALLELISIME HERE
		main_sync_child_server_logic ${child_index} &
	fi	
}


function main_sync_recursive_routine() {
	main_sync_update_sync_log
	#DO CURRENT SERVER SYNC ROUTINE
	curr_server_index=$1
	shift
	if [ -n "${curr_server_index}" ]; then
		child_server_index_L=$(( ${curr_server_index}*2 + 1 ))
		child_server_index_R=$(( ${curr_server_index}*2 + 2 ))
		#CALL CURRENT SERVER CHILD RECURSIVELY
		main_sync_child_server ${child_server_index_L}
		main_sync_child_server ${child_server_index_R}
	fi
}


function main_sync_routine_check() {
	athead=0
	begin=0
	completed=0
	for addr in ${DEPLOY_LIST};
	do
		echo ${addr} "-------------------------------------------------------"
		count=0
		while read line
		do
			echo ${line}
			if [ ${count} -eq 0 ]; then
				timestamp=$(date -d "${line}" +%s)
				if [ ${athead} -eq 0 ]; then
					begin=${timestamp}
				else
					if [ ${timestamp} -lt ${begin} ]; then
						echo "${addr} NOT FINISHED...............${begin}"
						completed=1
					fi
				fi
			fi
			count=$(( ${count} + 1 ))
		done < <(ssh -n ${addr} "cat ${main_sync_update_log}")
		athead=1
	done
	if ! [ ${completed} -eq 0 ]; then
		echo "ROUTINE HAS *NOT* FINISHED"
	else
		echo "ROUTINE FINISHED"
	fi
}


function main_sync_linear_mode() {
	for addr in ${DEPLOY_LIST};
	do
		echo ${addr} "-------------------------------------------------------"
		main_sync_target_server ${addr}
		if [ 0 -eq "$?" ]; then
			ssh -n ${addr} "${current_script_path} touch"
		fi
	done
}


function main_sync_flow_control() {
	main_sync_initialize
	curr_cmd=$1
	shift
	case "${curr_cmd}" in
		"${current_script_magic}")
			curr_server_index=$1
			shift
			main_sync_recursive_routine ${curr_server_index} >> ${main_sync_update_log} 2>&1
			;;
		"touch")
			main_sync_update_sync_log
			;;
		"check")
			main_sync_routine_check
			;;
		"recursive")
			server_header_index=0
			main_sync_child_server ${server_header_index} > /dev/null 2>&1
			echo "Invoke finished: use 'check' command to monitor..."
			;;
		"linear")
			main_sync_linear_mode
			;;
		*)
			echo "command: recursive | linear | check"
			;;
	esac
}

main_sync_flow_control "$@"
exit 0

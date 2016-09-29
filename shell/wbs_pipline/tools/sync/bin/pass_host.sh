#! /bin/bash -
current_path=$(cd `dirname $(which $0)`; pwd)
project_home=$(cd $current_path; cd ..; pwd)
source ${project_home}/cluster.ini ${project_home}

function do_host_pass() {
        list="$@"
        for addr in ${list}
        do
		echo ${addr} "-----------------------------------------------------------------------------"
		sleep 1
                ssh -n -o StrictHostKeyChecking=no ${addr} java -version 2>&1
        done
}

do_host_pass ${HOST_PASS_LIST}

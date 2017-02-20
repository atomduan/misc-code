#! /bin/bash -
current_path=$(cd `dirname $(which $0)`; pwd)
project_home=$(cd $current_path; cd ..; pwd)
source ${project_home}/cluster.ini ${project_home}

cmd="$@"

if [ -n "${cmd}" ]; then
	for addr in ${DEPLOY_LIST};
	do
		echo ${addr} "-----------------------------------------------------------------------------"
		ssh -nt ${addr} "${cmd}"
	done
else
	echo "command can not be empty..."
fi

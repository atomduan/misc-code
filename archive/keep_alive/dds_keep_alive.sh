#!/bin/bash -
curr_path=$(cd `dirname $(which $0)`; pwd)

log_path="${curr_path}/logs"

function loop_check() {
	while read f; 
	do
		bn=`basename $f`
		log_file="${log_path}/${bn%\.*}.log"
		/bin/bash $f >> $log_file
	done< <(find ${curr_path}/keep_alive -type f -name "*.sh")
}

echo "$(date): keep_alive service started..."
while true;
do
	sleep 1
	loop_check
done

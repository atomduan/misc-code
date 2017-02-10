#!/bin/bash -

function is_alive() {
	count=$(ps -ef | grep python | grep -v grep | grep 'Ddataplate' | wc -l)
	if [ $count -gt 1 ]; then
		return 0	
	else
		return 1
	fi
}

if ! is_alive; then
	echo "$(date) , dds_meta service seems dead, we need restart it......"
	cd /var/yx/svr/dds_meta/dataplatform
	./stop.sh
	./start.sh
fi

#!/bin/bash -

function is_alive() {
	count=$(ps -ef | grep python | grep -v grep | grep 'Dcas' | wc -l)
	if [ $count -gt 1 ]; then
		return 0	
	else
		return 1
	fi
}

if ! is_alive; then
	echo "$(date) , dds_cas service seems dead, we need restart it......"
	cd /var/yx/svr/dds_cas/cas_server
	./stop.sh
	./start.sh
fi

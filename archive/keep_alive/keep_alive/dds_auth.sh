#!/bin/bash -

function is_alive() {
	count=$(ps -ef | grep python | grep -v grep | grep 'Dauth-cas' | wc -l)
	if [ $count -gt 1 ]; then
		return 0	
	else
		return 1
	fi
}

if ! is_alive; then
	echo "$(date) , dds_auth service seems dead, we need restart it......"
	cd /var/yx/svr/dds_auth/auth-sysd	
	./stop.sh
	./cas_start.sh
fi

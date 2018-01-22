#!/bin/bash -

function is_alive() {
	count=$(ps -ef | grep java | grep -v grep | grep 'dds_report_form' | grep 'org.apache.catalina.startup.Bootstrap start' | wc -l)
	if [ $count -gt 0 ]; then
		return 0	
	else
		return 1
	fi
}

if ! is_alive; then
	echo "$(date) , dds_report_form service seems dead, we need restart it......"
	cd /var/yx/svr/dds_report_form/bin
	./startup.sh
fi

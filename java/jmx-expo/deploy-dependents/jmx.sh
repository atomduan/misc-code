#!/bin/bash -x
while true; do
	pushd /home/kali/tmp/deploy-dependents/jmxmonitor/release/libexec/jmxmonitor/bin
	/usr/bin/python jmxmonitor.py --host kn-g-vm-staging-kali --port 6471 yan
	popd
	sleep 30
done

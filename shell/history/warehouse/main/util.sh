#!/bin/bash -
# offline recompute project utility
# yangming5, 2015-04-30
#

# simple log helper
function r_log() {
        msg="$@"
        shift
        log_date=`date +'%Y-%m-%d_%H:%M:%S'`
        CURR_HOST=`hostname -i`
        echo "[${log_date}@${CURR_HOST}][$0]:${msg}"
}

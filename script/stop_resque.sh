#!/bin/bash
#
# Stops the resque-pool
# script/stop_resque.sh

RESQUE_POOL_PIDFILE="/opt/druw/tmp/pids/resque-pool.pid"

function anywait {
    for pid in "$@"; do
        while kill -0 "$pid" > /dev/null 2>&1; do
            sleep 0.5
        done
    done
    return 0
}

[ -f $RESQUE_POOL_PIDFILE ] && {	
    PID=$(cat $RESQUE_POOL_PIDFILE)
    kill -2 $PID && anywait $PID
}


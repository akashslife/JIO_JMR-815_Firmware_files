#!/bin/sh

relaySocat=$1
relayMessage=$2

if [ $# -ne 2 ]; then
    exit 1
fi

while [ 1 ]
do
    # If pipe exist 
    if [ -p "/tmp/log_out" ]; then
      echo $relayMessage > /dev/kmsg
      socat $relaySocat
    fi
    sleep 1
done

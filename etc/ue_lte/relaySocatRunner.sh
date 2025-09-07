#!/bin/sh

exeRelay() {
	echo $relayMessage > /dev/kmsg
	while [ 1 ]
	do
        sleep 1
	    socat $relaySocat
	done
}

relaySocat=$1
relayMessage=$2

if [ $# -ne 2 ]; then
    exit 1
fi

exeRelay &

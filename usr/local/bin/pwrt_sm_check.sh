#!/bin/sh

PID=`pidof pwrt_sm|wc -l`
while [ 1 ]; do

	if [ -f /tmp/led_test ];then

	sleep 600

	fi

	PID=`pidof pwrt_sm|wc -l`


	if [ $PID -ne 1 ];then
		
		/usr/bin/pwrt_sm RTL &

		echo "[WARNNIG] pwrt_sm restarted" >/dev/kmsg

	fi

	sleep $1
	

done

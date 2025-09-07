#!/bin/sh

#REPORT_DIR=/tmp/mem_report


while read pid; do
	echo "statm: $(cat /proc/$pid/statm)" > $REPORT_DIR/pid_$pid.txt
	cat /proc/$pid/status >> $REPORT_DIR/pid_$pid.txt
	cat /proc/$pid/maps >> $REPORT_DIR/pid_$pid.txt

        mkdir $LOC_SMEMCAP/$pid
        cp /proc/$pid/cmdline $LOC_SMEMCAP/$pid     
        cp /proc/$pid/smaps $LOC_SMEMCAP/$pid     
        cp /proc/$pid/stat $LOC_SMEMCAP/$pid     
done;



#!/bin/sh

relaySocat=$1
relayMessage=$2

if [ $# -ne 2 ]; then
    exit 1
fi
LOG_DEVICE=/dev/ueservice0
if [ ! -e $LOG_DEVICE ]; then
   echo "ERROR: ($0) didnt find $LOG_DEVICE - bailing out" > /dev/kmsg
   exit 0;
fi
while [ 1 ]
do
    # If pipes exist 
    if [ -p "/tmp/console_in" ] && [ -p "/tmp/console_out" ]; then
      echo $relayMessage > /dev/kmsg
      socat $relaySocat
    fi
    sleep 1
done

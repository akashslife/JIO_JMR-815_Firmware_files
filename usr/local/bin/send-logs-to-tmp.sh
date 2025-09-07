#!/bin/sh

thisShellScript="send-logs-to-tmp"
currentPid=$$

echo ">>> Sending LTE FW logs to /tmp >>>" > /dev/kmsg

# Transition between internal and external mode requires reboot
exeRelayToTmp() {
    while [ 1 ]
    do
       socat -b1450 -u /dev/ueservice0 OPEN:/tmp/ModemLog/ModemFW.bin,creat,append
       echo ">>> Local save of LTE FW logs failed (too many logs) flushing /tmp/ModemLogs ! >>>" > /dev/kmsg
       rm -rf /tmp/ModemLog/*
       sleep 1
    done
}
LOG_DEVICE=/dev/ueservice0
if [ ! -e $LOG_DEVICE ]; then
   echo "ERROR: ($0) didnt find $LOG_DEVICE - bailing out" > /dev/kmsg
   exit 0;
fi

if grep -q "nomodem" /proc/cmdline ; then
    echo ">>> Stop sending LTE FW logs to /tmp in nomodem mode >>>" > /dev/kmsg
else
    exeRelayToTmp &
fi


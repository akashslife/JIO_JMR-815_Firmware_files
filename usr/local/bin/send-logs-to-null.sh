#!/bin/sh

thisShellScript="send-logs-to-null"
currentPid=$$

echo ">>> Sending LTE FW logs to /dev/null >>>" > /dev/kmsg

exeRelayToTmp() {
    while [ 1 ]
    do
       socat -b1450 -u /dev/ueservice0 OPEN:/dev/null,append

       echo ">>> Local save of LTE FW logs to /dev/null failed >>>" > /dev/kmsg
       sleep 1
    done
}

if grep -q "nomodem" /proc/cmdline ; then
    echo ">>> Stop sending LTE FW logs to /dev/null in nomodem mode >>>" > /dev/kmsg
else
    exeRelayToTmp &
fi

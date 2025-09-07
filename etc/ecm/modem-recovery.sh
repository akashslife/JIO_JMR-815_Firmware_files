#!/bin/sh
#
# modem recovery
#

REBOOT=`uci get ecm.ModemRecovery.EnableReboot`
COLLECT_LOGS=`uci get ecm.ModemRecovery.CollectLogs`

if [ "$COLLECT_LOGS" = "true" ]; then
	collect-logs.sh
fi

if [ "$REBOOT" = "true" ]; then
	reboot
fi


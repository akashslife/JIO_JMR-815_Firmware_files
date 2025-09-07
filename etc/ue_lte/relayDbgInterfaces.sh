#!/bin/sh

econsole_enable=`uci -q get /etc/config/lte-gw.econsole.econsole_enable`
STREAMER_SCRIPT="/etc/ue_lte/relayDbgStreamer.sh"

# If you are using the consold deamon
if [ "$econsole_enable" == "enable" ]; then
  LOGS_SCRIPT="/etc/ue_lte/relayFwLogs.sh"
  CONSOLE_SCRIPT="/etc/ue_lte/relayFwConsole.sh"
else
  LOGS_SCRIPT="/etc/ue_lte/relayFwLogsAndConsole.sh"
  CONSOLE_SCRIPT=""
fi
# script <start/stop> <IPADDR>

#---- Logs -----
$LOGS_SCRIPT $1 $2

#---- Console -----
$CONSOLE_SCRIPT $1 $2

#---- Debug Streamer -----
$STREAMER_SCRIPT $1 $2

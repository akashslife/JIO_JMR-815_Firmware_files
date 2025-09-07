#!/bin/sh
res=""
if [ -e /etc/config/reason_start ]
then
 res=$(cat /etc/config/reason_start)
 rm /etc/config/reason_start
else
 res="unknown"
fi

uci set /etc/config/web_info.info.reason="$res"
uci commit /etc/config/web_info

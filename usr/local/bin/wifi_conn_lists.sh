#!/bin/sh

#temporary file
filename=/tmp/conn_cnts

wifi_sec=`uci get /etc/config/wifi.wifi.sec_encryption`

#print hw and expired_time fields into $filename at reversive order
if [ $wifi_sec == "none" ]
then
	egrep /proc/wlan0/sta_keyinfo -e "hw|keyInCam:" | awk '{print $2}' | sed '1!G;h;$!d' |tr '\n' '\t' | sed 's/\(\w\+\)\W\(\w\+\)\W/\1 \2\n/g' | grep no | awk '{print $2}' > $filename
else
	egrep /proc/wlan0/sta_keyinfo -e "hw|keyInCam:" | awk '{print $2}' | sed '1!G;h;$!d' |tr '\n' '\t' | sed 's/\(\w\+\)\W\(\w\+\)\W/\1 \2\n/g' | grep yes | awk '{print $2}' > $filename
fi

#print only the connections with non-zero expiration types
while read -r line
do
	echo "$line"

done < "$filename"

#remove the temp file
rm -f $filename

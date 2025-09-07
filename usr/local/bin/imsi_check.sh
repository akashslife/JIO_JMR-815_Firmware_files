#!/bin/sh
IMSI=`db_reader -p imsi | cut -c 1-5`

if [ $IMSI == "22201" ];then
	echo "Global IMSI Check Found, $(date '+%Y%m%d,%H:%M')" >>/nvm/etc/Log
	/etc/ue_lte/at.sh 'AT+CSIM=56,"80C2000017D615190103820282811B01001309044578000000000000"'
	sleep 10
	fw_setenv reboot 1
	reboot
	sync
fi

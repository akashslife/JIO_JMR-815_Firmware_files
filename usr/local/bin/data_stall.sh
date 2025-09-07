#!/bin/sh
#COMPLETE_COUNT=`/etc/ue_lte/at.sh 'at%count="rrc"' 1 | grep "connection setup Complete:" | cut -d : -f 2|tr -d ' '`
#REQUEST_COUNT=`/etc/ue_lte/at.sh 'at%count="rrc"' 1 | grep "connection requests:" | cut -d : -f 2|tr -d ' '`
LTE_STATUS=`db_reader -p lte_status`
OLD_COMPLETE_COUNT="0"
SLEEP_COUNT=$1
CLEAR_COUNT="0"

#echo $COMPLETE_COUNT
#echo $REQUEST_COUNT
#echo $LTE_STATUS

while [ 1 ];

do

COMPLETE_COUNT=`/etc/ue_lte/at.sh 'at%count="rrc"' 1 | grep "connection setup Complete:" | cut -d : -f 2|tr -d ' '`
REQUEST_COUNT=`/etc/ue_lte/at.sh 'at%count="rrc"' 1 | grep "connection requests:" | cut -d : -f 2|tr -d ' '`
#COMPLETE_COUNT=`cat CC`
#REQUEST_COUNT=`cat RC`
LTE_STATUS=`db_reader -p lte_status`

TOTAL=`expr $REQUEST_COUNT - $COMPLETE_COUNT`

if [ $TOTAL -ge 5 ] && [ $LTE_STATUS == "Registered" ];then

	if [ $OLD_COMPLETE_COUNT -eq $COMPLETE_COUNT ];then
		/etc/ue_lte/at.sh 'at%count="rrc",,,"clear"' 1
		/etc/ue_lte/at.sh 'at+cfun=0' 1
		/etc/ue_lte/at.sh 'at%cmatt=1' 1
		OLD_COMPLETE_COUNT="0"

		echo "Data Stall Recovered, $(date '+%Y%m%d,%H:%M'),REQ=$REQUEST_COUNT, COMPLETE=$COMPLETE_COUNT " >> /nvm/etc/Log
	
	elif [ $OLD_COMPLETE_COUNT -lt $COMPLETE_COUNT ];then
		CLEAR_COUNT=`expr $CLEAR_COUNT + 1`
                echo "RRC Count Clear, $(date '+%Y%m%d,%H:%M'),CLEAR=$CLEAR_COUNT, REQ=$REQUEST_COUNT, COMPLETE=$COMPLETE_COUNT " >> /nvm/etc/Log
		/etc/ue_lte/at.sh 'at%count="rrc",,,"clear"' 1
		OLD_COMPLETE_COUNT="0"
	fi

else

	OLD_COMPLETE_COUNT=$COMPLETE_COUNT
	#echo $OLD_COMPLETE_COUNT
	
fi

sleep $SLEEP_COUNT

done

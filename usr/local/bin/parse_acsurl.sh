#!/bin/sh
#NTmore added.

EXIST_PROTOCOL=`cat /etc/config/cpestate.xml | grep acsURL | grep "://" | wc -l`

if [ $EXIST_PROTOCOL -eq 1 ]; then
#	echo exist protocol

	TEMP_URL=`cat /etc/config/cpestate.xml | grep acsURL | sed -e 's/\:\/\//\ /g' | awk ' {print $2}'`
else
#	echo non-exist protocol

	TEMP_URL=`cat /etc/config/cpestate.xml | grep acsURL | sed -e 's/<acsURL>/\ /g' | awk ' {print $1}'`
fi

#echo temp_url : $TEMP_URL

EXIST_PORT=`echo $TEMP_URL | grep ":" | wc -l`

#echo exist_port $EXIST_PORT

if [ $EXIST_PORT -eq 1 ]; then
#	echo exist port
	ACS_URL=`echo $TEMP_URL | sed -e 's/:/\ /g' | awk '{print $1}'`
else
#	echo non-exist port
	ACS_URL=`echo $TEMP_URL | sed -e 's/\//\ /g'  | sed -e 's/</\ /g' | awk '{print $1}'`
fi

echo $ACS_URL
	

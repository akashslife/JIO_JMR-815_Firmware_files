#!/bin/sh

#CON_START=`cat /tmp/connected_time`
CON_START=`db_reader -p connected`

if [ $CON_START == '0' ]; then
	echo 0sec
	exit 1
fi


CON_NOW=`date +%s`

CON_TOT_SEC=`expr "$CON_NOW" "-" "$CON_START"`
#debug -- echo con_tot_sec  $CON_TOT_SEC

CON_HOUR=`expr "$CON_TOT_SEC" "/" "3600"`
#debug -- echo con_hour $CON_HOUR

CON_TEMP=`expr "$CON_TOT_SEC" "%" "3600"`
#debug -- echo con_temp $CON_TEMP

CON_MIN=`expr "$CON_TEMP" "/" "60"`
#debug -- echo con_min $CON_MIN

CON_SEC=`expr "$CON_TEMP" "%" "60"`
#debug -- echo con_sec $CON_SEC


if [ $CON_HOUR -gt 0 ]
then
    echo "$CON_HOUR"hour "$CON_MIN"min "$CON_SEC"sec
elif [ $CON_MIN -gt 0 ]
then
    echo "$CON_MIN"min "$CON_SEC"sec
else
    echo "$CON_SEC"sec
fi


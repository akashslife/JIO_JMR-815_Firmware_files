#!/bin/sh

#Remark: we dont run at command in collect logs - if needed
#        we can do it via db probe
#echo "==============="
#echo "AT"
#echo "==============="
#/etc/ue_lte/at.sh 'at%count="pwr"' 1
#echo "--------------------------"
#/etc/ue_lte/at.sh 'at%count="pwr"' 1



echo "linux pwr"
echo "================"
cat  /sys/devices/soc.0/b0220200.pm/sleep_status
echo
cat  /sys/devices/soc.0/b0220200.pm/sleep_counters


#!/bin/sh
echo "==========="
echo " Wifi Info "
echo "==========="

echo "=============="
echo " mib all Info "
echo "=============="
cat /proc/wlan0/mib_all   

echo "=============="
echo " dbg Info "
echo "=============="
cat /proc/wlan0/sdio_dbginfo

echo "=============="
echo " station Info "
echo "=============="
cat /proc/wlan0/sta_info 

echo "====================="
echo " stat and queue Info "
echo "====================="

let count=0;
while [ $count -lt 5 ]; do
    echo "Iteration #"$count ;
    date;
    cat /proc/wlan0/stats;
    cat /proc/wlan0/que_info; 
    tc -s qdisc show dev wlan0;
    sleep 2;
    let count=count+1;
done


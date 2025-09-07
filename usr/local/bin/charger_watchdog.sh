#!/bin/sh
# 
# Reset Charger watchdog timer (30 sec max).
# 
. /usr/local/bin/lte-gw-global-env.sh
if [ $PROJECT_TYPE != "PWRT" ]; then
	echo "not PWRT skipping script "$0        
	exit 0
fi
i2cset -y 0 0x6b 1 0x80
i2cset -y 0 0x6b 1 0x20
i2cset -y 0 0x6b 2 0xa0
i2cset -y 0 0x6b 6 0xb8
while [ 1 ];
do
 i2cset -y 0 0x6b 0 0x80
# P=`i2cget -y 0 0x55 0x8 w`; echo $(($P));
# echo 1
 sleep 20;
done

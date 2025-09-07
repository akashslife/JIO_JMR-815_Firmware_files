#!/bin/sh

if [ -e /sys/devices/soc.0/b0220200.pm/eLC_allow_sleep ]
then
    SLEEP_ALLOW_FILE="/sys/devices/soc.0/b0220200.pm/eLC_allow_sleep"
else
    SLEEP_ALLOW_FILE="/sys/devices/soc.0/bf020400.pm/eLC_allow_sleep"
fi

echo $1 > $SLEEP_ALLOW_FILE

if [ $1 == 0 ]; then
        echo "sleep not allowed" > /dev/kmsg
else
        echo "sleep allowed" > /dev/kmsg
fi



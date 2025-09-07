#!/bin/sh

#Export the relevent interfaces name
. /usr/local/bin/lte-gw-global-env.sh

# Available TYPES PWRT_USB , PWRT_ETH , PWRT_FULL
if [ $PWRT_CONFIG = "PWRT_ETH" ]; then
ETH_PORT=1
elif [ $PWRT_CONFIG = "PWRT_USB" ]; then
USB_PORT=1
elif [ $PWRT_CONFIG = "PWRT_FULL" ]; then
ETH_PORT=1
USB_PORT=2
fi

ETH_USERS=0
USB_USERS=0

for s in `brctl showmacs br0 | egrep -v '(yes|port)' | awk '$4 < 3 {print $1}'`; do
        case "$s" in
                "$ETH_PORT")
                        let ETH_USERS=$ETH_USERS+1
                        ;;
                "$USB_PORT")
                        let USB_USERS=$USB_USERS+1
                        ;;
                *)
                ;;
        esac

done

echo "$ETH_USERS"
echo "$USB_USERS"




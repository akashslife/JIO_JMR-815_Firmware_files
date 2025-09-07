#!/bin/sh

#Export the relevent interfaces name
. /usr/local/bin/lte-gw-global-env.sh

GPIO_5_ADDRESS=0xb496e3fc
GPIO_12_ADDRESS=0xb496e400
REGISTER_SIZE=32

#This script access the relevant registers in order to drop / load the 
#physical ETH interface


GPIO_12_bit2() {

    REG_VAL=`devmem $GPIO_12_ADDRESS $REGISTER_SIZE`
    let "RESULT=$REG_VAL | 0x4"
    devmem $GPIO_12_ADDRESS $REGISTER_SIZE $RESULT
}


stop_eth() {

    GPIO_12_bit2

    ifconfig $LAN_IF down

    REG_VAL=`devmem $GPIO_5_ADDRESS $REGISTER_SIZE`
    let "RESULT=$REG_VAL & 0xFB"
    devmem $GPIO_5_ADDRESS $REGISTER_SIZE $RESULT
}

start_eth() {

    GPIO_12_bit2

    REG_VAL=`devmem $GPIO_5_ADDRESS $REGISTER_SIZE`
    echo $REG_VAL
    let "RESULT=$REG_VAL | 0x4"
    echo $RESULT

    devmem $GPIO_5_ADDRESS $REGISTER_SIZE $RESULT

    ifconfig $LAN_IF up
}

#GPIO_12_bit2 direction:
#0xb496e400
#0xE (should read value and then OR with 0x4)
#write [ read(0xb496e400) | 0x4 ]


if [ $LAN_IF != "eth0" ]; then
    exit
fi


case "$1" in
    start)
        start_eth
        ;;
    stop)
        stop_eth
        ;;
    restart)
    $0 stop
    $0 start
    ;;
    restart-aneg)
        CONTROL_REG_VAL=0x$(mii-diag eth0 | grep "Basic registers of MII PHY" | awk '{print $7}')
        # Transceiver power down 
        mii-diag -C 0x800 $LAN_IF

        sleep 4

        # Transceiver normal operation
        mii-diag -C $CONTROL_REG_VAL $LAN_IF
        ;;
    status)
        echo "N/A"
        ;;
esac

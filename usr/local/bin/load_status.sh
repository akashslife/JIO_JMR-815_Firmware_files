#!/bin/sh

        MEM_STAT=`top -n 1 | grep "Mem:" | awk '{ print $4 }'`
#user CPU Status ------
#        CPU_STAT=`top -n 1 | grep "CPU:" | awk '{ print $2 }'`
#System CPU Status ------
        CPU_STAT=`top -n 1 | grep "CPU:" | awk '{ print $4 }'`
	RX_DIFF=`db_reader -p downlink`
	TX_DIFF=`db_reader -p uplink`
#        RX_OLD_DATA=`cat /sys/class/net/lte0/statistics/rx_bytes`
#        TX_OLD_DATA=`cat /sys/class/net/lte0/statistics/tx_bytes`

#        sleep 1

#        RX_CUR_DATA=`cat /sys/class/net/lte0/statistics/rx_bytes`
#        TX_CUR_DATA=`cat /sys/class/net/lte0/statistics/tx_bytes`


#        RX_DIFF=`expr "$RX_CUR_DATA" "-" "$RX_OLD_DATA"`
#        TX_DIFF=`expr "$TX_CUR_DATA" "-" "$TX_OLD_DATA"`

        #echo RX_OLD_DATA : $RX_OLD_DATA, TX_OLD_DATA : $TX_OLD_DATA
        #echo RX_CUR_DATA : $RX_CUR_DATA, TX_CUR_DATA : $TX_CUR_DATA


        echo $MEM_STAT, $CPU_STAT, $RX_DIFF, $TX_DIFF >/tmp/perform


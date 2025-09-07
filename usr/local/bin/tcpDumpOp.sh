#!/bin/sh

#tcpDumpOp.sh start/stop if log
APPEXEC=tcpdump
IF=$2
LOGF=$3_$2.pcap
MAX_FILE_SIZE=2 #In  MBytes
MAX_ROTATION_FILES=2
FLASH_EACH_PACKET=-U #do not buffer packets
POST_ROTATE_CMD=gzip_force.sh

case "$1" in
    start)
	    echo -e "Removing old files with prefix $3_$2\n" > /dev/kmsg
            rm -rf $3_$2*
	    echo -e "uci get service.IMS.TcpLogEnabled=true\n" > /dev/kmsg
	    echo -e "$APPEXEC -i $IF $FLASH_EACH_PACKET -w $LOGF -W $MAX_ROTATION_FILES -C $MAX_FILE_SIZE -z $POST_ROTATE_CMD & \n" > /dev/kmsg
	    $APPEXEC -i $IF $FLASH_EACH_PACKET -w $LOGF  -W $MAX_ROTATION_FILES -C $MAX_FILE_SIZE -z $POST_ROTATE_CMD &
        ;;
    stop)
        killall $APPEXEC 2>/dev/null
        ;;
    restart)
    $0 stop
    $0 start
    ;;
    status)
        if pidof $APPEXEC | sed "s/$$\$//" | grep -q [0-9] ; then
        echo "running"
        else
        echo "stopped"
        fi
        ;;
esac

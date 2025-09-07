#for diagnostic

DIAGFILE=/tmp/diagnostic

if [ ! -f $DIAGFILE ]; then
		rm -rf /home/www/*_tmplog.tar.gz
		rm -rf /home/www/*_ecm.log
		echo "config 'Global' 'diagnostic'" >$DIAGFILE
fi

case "$1" in
	init)	
		CPU_AVER=`top -n 1 | grep CPU | grep -v PID | awk '{print $2}'`
		MEM_FREE=`cat /proc/meminfo | grep MemFree | awk '{print $2}'`
		RFS_USAGE=`df | grep "/dev/root" | awk '{print $5}'`
		UP_USAGE=`df | grep "/upload" | awk '{print $5}'`
#		UBOOT_DELAY=`fw_printenv bootdelay | cut -d = -f2`
#		UBOOT_NUM=`fw_printenv boot_number | cut -d = -f2`
                HN_VER=`/etc/ue_lte/at.sh at%ver 1 | grep "NP Package" |cut -d : -f2| tr -d ' '`
		MODEM_VER=`/etc/ue_lte/at.sh at%ver 1 | grep "MAC Package" |cut -d : -f2| tr -d ' '`

		FACTORY_STATUS_COUNT=`cat /nvm/bsp/factory | grep "'1'" |wc -l`
		WIFI_STATUS=0
		WIFI_STATUS_COUNT=`ifconfig wlan0 |wc -l`
		DNSMASQ_COUNT=`ps -ef| grep dns | grep -v grep |wc -l`
		BAD_COUNT=`dmesg | grep "Bad eraseblock" |wc -l`
		KERFAULT_COUNT=`dmesg | grep "Call Trace" |wc -l`
#		NAND_INTER_COUNT=`dmesg | grep "timeout waiting for interrupt" |wc -l`
#		NAND_PAD_COUNT=`dmesg | grep "jffs2_sum_write_data"|wc -l`
		PING_TEST_COUNT=`ping 8.8.8.8 -w 2 -c 1 | grep "bytes from" |wc -l`
		PING_TEST=0
#		DNS_PING_TEST_COUNT=`ping yahoo.co.kr -w 2 -c 1 | grep "bytes from" |wc -l`
		DNS_PING_TEST=0
		MODEM_ASSERT_COUNT=`ls -1 /nvm/CrushDumps/ |wc -l`
		
		CALBSPDOWNLOAD_READY=0
		TMPDOWNLOAD_READY=0

		FACTORY_STATUS=$FACTORY_STATUS_COUNT

		if [ $PING_TEST_COUNT -gt "0" ];then
			PING_TEST="PingOK"
			DNS_PING_TEST_COUNT=`ping yahoo.co.kr -w 2 -c 1 | grep "bytes from" |wc -l`
		else
			CEER=`/etc/ue_lte/at.sh at%ceer? 1 | grep CEER| cut -d : -f2 | tr -d ' '`
			PING_TEST="NoResponse,CEER:${CEER}"
			DNS_PING_TEST_COUNT="0"
		fi

		if [ $DNS_PING_TEST_COUNT -gt "0" ];then
			DNS_PING_TEST="PingOK"
		else
			DNS_PING_TEST="NoResponse"
		fi		

		if [ -f /home/www/*_bsp_backup.tar ];then
			CALBSPDOWNLOAD_READY=1
		fi
		
		if [ -f /home/www/*_tmplog.tar.gz ];then
			TMPDOWNLOAD_READY=1
		fi
		
		if [ -f /home/www/*_ecm.log ];then
			ECMDOWNLOAD_READY=1
		fi		
		
		if [ $WIFI_STATUS_COUNT -gt "0" ];then
			WIFI_STATUS="Working"
		else
			WIFI_STATUS="NoWorking"
		fi

		uci set $DIAGFILE.diagnostic.hnver=$HN_VER
		uci set $DIAGFILE.diagnostic.modemver=$MODEM_VER
		uci set $DIAGFILE.diagnostic.cpuaver=$CPU_AVER
		uci set $DIAGFILE.diagnostic.memfree=$MEM_FREE
		uci set $DIAGFILE.diagnostic.rfsusage=$RFS_USAGE
		uci set $DIAGFILE.diagnostic.upusage=$UP_USAGE
#		uci set $DIAGFILE.diagnostic.uboot_usb=$UBOOT_USB
#		uci set $DIAGFILE.diagnostic.uboot_delay=$UBOOT_DELAY
#		uci set $DIAGFILE.diagnostic.uboot_num=$UBOOT_NUM
		uci set $DIAGFILE.diagnostic.factory_status=$FACTORY_STATUS
		uci set $DIAGFILE.diagnostic.wifi_status=$WIFI_STATUS
		uci set $DIAGFILE.diagnostic.dnsmasq_status=$DNSMASQ_COUNT
		uci set $DIAGFILE.diagnostic.bad_count=$BAD_COUNT
		uci set $DIAGFILE.diagnostic.kerfault_count=$KERFAULT_COUNT
		uci set $DIAGFILE.diagnostic.nand_inter_count=$NAND_INTER_COUNT
		uci set $DIAGFILE.diagnostic.nand_pad_count=$NAND_PAD_COUNT
		uci set $DIAGFILE.diagnostic.ping_test=$PING_TEST
		uci set $DIAGFILE.diagnostic.dns_ping_test=$DNS_PING_TEST
		uci set $DIAGFILE.diagnostic.cal_bsp_download_ready="$CALBSPDOWNLOAD_READY"
		uci set $DIAGFILE.diagnostic.tmp_log_download_ready="$TMPDOWNLOAD_READY"
		uci set $DIAGFILE.diagnostic.ecm_log_download_ready="$ECMDOWNLOAD_READY"
		uci set $DIAGFILE.diagnostic.assert_modem_logcount="$MODEM_ASSERT_COUNT"
		uci commit $DIAGFILE
		;;
		
	backup)
		MODEL_SERIAL_COUNT=`uci get /nvm/bsp/factory.value.psn|wc -L`
		MODEL_SERIAL=`uci get /nvm/bsp/factory.value.psn`
		cp -rf /nvm/ /home/www/
		rm -rf /home/www/nvm/etc/config
		cd /home/www/
		if [ $MODEL_SERIAL_COUNT -eq 15 ];then
			tar cvf ${MODEL_SERIAL}_bsp_backup.tar nvm
		else
			tar cvf _bsp_backup.tar nvm
		fi
		rm -rf /home/www/nvm
		;;
	restore)
		rm -rf /tmp/update_result

		if [ -f $2 ];then
			mv $2 /nvm
			cd /
			tar xvf /nvm/*.tar
			rm -rf /nvm/*.tar
			echo "Done" >/tmp/update_result
		else
			echo "No files" >/tmp/update_result
		fi
		;;
	dump_tmp)
		MODEL_SERIAL_COUNT=`uci get /nvm/bsp/factory.value.psn|wc -L`
		MODEL_SERIAL=`uci get /nvm/bsp/factory.value.psn`
		rm -rf /home/www/*_tmplog.tar
		cd /home/www/
	
		/usr/bin/collect-logs.sh
		
		if [ $MODEL_SERIAL_COUNT -eq 15 ];then
#                        tar cvf ${MODEL_SERIAL}_tmplog.tar /tmp
			mv /nvm/Logs/*.tar.gz /home/www/${MODEL_SERIAL}_tmplog.tar.gz
		else
#                        tar cvf _tmplog.tar /tmp
			mv /nvm/Logs/*.tar.gz /home/www/_tmplog.tar.gz
		fi
                rm -rf /tmp/kernel.log
		;;

        dump_ecm)
		MODEL_SERIAL_COUNT=`uci get /nvm/bsp/factory.value.psn|wc -L`
                MODEL_SERIAL=`uci get /nvm/bsp/factory.value.psn`
                rm -rf /home/www/*ecm.log
                cd /home/www/

		if [ $MODEL_SERIAL_COUNT -eq 15 ];then
			cp /tmp/logs/ecm.log /home/www/${MODEL_SERIAL}_ecm.log
		else
			cp /tmp/logs/ecm.log /home/www/_ecm.log
		fi
                ;;
esac

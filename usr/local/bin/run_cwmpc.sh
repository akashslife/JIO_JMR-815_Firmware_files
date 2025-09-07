#!/bin/sh
FIR_PDN=`uci get /etc/config/APNTable.Class1.Enabled`
FIR_PDN_TYPE=`uci get /etc/config/APNTable.Class1.IP_Type`

SEC_PDN=`uci get /etc/config/APNTable.Class2.Enabled`
SEC_PDN_TYPE=`uci get /etc/config/APNTable.Class2.IP_Type`

#TIME is Waiting time until ADDR_TYPE of IFACE up.
TIME=20

DISABLE=0
CNT=0

#this value of ADDR_TYPE Convey to cwmpc with -p option.
ADDR_TYPE="inet6 addr"

searching_inet(){
	#must be able to connect to External network. Scope:Global can connect to External network. Scope:Link can't connect to External network.
	if [ $1 -eq 6 ]; then
		CMD="`ifconfig $IFACE | grep "inet6 addr" | grep "Scope:Global" | wc -l`"			
	else
		CMD="`ifconfig $IFACE | grep "inet addr" | wc -l`"
	fi

	COUNT_LTE02=$CMD
	while [ $COUNT_LTE02 -eq 0 ]; do
		sleep $TIME
		COUNT_LTE02=$CMD
		if [ $CNT -gt 2 ]; then
			#if don't search useful ADDR_TYPE after wait 120 second, will search another ADDR_TYPE.
			DISABLE=1
			break
		fi  
		let CNT++
	done
}

searching_inet_lte0(){
	#must be able to connect to External network. Scope:Global can connect to External network. Scope:Link can't connect to External network.
	if [ $1 -eq 6 ]; then
		CMD="`ifconfig $IFACE | grep "inet6 addr" | grep "Scope:Global" | wc -l`"			
	else
		CMD="`ifconfig $IFACE | grep "inet addr" | wc -l`"
	fi

	COUNT_LTE02=$CMD
	while [ $COUNT_LTE02 -eq 0 ]; do
		sleep $TIME
		COUNT_LTE02=$CMD
	done
}

#check attaching network.
IS_CONNECTED=`db -d | db -d | grep connected: | cut -d ' ' -f 2`
while [ $IS_CONNECTED -eq 0 ]; do
	sleep 5
	IS_CONNECTED=`db -d | db -d | grep connected: | cut -d ' ' -f 2`
done

# Try connection to lte0.2
if [ $SEC_PDN = "true" ]; then
	IFACE="lte0.2"
	
	if [ $SEC_PDN_TYPE = "IPV6" ]; then
		ADDR_TYPE="inet6"	
		searching_inet 6
	elif [ $SEC_PDN_TYPE = "IP" ]; then
		ADDR_TYPE="inet"	
		searching_inet 4
	else
		#first must search ipv6.
		ADDR_TYPE="inet6"	
		searching_inet 6
		
		#if don't search useful ipv6 address, will search ipv4 address
		if [ $DISABLE -eq 1 ]; then
			COUNT_LTE02=`ifconfig $IFACE 2>&1 | grep "inet addr" | wc -l`
			if [ $COUNT_LTE02 -ne 0 ]; then
				DISABLE=0
				ADDR_TYPE="inet"	
			fi
		fi
	fi

	if [ $DISABLE -eq 0 ]; then
		#if succeeded searching useful ADDR_TYPE, excute a cwmpc process with -p ADDR_TYPE -i IFACE.
		echo "found $ADDR_TYPE in [ $IFACE ] ... COUNT_LTE02 = $COUNT_LTE02"
#		rm /etc/config/config.save
		/usr/bin/cwmpc -i $IFACE -D 0x00 -c DEFAULT -p $ADDR_TYPE &
		exit
	fi  
	echo "Not found $ADDR_TYPE in [ $IFACE ]"
fi

# Initial value 
DISABLE=0
CNT=0
# Try connection to lte0 
if [ $FIR_PDN = "true" ]; then
#jwpark 2014.07.22 changed a interface name from lte0 to lte0.1 at Ver. ALT3100_PWRT_03_00_04_00_14.
	IFACE="lte0.1"
	
	if [ $FIR_PDN_TYPE = "IPV6" ]; then
		ADDR_TYPE="inet6"	
		searching_inet_lte0 6	
	elif [ $FIR_PDN_TYPE = "IP" ]; then
		ADDR_TYPE="inet"	
		searching_inet_lte0 4
	else
		ADDR_TYPE="inet6"	

		COUNT_LTE02=`ifconfig $IFACE 2>&1 | grep "$ADDR_TYPE" | grep "Scope:Global" | wc -l`
		while [ $COUNT_LTE02 -eq 0 ]; do
			sleep $TIME 
			COUNT_LTE02=`ifconfig $IFACE 2>&1 | grep "$ADDR_TYPE" | grep "Scope:Global" | wc -l`
			if [ $CNT -gt 2 ]; then
				#if don't search useful ipv6 address, will search ipv4 address
				COUNT_LTE02=`ifconfig $IFACE 2>&1 | grep "inet addr" | wc -l`
				if [ $COUNT_LTE02 -ne 0 ]; then
					ADDR_TYPE="inet"	
					break
				fi
				#until searching ADDR_TYPE of IFACE do loop.
				CNT=0
			fi  
			let CNT++
		done
	fi

	echo "found $ADDR_TYPE in [ $IFACE ] COUNT_LTE02 = $COUNT_LTE02"
#	rm /etc/config/config.save
	#if succeeded searching useful ADDR_TYPE, excute a cwmpc process with -p ADDR_TYPE -i IFACE.
	/usr/bin/cwmpc -i $IFACE -D 0x00 -c DEFAULT -p $ADDR_TYPE &
fi	


###################    Multiple PDN Suport    ###################
#---------------------------------------------------------------->
#COUNT_LTE0=`ifconfig lte0 2>&1 | grep "inet addr" | wc -l`
#COUNT_LTE02=`ifconfig lte0.2 2>&1 | grep "inet addr" | wc -l`
#COUNT=`expr "$COUNT_LTE0" "+" "$COUNT_LTE02"`

#while [ $COUNT -eq 0 ]; do
#    sleep 20
#	COUNT_LTE0=`ifconfig lte0 2>&1 | grep "inet addr" | wc -l`
#	COUNT_LTE02=`ifconfig lte0.2 2>&1 | grep "inet addr" | wc -l`
#	COUNT=`expr "$COUNT_LTE0" "+" "$COUNT_LTE02"`
#done

#if [ $COUNT_LTE02 -eq 1 ]
#then
#	IFACE="lte0.2"
#	IFACE="lte0"
#fi
#<----------------------------------------------------------------


###################    Single PDN Support    #####################
#---------------------------------------------------------------->
#COUNT=`ifconfig lte0 2>&1 | grep "inet addr" | wc -l`

#while [ $COUNT -eq 0 ]; do
#    sleep 20
#	COUNT=`ifconfig lte0 2>&1 | grep "inet addr" | wc -l`
#done

#IFACE="lte0"
#<----------------------------------------------------------------


#jwpark 2013.07.18 remove config.save file in order to synchronize with web-ui when cwmpc bootup.
#rm /etc/config/config.save

#/usr/bin/cwmpc -i $IFACE -D 0x00 -c DEFAULT &
#debug : /usr/bin/cwmpc -i $IFACE -D 0xff -v -c DEFAULT &

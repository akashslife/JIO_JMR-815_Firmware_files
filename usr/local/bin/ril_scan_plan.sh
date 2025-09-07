#!/bin/sh

#### check_scan_plan_list function ####
check_scan_plan_list(){

atcmd /tmp/atsw10 at%getcfg='"scan_list"' | grep "[0-9]" >/tmp/scanlist_target

RESULT=`diff -Nurw /etc/scan_list /tmp/scanlist_target | wc -l`
                                                               
        if [ $RESULT -eq 0 ];then                              
		scan_plan_result=0
	else
		scan_plan_result=1
        fi                                                     
}

#### check_value function ####
check_value(){
CHECK_SP_MODE=`atcmd /tmp/atsw10 at%getcfg='"SP_MODE"' | grep : | cut -d : -f2| tr -d ' '`
CHECK_SP_SCHED_SCHEME=`atcmd /tmp/atsw10 at%getcfg='"SP_SCHED_SCHEME"' | grep : | cut -d : -f2| tr -d ' '`
CHECK_SP_SCHED_COUNTER=`atcmd /tmp/atsw10 at%getcfg='"SP_SCHED_COUNTER"' | grep : | cut -d : -f2| tr -d ' '`
CHECK_ENABLE=`atcmd /tmp/atsw10 at%getcfg='"scan_plan_en"' | grep : | cut -d : -f2| tr -d ' '`

CHECK_SP_MODE_CONFIG=`uci get /etc/config/scan_plan.value.SP_MODE`
CHECK_SP_SCHED_SCHEME_CONFIG=`uci get /etc/config/scan_plan.value.SP_SCHED_SCHEME`
CHECK_SP_SCHED_COUNTER_CONFIG=`uci get /etc/config/scan_plan.value.SP_SCHED_COUNTER`
CHECK_ENABLE_CONFIG=`uci get /etc/config/scan_plan.value.scan_plan_en`

if [ $CHECK_SP_MODE -eq $CHECK_SP_MODE_CONFIG ] && [ $CHECK_SP_SCHED_SCHEME -eq $CHECK_SP_SCHED_SCHEME_CONFIG ] && [ $CHECK_SP_SCHED_COUNTER -eq $CHECK_SP_SCHED_COUNTER_CONFIG ] && [ $CHECK_ENABLE -eq $CHECK_ENABLE_CONFIG ];then
	config_result=0
else
	config_result=1
fi

}

#### set scan plan value ####

set_scan_plan(){
/etc/ue_lte/at.sh at%setcfg='"scan_list","0","1","3","1","1234","1234"' 1
/etc/ue_lte/at.sh at%setcfg='"scan_list","1","1","3","1","1286","1286"' 1
/etc/ue_lte/at.sh at%setcfg='"scan_list","2","1","3","1","1328","1328"' 1
/etc/ue_lte/at.sh at%setcfg='"scan_list","3","1","3","1","1350","1350"' 1
/etc/ue_lte/at.sh at%setcfg='"scan_list","4","1","3","1","1356","1356"' 1
/etc/ue_lte/at.sh at%setcfg='"scan_list","5","1","3","1","1370","1370"' 1
/etc/ue_lte/at.sh at%setcfg='"scan_list","6","1","3","1","1394","1394"' 1
/etc/ue_lte/at.sh at%setcfg='"scan_list","7","1","3","1","1516","1516"' 1
/etc/ue_lte/at.sh at%setcfg='"scan_list","8","1","3","1","1536","1536"' 1
/etc/ue_lte/at.sh at%setcfg='"scan_list","9","1","3","1","1562","1562"' 1
/etc/ue_lte/at.sh at%setcfg='"scan_list","10","1","3","1","1616","1616"' 1
/etc/ue_lte/at.sh at%setcfg='"scan_list","11","1","3","1","1636","1636"' 1
/etc/ue_lte/at.sh at%setcfg='"scan_list","12","1","3","1","1642","1642"' 1
/etc/ue_lte/at.sh at%setcfg='"scan_list","13","1","3","1","1724","1724"' 1
/etc/ue_lte/at.sh at%setcfg='"scan_list","14","1","40","25"' 1
/etc/ue_lte/at.sh at%setcfg='"scan_list","15","1","5"' 1
/etc/ue_lte/at.sh at%setcfg='"SP_MODE","2"' 1
/etc/ue_lte/at.sh at%setcfg='"SP_SCHED_SCHEME","1"' 1
/etc/ue_lte/at.sh at%setcfg='"SP_SCHED_COUNTER","4"' 1
/etc/ue_lte/at.sh at%setcfg='"scan_plan_en","1"' 1
}


SCAN_PLAN_TEST=`uci get /etc/config/scan_plan.value.tested`

if [ $SCAN_PLAN_TEST -eq 0 ];then

check_scan_plan_list
check_value

#echo "scan_plan_result : $scan_plan_result"
#echo "config_result : $config_result"


	if [ $scan_plan_result -eq 0 ] && [ $config_result -eq 0 ];then
		uci set /etc/config/scan_plan.value.tested="1"
	else
		set_scan_plan	
	fi


fi

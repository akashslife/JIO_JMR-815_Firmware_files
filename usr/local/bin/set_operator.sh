#!/bin/sh

NVM_CFG_PATH='/nvm/etc/config'
OPERATOR_FOLDER_NAME="default"
REQUIRED_OPERATOR_ID=0
OPERATOR_NAME="default"

atcmd_send()
{
 CMD=$1
 TIMEOUT=$2	

 /etc/ue_lte/at.sh $CMD $TIMEOUT | grep -q OK

 if [ $? -ne 0 ]; then
  echo $CMD FAIL!
  exit 1
 fi
}

uci_set()
{
 uci set $1=$2
 uci commit $1

 if [ $? -ne 0 ]; then
  echo $1=$2 FAIL!
  exit 1
 fi	
}

copy_operator_files()
{
# copy operator related config files

    if [ -e /etc/operators/"$OPERATOR_FOLDER_NAME" ]; then
        OPER_PATH='/etc/operators/'"$OPERATOR_FOLDER_NAME"
    else
        OPER_PATH='/etc/operators/default'
    fi

    cp -rf $OPER_PATH/config/* $NVM_CFG_PATH
    cp -rf $OPER_PATH/scripts/* /usr/local/bin/

    uci set service.Mode.Operator="$OPERATOR_NAME"
    uci commit service.Mode.Operator

    echo ">>> Copy Operator configurations from $OPER_PATH >>>" > /dev/kmsg
}



get_modem_operator()
{
	
    case "$@" in
    "vzw"|"Verizon" )
       MODEM_FW_OPER_MODE=1
       OPERATOR_FOLDER_NAME="vzw"
       OPERATOR_NAME="vzw"
        ;;
    "CMCC" )
       MODEM_FW_OPER_MODE=2
       OPERATOR_FOLDER_NAME="default"
       OPERATOR_NAME="CMCC"
        ;;
    "RJIL"|"JIO" )
       MODEM_FW_OPER_MODE=3
       OPERATOR_FOLDER_NAME="default"
       OPERATOR_NAME="RJIL"
        ;;
    "kddi"|"KDDI" )
       MODEM_FW_OPER_MODE=4
       OPERATOR_FOLDER_NAME="kddi"
       OPERATOR_NAME="kddi"
        ;;
    "att"|"AT&T" )
       MODEM_FW_OPER_MODE=5
       eval OPERATOR_FOLDER_NAME="att"
       OPERATOR_NAME="att"
        ;;
    "uscc"|"USCC" )
       MODEM_FW_OPER_MODE=6
       OPERATOR_FOLDER_NAME="default"
       OPERATOR_NAME="uscc"
        ;;
    "Docomo"|"DOCOMO" )
       MODEM_FW_OPER_MODE=7
       OPERATOR_FOLDER_NAME="default"
       OPERATOR_NAME="Docomo"
        ;;
    "Softbank"|"SoftBank" )
       MODEM_FW_OPER_MODE=8
       OPERATOR_FOLDER_NAME="default"
       OPERATOR_NAME="Softbank"
        ;;
    "LGU+"|"LG U+" )
       MODEM_FW_OPER_MODE=9
       OPERATOR_FOLDER_NAME="default"
       OPERATOR_NAME="LGU+"
        ;;
    "kt"|"KT" )
       MODEM_FW_OPER_MODE=10
       OPERATOR_FOLDER_NAME="kt"
       OPERATOR_NAME="kt"
        ;;
    "T-Mobile" )
       MODEM_FW_OPER_MODE=11
       OPERATOR_FOLDER_NAME="default"
       OPERATOR_NAME="T-Mobile"
        ;;
    "SKT" )
       MODEM_FW_OPER_MODE=12
       OPERATOR_FOLDER_NAME="default"
       OPERATOR_NAME="SKT"
        ;;
    * )
       MODEM_FW_OPER_MODE=0
       OPERATOR_NAME="default"
        ;;
       esac
       REQUIRED_OPERATOR_ID=$MODEM_FW_OPER_MODE	
}

set_modem_fw_operator()
{
	atcmd_send AT%SETCFG=\"NW_OPER_MODE\",\"$1\"      2
}

set_operator()
{
        CONFIGURED_OPERATOR_NAME=`uci get service.Mode.Operator` 
        get_modem_operator "$@"

	
        if [ "$CONFIGURED_OPERATOR_NAME" == "$OPERATOR_FOLDER_NAME" ]; then
            echo "configured operator $CONFIGURED_OPERATOR_NAME : $REQUIRED_OPERATOR_ID , is same as $@"
        else
            copy_operator_files
            set_modem_fw_operator $REQUIRED_OPERATOR_ID			
        fi	
}

if [ $# -eq 0 ]; then
 OPERATOR=default
else
 OPERATOR=$1
fi

case $OPERATOR in
"default" | "vzw" | "Verizon" | "CMCC" | "RJIL" | "JIO" | "kddi" | "KDDI" | "att" | "AT&T" | "uscc" | "USCC"  | "Docomo"| "DOCOMO" | "Softbank" | "SoftBank" | "LGU+" | "LG U+" | "kt" | "KT" | "T-Mobile" | "SKT")
   set_operator "$OPERATOR"
   ;;
"?")
   echo "default,vzw,CMCC,RJIL,kddi,att,uscc,Docomo,Softbank,LGU+,kt,T-Mobile,SKT"
   exit 0
   ;;
*)
   echo -e "\nERROR: Invalid Operator \"$OPERATOR\" !"
   echo Available Configurations: 
   echo "default,vzw,CMCC,RJIL,kddi,att,uscc,Docomo,Softbank,LGU+,kt,T-Mobile,SKT"
   exit 2	
   ;;
esac

uci_set service.Mode.LstTestMode    null

sync
sync

echo -e "\nOperator: $OPERATOR"


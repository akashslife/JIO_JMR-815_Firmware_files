#!/bin/sh

# Default
MODEM_FW_TEST_MODE=0
ECM_EN_MODE=true
APN_TABLE=APNTable	
APN_TABLE_ROAM=APNTable
ENABLE_ROAMING=true


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

test_setup()
{
 uci_set service.ECM.Enabled            $ECM_EN_MODE
 uci_set service.ECM.APNTableFile       $APN_TABLE
 uci_set service.ECM.APNTableFileRoam   $APN_TABLE_ROAM
 uci_set ecm.Mode.EnableRoamConfig      $ENABLE_ROAMING

 atcmd_send AT%SETCFG=\"enable_test_mode\",\"$MODEM_FW_TEST_MODE\"  2

 uci_set service.Mode.LstTestMode       $CFG_MODE
}

if [ $# -eq 0 ]; then
 CFG_MODE=DEFAULT
else
 CFG_MODE=$1
fi

case $CFG_MODE in
"DEFAULT")
   # Leave params unchanged	
   ;;
"DEFAULT_PDN")
   # Leave params unchanged	
   ;;
"CONFIG1" | "GCF_RF" | "GCF_BB" | "GCF_RRM" | "GCF_SUP_RF" )
   MODEM_FW_TEST_MODE=2
   ENABLE_ROAMING=false
   ;;
"CONFIG2" | "GCF_PROT" | "GCF_USIM" | "GCF_UICC")
   MODEM_FW_TEST_MODE=1
   ECM_EN_MODE=false
   ENABLE_ROAMING=false
   ;;
"CONFIG4" | "USAT")
   APN_TABLE=APNTable_for_usat
   ENABLE_ROAMING=false
   ;;
"CONFIG5" | "BLOCK_DATA")
   MODEM_FW_TEST_MODE=8
   ;;
"GCF_IMS")
   ENABLE_ROAMING=false
   ;;
"?")
   echo "DEFAULT,DEFAULT_PDN,GCF_RF,GCF_BB,GCF_RRM,GCF_SUP_RF,GCF_PROT,GCF_USIM,GCF_UICC,GCF_IMS,USAT,BLOCK_DATA"
   exit 0
   ;;
*)
   echo -e "\nERROR: Invalid Configuration \"$CFG_MODE\" !"
   echo Available Configurations: 
   echo "DEFAULT"
   echo "DEFAULT_PDN"
   echo "CONFIG1 (GCF_RF, GCF_BB, GCF_RRM and GCF_SUP_RF)"
   echo "CONFIG2 (GCF_PROT, GCF_UICC and GCF_USIM)"
   echo "CONFIG4 (USAT)" 
   echo "CONFIG5 (BLOCK_DATA)"
   echo "GCF_IMS"
   exit 1	
   ;;
esac

echo -e "\nConfiguration: $CFG_MODE"

test_setup

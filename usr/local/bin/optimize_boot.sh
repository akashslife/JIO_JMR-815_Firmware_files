#!/bin/sh

# Default
ADMIN_TELNET=enable
ADMIN_FTP=disable
ADMIN_TFTP=disable
ADMIN_SSH=disable
ADMIN_HTTP=disable
ADMIN_PORTMAP=disable

USB_IF=disable



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

set_opt()
{
 uci_set admin.services.telnet          $ADMIN_TELNET
 uci_set admin.services.ftp             $ADMIN_FTP
 uci_set admin.services.tftp            $ADMIN_TFTP
 uci_set admin.services.ssh             $ADMIN_SSH
 uci_set admin.services.http            $ADMIN_HTTP
 uci_set admin.services.portmap         $ADMIN_PORTMAP
 uci_set usb-gadget.config.usb_if       $USB_IF

 atcmd_send AT%SETCFG=\"phy_log_disable\",\"1\"  2
 atcmd_send AT%SETCFG=\"mac_log_sev\",\"255\"  2
 atcmd_send AT%SETCFG=\"pmp_log_sev\",\"255\"  2
 atcmd_send AT%LOGSTOHOST=2

 boot-delay-control.sh 0
}

set_opt

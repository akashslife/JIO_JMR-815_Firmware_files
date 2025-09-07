#!/bin/sh

#The internaet LTE interface lte0 / lte0.1 etc...
LTE_INTERFACE=$1

VPN_IPSEC=`uci get lte-gw.vpn_pass.ipsec`
VPN_PPTP=`uci get lte-gw.vpn_pass.pptp`
VPN_L2TP=`uci get lte-gw.vpn_pass.l2tp`


if [ $VPN_PPTP == "enable" ]
then
    modprobe nf_nat_pptp.ko > /dev/null 2>&1
else
    modprobe -r nf_nat_pptp.ko > /dev/null 2>&1
fi



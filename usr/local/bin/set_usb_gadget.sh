#!/bin/sh

DHCP_MODE=enable
GADGET_NAME=""
#defualt value in /etc/config/usb-gadget
ACM_NUM=3
ETH_NUM=1

print_usage()
{
   echo Available Configurations: 
   echo "rndis / composite / mbim / mbim_acm / mbim_hid / mbim_hid_acm / ncm / ncm_acm / ncm_acm_apa / ncm_acm_cpc / osd / osd_composite / status"
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

uci_get()
{
    uci get $1
}


if [ $# -eq 0 ]; then
    print_usage
    exit
fi

set_rndis()
{
    GADGET_NAME=rndis
    DHCP_MODE=enable
}

set_mbim()
{
    GADGET_NAME=mbim
    DHCP_MODE=disable
}

set_mbim_acm()
{
    GADGET_NAME=mbim_acm
    DHCP_MODE=disable
}

set_mbim_hid()
{
    GADGET_NAME=mbim_hid
    DHCP_MODE=disable
}

set_mbim_hid_acm()
{
    GADGET_NAME=mbim_hid_acm
    DHCP_MODE=disable
}

set_ncm()
{
    GADGET_NAME=ncm
    DHCP_MODE=enable
}

set_ncm_acm()
{
    GADGET_NAME=ncm_acm
    DHCP_MODE=enable
}

set_composite()
{
    GADGET_NAME=composite
    DHCP_MODE=enable
}

set_osd()
{
    GADGET_NAME=osd_algo
    DHCP_MODE=enable
}

set_osd_composite()
{
    GADGET_NAME=osd_composite
    DHCP_MODE=enable
}

set_ncm_acm_cpc()
{
    GADGET_NAME=ncm_acm_cpc
    DHCP_MODE=enable
    ACM_NUM=2
    ETH_NUM=2
}

set_ncm_acm_apa()
{
    GADGET_NAME=ncm_acm_apa
    DHCP_MODE=enable
    ACM_NUM=3
    ETH_NUM=1

}
get_stat()
{
    echo "USB Interface"
    uci_get usb-gadget.config.usb_if
    echo "DHCP mode"
    uci_get lte-gw.dhcp_srv.dhcp_enable
}

commit_new_conf()
{
    uci_set usb-gadget.config.usb_if $GADGET_NAME
    uci_set lte-gw.dhcp_srv.dhcp_enable $DHCP_MODE
    uci_set usb-gadget.config.num_serial_ports $ACM_NUM
    uci_set usb-gadget.config.num_ether_ports $ETH_NUM
}


case "$1" in
    rndis)
        set_rndis
        ;;
    mbim)
        set_mbim
        ;;
    mbim_acm)
        set_mbim_acm
        ;;
    mbim_hid)
        set_mbim_hid
        ;;
    mbim_hid_acm)
        set_mbim_hid_acm
        ;;
    ncm)
        set_ncm
        ;;
    ncm_acm)
        set_ncm_acm
        ;;
    ncm_acm_apa)
        set_ncm_acm_apa
        ;;
    ncm_acm_cpc)
        set_ncm_acm_cpc
        ;;
    composite)
        set_composite
        ;;
    osd)
        set_osd
        ;;
    osd_composite)
        set_osd_composite
        ;;
    status)
        get_stat
        exit
        ;;
    *)
        print_usage
        exit
        ;;

esac

commit_new_conf
sync

echo -e "\nConfiguration: $1 was set"




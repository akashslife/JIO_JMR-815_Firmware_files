#!/bin/sh

GADGETS_LIST="g_eth_acm g_ether g_mass_storage g_mbim g_mbim_acm g_mbim_hid g_mbim_hid_acm g_multi g_ncm g_ncm_acm g_os_detect g_rndis"

is_loaded_module()
{
        module=$(lsmod | awk '{print $1}' | grep $1)
	if [ ! -z $module ]; then
		echo "y"
		return
	fi
	echo "n"
}

rm_module_if_gadget_exist()
{
        local Gadget
        for Gadget in $GADGETS_LIST
        do
                module=$(lsmod | awk '{print $1}' | grep $Gadget)
                if [ ! -z $module ]; then
                        rmmod $module
                fi
        done
}

reset_usb_ctl()
{
	echo 1 > /sys/devices/soc.0/b0220200.pm/reset_usb_ctrl
}

launch_parser()
{
	pid=$(ps | grep parser | grep local | awk '{print $1}')
	if [ -z $pid ]; then
		/usr/local/bin/parser &
	fi
}

is_modprobe_required()
{
        if [ `is_loaded_module $1` == "y" ]; then
                # Make the caller happy
                echo "n"
                return
        fi
        echo "y"
}





#!/bin/sh


#Reset USB PHY & Controller
echo 1 > /sys/devices/soc.0/bf020400.pm/reset_usb_phy
echo 1 > /sys/devices/soc.0/bf020400.pm/reset_usb_ctrl
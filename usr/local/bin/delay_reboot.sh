#!/bin/sh

sleep 2
fw_setenv reboot 1
sync
echo "Config Reset" >/etc/config/reason_start
reboot

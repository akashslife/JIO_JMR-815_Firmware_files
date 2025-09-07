#!/bin/sh

BOOT_NUMBER=$1

echo "*** Setting image #$BOOT_NUMBER as Active! ***"
fw_setenv boot_number $BOOT_NUMBER

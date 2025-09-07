#!/bin/sh
#
# Unmounting an NFS shared directory
#

TARGET_DIR=`uci get alt-vdmc.Config.DlDirectory`

umount $TARGET_DIR

#!/bin/sh
#
# Mounting an NFS shared directory
#

show_usage()
{
  echo "nfs-mount.sh <IP address of NFS server> <remote directory>"
  exit 1
}

if [ $# -ne 2 ]; then
  show_usage
fi

# source= <IP address of NFS server>:<remote directory>
SOURCE_DIR=$1:$2
TARGET_DIR=`uci get alt-vdmc.Config.DlDirectory`
OPT='-o nolock,rsize=32768,wsize=32768'

# if target directory isn't exist, create it
if [ ! -d $TARGET_DIR ]
then
    mkdir -p $TARGET_DIR
fi

busybox mount $OPT $SOURCE_DIR $TARGET_DIR

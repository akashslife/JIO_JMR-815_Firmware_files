#!/bin/sh

MODEL_NAME=`cat /proc/device-tree/model | cut -d - -f2`
FILE_LINK="/tmp/config.bin"

/usr/local/bin/backup_config.sh backup
/usr/local/bin/backup_config.sh uibackup

if [ -f $FILE_LINK ];then
	rm -rf $FILE_LINK
fi

cd /nvm/etc/backup_config
tar cvf /upload/config.tar *
cd /upload
rm -rf /nvm/etc/backup_config

if update-tool --append NTLR$MODEL_NAMEconf config.tar --output /upload/config.img >/dev/null; then
  rm config.tar
  if uuencode -m config.img NTLM100 > $FILE_LINK; then
    rm config.img
  fi
fi

cd

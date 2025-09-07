#!/bin/sh


VERSION=FourGee3100
OPTION=version
OPTION_CMD=1
METHOD=tftp

# Check arguments

if [ $# -gt 0 ]; then
	# adjust upgrade option
	OPTION=$1
        case $OPTION in 
	"version")  OPTION_CMD=1 ;;
	"all")  OPTION_CMD=2 ;;
	"all_nvm")  OPTION_CMD=3 ;;
	*)
		echo "$OPTION is not supported. Use version/all/all_nvm only";
		exit 1;
		;;
	esac
fi

if [ $# -gt 1 ]; then
	# adjust version name (target directory)
	VERSION=$2
fi

if [ $# -gt 2 ]; then
	# adjust upgrade option
	METHOD=$3
        case $METHOD in 
	"tftp") ;;
	"dhcp") ;;
	*)
		echo "$METHOD is not supported. Use tftp/dhcp only";
		exit 1;
		;;
	esac
fi


echo  "Going to upgrade: option = $OPTION ($OPTION_CMD), Version = $VERSION, Method = $METHOD"
fw_setenv fg3100_bootfiledir $VERSION
fw_setenv download_method $METHOD
fw_setenv auto_update_option $OPTION_CMD
reboot




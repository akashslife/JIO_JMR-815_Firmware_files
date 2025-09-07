#!/bin/sh

bdinfo_sig=$(nanddump -p -s 0x40000 -l 0x800 -o /dev/mtd0 2>/dev/null | head -1 | awk ' {print $2$3$4$5} ')

#block_2_badmark=$(nanddump -p -s 0x40000 -l 0x800 -o --bb=dumpbad /dev/mtd0 2>/dev/null | awk 'BEGIN{i=0;} /OOB Data:/{if (i==0) print $3$4; i++} ')
#block_3_badmark=$(nanddump -p -s 0x60000 -l 0x800 -o --bb=dumpbad /dev/mtd0 2>/dev/null | awk 'BEGIN{i=0;} /OOB Data:/{if (i==0) print $3$4; i++} ')

if [ "$bdinfo_sig" == "bdf45678" ]; then
	echo "Board info signature detected ($bdinfo_sig)" > /dev/kmsg
else
	echo "Board signature not found ..."  > /dev/kmsg
	nand_manufacture_id=$(dmesg | grep "NAND device: Manufacturer ID:" | awk -F: '{ print $3}' | awk -F '[, ]' '{ print $2}')
	nand_chip_id=$(dmesg | grep "NAND device: Manufacturer ID:" | awk -F: '{ print $4}' | awk '{ print $1}')
	if [ "$nand_chip_id" == "0xaa" ] && [ "$nand_manufacture_id" == "0x2c" ]; then
		echo "Nand chip is MICRON MT46H64M16LFBF-5 (ID=$nand_chip_id) going to burn board info 0"  > /dev/kmsg
		flash_erase /dev/mtd0 0x40000 0x1
		nandwrite -p -s 0x40000 /dev/mtd0 /etc/bdinfo_0.bin
	elif [ "$nand_chip_id" == "0xba" ] && [ "$nand_manufacture_id" == "0xc8" ]; then
		echo "Nand chip is ESMT FM64D2G1Ga (ID=$nand_chip_id) going to burn board info 1"   > /dev/kmsg
		flash_erase /dev/mtd0 0x40000 0x1
		nandwrite -p -s 0x40000 /dev/mtd0 /etc/bdinfo_1.bin
	else
		echo "No board info available for this chip ID ( $nand_manufacture_id / $nand_chip_id)"   > /dev/kmsg
	fi
fi




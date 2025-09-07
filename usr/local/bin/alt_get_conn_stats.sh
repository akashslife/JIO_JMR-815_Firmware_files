#!/bin/sh
# Altair: this script is performing the listing of stations connected to the device

#temporary file
filename=/tmp/altcnsts

#state vars
bState=0
toPrint=0

#print hw and expired_time fields into $filename at reversive order
egrep "$1"/sta_info -e "hw|expired_time:" | awk '{print $2}' | sed '1!G;h;$!d' > $filename

#print only the connections with non-zero expiration types
while read -r line
do
 if [ $bState = 0 ] ; then
    if [ "$line" =  "0"  ] ; then
   	   toPrint=0 
    else
	   toPrint=1
    fi	
    
    bState=1
 else
     if [ $toPrint = 1 ] ; then 
        echo "$line"
     fi
     bState=0
 fi 

done < "$filename"

#remove the temp file
rm -f $filename

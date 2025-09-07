#!/bin/sh

echo read $2 bytes from $1

let i=0;
let addr=$1
while [ $i -lt $2 ]; do
        ADDR=`printf "0x%x\n" $addr`;
        echo "$ADDR:" `devmem $ADDR`;
        let addr=addr+4;
        let i=i+4;
done


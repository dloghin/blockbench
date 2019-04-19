#!/bin/bash

MAX_TIP=16
SUM=""
FILE="ethereum-block-size.csv"
echo "Size" > $FILE
for TIP in `seq 1 $MAX_TIP`; do
	TIP_HEX="0x`echo "obase=16; ibase=10; $TIP" | bc`"
	SIZE=`curl --data "{\"method\":\"eth_getBlockByNumber\",\"params\":[\"$TIP_HEX\",false],\"id\":1,\"jsonrpc\":\"2.0\"}" -H "Content-Type: application/json" -X POST localhost:8545 2> /dev/null | tr ',' '\n' | grep size | cut -d 'x' -f 2 | tr -d '"' | awk '{ print toupper($0) }'`
	if [ -z "$SUM" ]; then
		SUM=$SIZE
	else
		SUM="$SUM+$SIZE"
	fi
	echo "$SIZE" >> $FILE
done
echo "obase=10; ibase=16; $SUM" | bc

#!/bin/bash

. env.sh

TIP=`$GETH_BIN attach ipc:$ETH_DATA/geth.ipc --exec 'web3.eth.blockNumber' 2> /dev/null`
if [ -z "$TIP" ] || [[ "$TIP" =~ "Fatal" ]]; then
	echo 0
else
	echo $TIP
fi

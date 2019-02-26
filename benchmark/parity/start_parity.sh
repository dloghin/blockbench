#!/bin/bash

if [ $# -lt 5 ]; then
	echo "Usage: $0 CHAIN_DATA HOST LOGS PARITY_BIN IDX"
	exit 1
fi

CHAIN_DATA=$1
KEYS=$CHAIN_DATA/keys/PoA
HOST=$2
LOGS=$3
PARITY=$4
IDX=$5
cd `dirname ${BASH_SOURCE-$0}`

# remove chain data
rm -rf $CHAIN_DATA
mkdir -p $KEYS
mkdir -p $LOGS
# copy keys
cp keys/key* $KEYS/

nohup ${PARITY} --config config.toml.$IDX --rpcport 8545 --rpcaddr $HOST > $LOGS/log 2>&1 & 

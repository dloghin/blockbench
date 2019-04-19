#!/bin/bash

if [ $# -lt 1 ]; then
	echo "Usage: $0 IDX [EXTRA_FALGS]"
	exit 1
fi

HOME_DIR='/data/dumi/blockbench/benchmark/parity'
CHAIN_DATA='/tmp/chain-data'
LOGS='/data/dumi/blockbench/benchmark/parity/logs'
KEYS=$CHAIN_DATA/keys/PoA
HOST="0.0.0.0"
IDX=$1
EXTRA_FLAGS=$2

cd `dirname ${BASH_SOURCE-$0}`

PARITY_EXE='/users/dumi/git/parity-ethereum/target/release/parity'

killall -KILL parity

# remove chain data
rm -rf $CHAIN_DATA
mkdir -p $KEYS
mkdir -p $LOGS
# copy keys
cp keys/key* $KEYS/

nohup $PARITY_EXE --config config.toml.$IDX --rpcport 8545 --rpcaddr $HOST $EXTRA_FALGS > $LOGS/log 2>&1 & 

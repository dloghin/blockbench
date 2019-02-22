#!/bin/bash

ADDR="0.0.0.0"
if [ $# -gt 0 ]; then
	ADDR=$1
fi
	
cd `dirname ${BASH_SOURCE-$0}`
. env.sh

HOSTNAME=`hostname`

rm -rf $LOG_DIR
mkdir -p $LOG_DIR

nohup $GETH_BIN --datadir=$ETH_DATA --nodiscover --rpc --rpcaddr $ADDR --rpcport "8000" --rpccorsdomain "*" --gasprice 0 --maxpeers 32 --networkid 9119 --unlock 0 --password <(echo -n "") --mine --minerthreads 2 > $LOG_DIR/geth_log_$HOSTNAME 2>&1 &

sleep 1

for com in `cat $ETH_HOME/addPeer.txt`; do
  $GETH_BIN --exec $com attach ipc:/$ETH_DATA/geth.ipc
done

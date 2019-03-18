#!/bin/bash
#args: number_of_nodes
cd `dirname ${BASH_SOURCE-$0}`
. env.sh

HOSTNAME=`hostname`

rm -rf $LOG_DIR
mkdir -p $LOG_DIR
rm -rf $ETH_DATA
mkdir -p $ETH_DATA
rm -r $ETH_DAG
mkdir -p $ETH_DAG

if [ "$GETH_VER" == "1.4.18" ]; then
$GETH_BIN --datadir=$ETH_DATA init $ETH_HOME/CustomGenesis"_"$1".json" > $LOG_DIR/geth_init_$HOSTNAME 2>&1 &
$GETH_BIN --datadir=$ETH_DATA --password <(echo -n "") account new >> $LOG_DIR/geth_init_$HOSTNAME 2>&1 &
else
$GETH_BIN --datadir=$ETH_DATA --ethash.dagdir=$ETH_DAG init $ETH_HOME/CustomGenesis"_"$1".json" > $LOG_DIR/geth_init_$HOSTNAME 2>&1 &
$GETH_BIN --datadir=$ETH_DATA --ethash.dagdir=$ETH_DAG --password <(echo -n "") account new >> $LOG_DIR/geth_init_$HOSTNAME 2>&1 &
fi

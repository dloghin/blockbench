#!/bin/bash
#args: number_of_nodes
cd `dirname ${BASH_SOURCE-$0}`
. env.sh

mkdir -p $ETH_DATA

$GETH_BIN --datadir=$ETH_DATA init $ETH_HOME/CustomGenesis"_"$1".json"
$GETH_BIN --datadir=$ETH_DATA --password <(echo -n "") account new

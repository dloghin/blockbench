#!/bin/bash
if [ $# -lt 1 ]; then
	echo "Usage: $0 <IP addr>"
	exit 1
fi
ip_addr=$1

cd `dirname ${BASH_SOURCE-$0}`
. env.sh
    
$GETH_BIN --datadir=$ETH_DATA --rpc --rpcaddr 0.0.0.0 --rpcport "8000" --rpccorsdomain "*" --gasprice 0 --networkid 9119 --unlock 0 --password <(echo -n "") js <(echo 'console.log(admin.nodeInfo.enode);') 2>/dev/null |grep enode | perl -pe "s/\[\:\:\]/$ip_addr/g" | perl -pe "s/^/\"/; s/\s*$/\"/;"


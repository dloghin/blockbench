#!/bin/bash

HOST="localhost"
if [ $# -gt 0 ]; then
	HOST=$1
fi
echo $((`curl --data '{"method":"eth_blockNumber","params":[],"id":1,"jsonrpc":"2.0"}' -H "Content-Type: application/json" -X POST $HOST:8545 2> /dev/null | grep -oh "\w*0x\w*"`))

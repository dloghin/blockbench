#!/bin/bash

if [ $# -lt 1 ]; then
	echo "Usage: $0 <# nodes>"
	exit 1
fi

NNODES=$1

cd `dirname ${BASH_SOURCE-$0}`
. env.sh

# copy the latest env.sh to nodes and clients
for host in `cat $HOSTS`; do
  scp -oStrictHostKeyChecking=no env.sh CustomGenesis_$NNODES.json $HOSTS $CLIENTS $host:$ETH_HOME/
done

for host in `cat $CLIENTS`; do
  scp -oStrictHostKeyChecking=no env.sh $HOSTS $CLIENTS $host:$ETH_HOME/
done


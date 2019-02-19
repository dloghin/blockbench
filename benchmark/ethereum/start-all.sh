#!/bin/bash
#nodes

if [ $# -lt 1 ]; then
	echo "Usage: $0 <# nodes>"
	exit 1
fi
NNODES=$1

cd `dirname ${BASH_SOURCE-$0}`
. env.sh

# ./update-env.sh

rm -rf addPeer.txt
./gather.sh $1
sleep 3

i=0
for host in `cat $HOSTS`; do
  if [[ $i -lt $NNODES ]]; then
    echo "Starting mining node $host"
    ssh -oStrictHostKeyChecking=no $host $ETH_HOME/start-mining.sh
  fi
  let i=$i+1
done

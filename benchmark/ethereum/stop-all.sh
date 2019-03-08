#!/bin/bash
#arg nnodes
if [ $# -lt 1 ]; then
	echo "Usage: $0 <# nodes>"
	exit 1
fi

cd `dirname ${BASH_SOURCE-$0}`
. env.sh

NNODES=$1
i=0
for host in `cat $CLIENTS`; do
  echo "Stopping client $host"
  ssh -oStrictHostKeyChecking=no $host killall -KILL driver 
done

for host in `cat $HOSTS`; do
  if [[ $i -lt $NNODES ]]; then
    echo "Stopping node $host"
    ssh -oStrictHostKeyChecking=no $host $ETH_HOME/stop.sh
  fi
  let i=$i+1
done



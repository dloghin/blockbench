#!/bin/bash
#nnodes
if [ $# -lt 1 ]; then
	echo "Usage: $0 <# nodes>"
	exit 1
fi
cd `dirname ${BASH_SOURCE-$0}`
. env.sh 

i=0
for host in `cat $HOSTS`; do
  if [[ $i -lt $1 ]]; then
    echo "admin.addPeer("`ssh $host $ETH_HOME/enode.sh $host 2>/dev/null | grep enode`")" >> addPeer.txt
  fi
  let i=$i+1
  echo $i
done

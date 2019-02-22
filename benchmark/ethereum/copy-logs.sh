#!/bin/bash

if [ $# -lt 2 ]; then
	echo "Usage: $0 <# nodes> <# clients"
	exit 1
fi

set -x

cd `dirname ${BASH_SOURCE-$0}`
. env.sh

NP=$1
NC=$2

TSTAMP=`date +%F-%H-%M-%S`
MASTER_LOG_DIR="geth-logs-$TSTAMP"
mkdir -p $MASTER_LOG_DIR

# hosts
i=1
for peer in `cat $HOSTS`; do
	if [[ $i -gt $NP ]]; then
		break
	fi
	scp $peer:$LOG_DIR/geth* $MASTER_LOG_DIR/
	let i=$i+1
done

# clients
i=1
for client in `cat $CLIENTS`; do
        if [[ $i -gt $NC ]]; then
                break
        fi
        scp $client:$LOG_DIR/client* $MASTER_LOG_DIR/
	let i=$i+1
done

echo "Done."

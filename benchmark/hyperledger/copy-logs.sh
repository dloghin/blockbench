#!/bin/bash

if [ $# -lt 2 ]; then
	echo "Usage: $0 <# nodes> <# clients"
	exit 1
fi

# set -x

cd `dirname ${BASH_SOURCE-$0}`
. env.sh

NP=$1
NC=$2

if [ $# -ge 3 ]; then
	LOG_DIR=$3
else
	TSTAMP=`date +%F-%H-%M-%S`
	LOG_DIR="hl-logs-$TSTAMP"
fi
mkdir -p $LOG_DIR

# hosts
i=1
for peer in `cat $HOSTS`; do
	if [[ $i -gt $NP ]]; then
		break
	fi
	scp $peer:$HL_HOME/logs/hl* $LOG_DIR/
	let i=$i+1
done

# clients
i=1
for client in `cat $CLIENTS`; do
        if [[ $i -gt $NC ]]; then
                break
        fi
        scp $client:$HL_HOME/logs/client* $LOG_DIR/
	let i=$i+1
done

echo "Done."

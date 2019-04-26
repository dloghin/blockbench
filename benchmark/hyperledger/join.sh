#!/bin/bash

cd `dirname ${BASH_SOURCE-$0}`

MAX_TIP=2000
if [ $# -gt 0 ]; then
	MAX_TIP=$1
fi
TIP=0
while [ $TIP -lt $MAX_TIP ]; do
	sleep 0.2
	TIP=`./get-tip.sh`
done
echo "Last tip: $TIP"

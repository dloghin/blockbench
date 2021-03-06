#!/bin/bash

if [ $# -lt 2 ]; then
	echo "Usage: $0 <bench> <txrate> <log-folder>"
	exit 1
fi

cd `dirname ${BASH_SOURCE-$0}`

cp env_$1.sh env.sh

./run-bench.sh 8 8 8 $2 $3

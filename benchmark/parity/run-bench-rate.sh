#!/bin/bash

if [ $# -lt 2 ]; then
	echo "Usage: $0 <bench> <txrate> <log-folder>"
	exit 1
fi

cd /home/ubuntu/git/blockbench/benchmark/parity

python run.py start -$1 $2 $3

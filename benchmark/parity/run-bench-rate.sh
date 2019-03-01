#!/bin/bash

if [ $# -lt 2 ]; then
	echo "Usage: $0 <bench> <txrate> <log-folder>"
	exit 1
fi

cd `dirname ${BASH_SOURCE-$0}`

python run.py start -$1 $2 $3

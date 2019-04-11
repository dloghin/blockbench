#!/bin/bash
THREADS=$1
HOST=$2
LOG=$3
RATE=$4
WT=$5

export LD_LIBRARY_PATH="/usr/local/lib"

cd `dirname ${BASH_SOURCE-$0}`
EXE='../../src/macro/smallbank/driver'
nohup $EXE -db parity -threads $THREADS -ops 10000000 -endpoint $HOST -txrate $RATE -wt $WT > $LOG 2>&1 &

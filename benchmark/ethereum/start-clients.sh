#!/bin/bash
# args=THREADS index N txrate waittime
echo IN START_CLIENTS $1 $2 $3 $4 $5

cd `dirname ${BASH_SOURCE-$0}`
. env.sh

export LD_LIBRARY_PATH="/usr/local/lib"

rm -rf $LOG_DIR
mkdir -p $LOG_DIR
i=0
for host in `cat $HOSTS`; do
  #let n=i/2
  let n=i
  let i=i+1
  if [[ $n -eq $2 ]]; then
    cd $EXE_HOME
    if [ "$BENCHMARK" == "smallbank" ]; then
      nohup ./driver -db ethereum -ops 10000000 -threads $1 -endpoint $host:8000 -txrate $4 -wt $5 > $LOG_DIR/client_$host"_"$1 2>&1 &
    else
      nohup ./driver -db ethereum -threads $1 -P workloads/workloada.spec -endpoint $host:8000 -txrate $4 -wt $5 > $LOG_DIR/client_$host"_"$1 2>&1 &
    fi
  fi
done


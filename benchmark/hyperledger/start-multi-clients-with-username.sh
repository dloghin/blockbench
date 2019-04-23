#!/bin/bash
# Arguments: num_clients num_servers num_threads txrate [-drop]
if [ $# -lt 4 ]; then
	echo "Usage: $0 <num_clients> <num_servers> <num_threads> <txrate> [-drop]"
	exit 1
fi
NCLIENTS=$1
NSERVERS=$2
NTHREADS=$3
TXRATE=$4
DROP=$5

cd `dirname ${BASH_SOURCE-$0}`
. env.sh

echo "Starting multi-clients ($NCLIENTS) ..."

let i=0
# let K=$NCLIENTS/2
let K=$NCLIENTS
for client in `cat $CLIENTS`; do
  if [[ $i -lt $K ]]; then
    echo "Start client $client index $i"
    scp hosts-users start-clients-with-username.sh $client:$HL_HOME/
    ssh -oStrictHostKeyChecking=no $client "export LD_LIBRARY_PATH=/usr/local/lib && $HL_HOME/start-clients-with-username.sh $NTHREADS $i $NSERVERS $TXRATE"
  fi
  let i=$i+1
done

if [[ "$DROP" == "-drop" ]]; then
  let M=$NSERVERS*10+320
  let SR=$M-250
  sleep 250 
  let idx=$NSERVERS-4
  let i=0
  for server in `cat $HOSTS`; do
    if [[ $i -ge $idx ]]; then
      ssh -oStrictHostKeyChecking=no $server killall -KILL peer java 
      echo "Dropped "$server
    fi
    let i=$i+1
  done
  sleep $SR
  let i=0
  for client in `cat $CLIENTS`; do
    if [[ $i -lt $K ]]; then
      ssh -oStrictHostKeyChecking=no $client 'killall -KILL driver' 
    fi
    let i=$i+1
  done
else
  # let M=$NSERVERS*10+300
  let M=$WAIT_TIME
  sleep $M
  let i=0
  for client in `cat $CLIENTS`; do
    if [[ $i -lt $K ]]; then
      ssh -oStrictHostKeyChecking=no $client 'killall -KILL driver' 
    fi
    let i=$i+1
  done
fi


#!/bin/bash
# Args: num_nodes num_threads num_clients txrate [-drop]
if [ $# -lt 4 ]; then
	echo "Usage: $0 <num_nodes> <num_threads> <num_clients> <txrate> <log-folder> [-drop]"
	exit 1
fi
NNODES=$1
NCLIENTS=$3
NTHREADS=$2
TXRATE=$4
DROP=$6
# local logs dir
LLWD=$5

cd `dirname ${BASH_SOURCE-$0}`
. env.sh

echo "Hyperledger $BENCHMARK benchmark $NNODES nodes $NCLIENTS clients $NTHREADS threads $TXRATE txrate"

./stop-peers.sh
sleep 2
./start-peers.sh $NNODES
echo "Wait $WARMUP_TIME s for HL to warm-up..."
sleep $WARMUP_TIME

./start-multi-clients.sh $NCLIENTS $NNODES $NTHREADS $TXRATE $DROP &
BACK=$!
#python partition.py $NNODES
echo "Waiting for PID $BACK ..."
wait $BACK
./stop-peers.sh
sleep 5
./copy-logs.sh $NNODES $NCLIENTS $LLWD

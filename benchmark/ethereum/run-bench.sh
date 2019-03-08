#!/bin/bash
#arg num_nodes #num_threads num_clients tx_rate [-drop]

if [ $# -lt 4 ]; then
	echo "Usage: $0 <# nodes> <# threads> <# clients> <tx-rate> <log-dir> [-drop]"
	exit 1
fi
NNODES=$1
NTHREADS=$2
NCLIENTS=$3
TXRATE=$4
DROP=$6
# local logs dir
LLWD=$5

cd `dirname ${BASH_SOURCE-$0}`
. env.sh

echo "Ethereum $BENCHMARK benchmark $NNODES nodes $NCLIENTS clients $NTHREADS threads $TXRATE txrate"

./update-env.sh $NNODES

./stop-all.sh $NNODES

./init-all.sh $NNODES 
./start-all.sh $NNODES

# let M=240+40*$NNODES
let M=240
sleep $M
echo "Wait $M s for geth to warm-up..."

./start-multi-clients.sh $NCLIENTS $NNODES $NTHREADS $TXRATE $DROP
BACK=$!
#sleep 100
#python partition.py $1
wait $BACK
#./start-multi-clients.sh clients_$1 $1 $2
#./start-multi-clients.sh clients_8 $1 $2
./stop-all.sh $NNODES
./copy-logs.sh $NNODES $NCLIENTS $LLWD

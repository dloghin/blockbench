# Environment variables for Ethereum in Blockbench
# 
# If not set, ETH_HOME is the folder of this script. Please uncomment 
# and change according to your setup.
# ETH_HOME=
GETH_BIN="/users/dumi/git/go-ethereum/build/bin/geth"
#GETH_VER="1.4.18"
GETH_VER="1.8.15"

if [ -z "$ETH_HOME" ]; then
	cd `dirname ${BASH_SOURCE-$0}`
	ETH_HOME=`pwd`
fi
if [ -z "$GETH_BIN" ]; then
	echo "Please set the path to geth binary"
	exit 1
fi

HOSTS=$ETH_HOME/hosts
CLIENTS=$ETH_HOME/clients
ETH_DATA=$ETH_HOME/data
ETH_DAG=$ETH_HOME/dag
LOG_DIR=$ETH_HOME/logs

DEPLOYTIME=20
WAITTIME=320

# Define benchmark, which can be: donothing, ycsb or smallbank
# BENCHMARK=donothing
BENCHMARK=ycsb
# BENCHMARK=smallbank

# For ycsb and donothing, the driver is in src/macro/kvstore
EXE_HOME=$ETH_HOME/../../src/macro/kvstore

# For smallbank, the driver is in src/macro/smallbank (uncomment)
# EXE_HOME=$ETH_HOME/../../src/macro/smallbank


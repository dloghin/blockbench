#!/bin/bash

cd `dirname ${BASH_SOURCE-$0}`

HL_GO="/home/dumi/git/hyperledger++/go"
PEER="$HL_GO/src/github.com/hyperledger/fabric/.build/bin/peer"
if ! [ -e $PEER ]; then
	echo "Hyperledger peer executable not found: $PEER"
	exit 1
fi

HL_DRYPTO="/home/dumi/git/hyperledger++/fabric-samples/first-network/crypto-config/peerOrganizations/org1.example.com/peers/peer0.org1.example.com"

export FABRIC_CFG_PATH="/home/dumi/git/hyperledger++/fabric-samples/first-network"

export CORE_PEER_ID=peer0.org1.example.com
export CORE_PEER_ADDRESS=peer0.org1.example.com:7051
export CORE_PEER_LISTENADDRESS=0.0.0.0:7051
export CORE_PEER_CHAINCODEADDRESS=peer0.org1.example.com:7052
export CORE_PEER_CHAINCODELISTENADDRESS=0.0.0.0:7052
export CORE_PEER_GOSSIP_BOOTSTRAP=peer1.org1.example.com:8051
export CORE_PEER_GOSSIP_EXTERNALENDPOINT=peer0.org1.example.com:7051
export CORE_PEER_LOCALMSPID=Org1MSP

export CORE_VM_ENDPOINT=unix:///host/var/run/docker.sock
# the following setting starts chaincode containers on the same
# bridge network as the peers
# https://docs.docker.com/compose/networking/
# CORE_VM_DOCKER_HOSTCONFIG_NETWORKMODE=${COMPOSE_PROJECT_NAME}_byfn
export FABRIC_LOGGING_SPEC=INFO
# export FABRIC_LOGGING_SPEC=DEBUG
export CORE_PEER_TLS_ENABLED=true
export CORE_PEER_GOSSIP_USELEADERELECTION=true
export CORE_PEER_GOSSIP_ORGLEADER=false
export CORE_PEER_PROFILE_ENABLED=true
export CORE_PEER_TLS_CERT_FILE=$HL_CRYPTO/tls/server.crt
export CORE_PEER_TLS_KEY_FILE=$HL_CRYPTO/tls/server.key
export CORE_PEER_TLS_ROOTCERT_FILE=$HL_CRYPTO/tls/ca.crt

#rm -rf $CORE_PEER_FILE_SYSTEM_PATH
#mkdir -p $CORE_PEER_FILE_SYSTEM_PATH
#mkdir -p $LOG_DIR

# GO environment
export GOPATH=$HL_GO
export PATH=$PATH:$HL_GO/bin

# rocksdb lib
export LD_LIBRARY_PATH=/usr/local/lib

HOST=`hostname`

$PEER node start
# nohup $PEER node start > $LOG_DIR/hl_log_root_$HOST 2>&1 &
# GOTRACEBACK=crash $PEER node start 2>&1 | tee -a $LOG_DIR/hl_log_root_$HOST

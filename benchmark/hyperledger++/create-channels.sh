#!/bin/bash
#
# (c) Dumi Loghin 2019
#
SCRIPTS_DIR=$(dirname "$0")

cd $SCRIPTS_DIR

. env.sh

cd /opt/gopath/src/github.com/hyperledger/fabric/peer

echo -e "\e[31mCreate channels...\e[0m"

# Create channel for A accounts, B accounts and coordinator
peer channel create -o orderer.example.com:7050 -c $CHANNELA -f ./channel-transfer/channel-aacc/channel.tx --tls true --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem

peer channel create -o orderer.example.com:7050 -c $CHANNELB -f ./channel-transfer/channel-bacc/channel.tx --tls true --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem

peer channel create -o orderer.example.com:7050 -c $CHANNELC -f ./channel-transfer/channel-coord/channel.tx --tls true --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem

# Join channels
CORE_PEER_COMMITTER_LEDGER_ORDERER=orderer.example.com:7050 CORE_PEER_ADDRESS=peer0.org1.example.com:7051 peer channel join -b $CHANNELA.block
CORE_PEER_COMMITTER_LEDGER_ORDERER=orderer.example.com:7050 CORE_PEER_ADDRESS=peer1.org1.example.com:8051 peer channel join -b $CHANNELA.block
CORE_PEER_COMMITTER_LEDGER_ORDERER=orderer.example.com:7050 CORE_PEER_ADDRESS=peer0.org1.example.com:7051 peer channel join -b $CHANNELB.block
CORE_PEER_COMMITTER_LEDGER_ORDERER=orderer.example.com:7050 CORE_PEER_ADDRESS=peer1.org1.example.com:8051 peer channel join -b $CHANNELB.block
CORE_PEER_COMMITTER_LEDGER_ORDERER=orderer.example.com:7050 CORE_PEER_ADDRESS=peer0.org1.example.com:7051 peer channel join -b $CHANNELC.block
CORE_PEER_COMMITTER_LEDGER_ORDERER=orderer.example.com:7050 CORE_PEER_ADDRESS=peer1.org1.example.com:8051 peer channel join -b $CHANNELC.block

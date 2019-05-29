#!/bin/bash
#
# (c) Dumi Loghin 2019
#
SCRIPTS_DIR=$(dirname "$0")
cd $SCRIPTS_DIR

. env.sh install

echo -e "\e[31mInstall Transfer v2...\e[0m"

# Install chaincodes
CORE_PEER_ADDRESS=peer0.org1.example.com:7051 peer chaincode install -n $CHAINCODEA -v 1.0 -l golang -p github.com/blockbench/benchmark/contracts/hyperledger++/go/transfer-v2
CORE_PEER_ADDRESS=peer1.org1.example.com:8051 peer chaincode install -n $CHAINCODEA -v 1.0 -l golang -p github.com/blockbench/benchmark/contracts/hyperledger++/go/transfer-v2
CORE_PEER_ADDRESS=peer0.org1.example.com:7051 peer chaincode install -n $CHAINCODEB -v 1.0 -l golang -p github.com/blockbench/benchmark/contracts/hyperledger++/go/transfer-v2
CORE_PEER_ADDRESS=peer1.org1.example.com:8051 peer chaincode install -n $CHAINCODEB -v 1.0 -l golang -p github.com/blockbench/benchmark/contracts/hyperledger++/go/transfer-v2
CORE_PEER_ADDRESS=peer0.org1.example.com:7051 peer chaincode install -n $CHAINCODEC -v 1.0 -l golang -p github.com/blockbench/benchmark/contracts/hyperledger++/go/coordinator
CORE_PEER_ADDRESS=peer1.org1.example.com:8051 peer chaincode install -n $CHAINCODEC -v 1.0 -l golang -p github.com/blockbench/benchmark/contracts/hyperledger++/go/coordinator

# Init
CORE_PEER_ADDRESS=peer0.org1.example.com:7051 peer chaincode instantiate -o orderer.example.com:7050 --tls true --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem -C $CHANNELA -n $CHAINCODEA -l golang -v 1.0 -c '{"Args":["init","a"]}'
CORE_PEER_ADDRESS=peer0.org1.example.com:7051 peer chaincode instantiate -o orderer.example.com:7050 --tls true --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem -C $CHANNELB -n $CHAINCODEB -l golang -v 1.0 -c '{"Args":["init","b"]}'
CORE_PEER_ADDRESS=peer0.org1.example.com:7051 peer chaincode instantiate -o orderer.example.com:7050 --tls true --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem -C $CHANNELC -n $CHAINCODEC -l golang -v 1.0 -c '{"Args":["init"]}'

# Create Accounts
peer chaincode invoke -o orderer.example.com:7050 --tls true --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem --peerAddresses peer0.org1.example.com:7051 --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt --peerAddresses peer1.org1.example.com:8051 --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/peers/peer1.org1.example.com/tls/ca.crt -C $CHANNELA -n $CHAINCODEA -c '{"Args":["create","a1","20"]}'

peer chaincode invoke -o orderer.example.com:7050 --tls true --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem --peerAddresses peer0.org1.example.com:7051 --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt --peerAddresses peer1.org1.example.com:8051 --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/peers/peer1.org1.example.com/tls/ca.crt -C $CHANNELA -n $CHAINCODEA -c '{"Args":["create","a2","30"]}'

peer chaincode invoke -o orderer.example.com:7050 --tls true --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem --peerAddresses peer0.org1.example.com:7051 --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt --peerAddresses peer1.org1.example.com:8051 --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/peers/peer1.org1.example.com/tls/ca.crt -C $CHANNELB -n $CHAINCODEB -c '{"Args":["create","b1","20"]}'

peer chaincode invoke -o orderer.example.com:7050 --tls true --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem --peerAddresses peer0.org1.example.com:7051 --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt --peerAddresses peer1.org1.example.com:8051 --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/peers/peer1.org1.example.com/tls/ca.crt -C $CHANNELB -n $CHAINCODEB -c '{"Args":["create","b2","30"]}'

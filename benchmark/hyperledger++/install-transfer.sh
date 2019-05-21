#!/bin/bash

VER_FILE="chaincode_version.txt"
if [ -f $VER_FILE ]; then
  VER=`cat $VER_FILE`
  CHAINCODEA="transfercca$VER"
  CHAINCODEB="transferccb$VER"
  VER=$(($VER+1))
  echo $VER > $VER_FILE
else
  CHAINCODEA="transfercca"
  CHAINCODEB="transferccb"
  echo "1" > $VER_FILE
fi

# Install chaincodes
CORE_PEER_ADDRESS=peer0.org1.example.com:7051 peer chaincode install -n $CHAINCODEA -v 1.0 -l golang -p github.com/blockbench/benchmark/contracts/hyperledger-1+/go/transfer
CORE_PEER_ADDRESS=peer1.org1.example.com:8051 peer chaincode install -n $CHAINCODEA -v 1.0 -l golang -p github.com/blockbench/benchmark/contracts/hyperledger-1+/go/transfer
CORE_PEER_ADDRESS=peer0.org1.example.com:7051 peer chaincode install -n $CHAINCODEB -v 1.0 -l golang -p github.com/blockbench/benchmark/contracts/hyperledger-1+/go/transfer
CORE_PEER_ADDRESS=peer1.org1.example.com:8051 peer chaincode install -n $CHAINCODEB -v 1.0 -l golang -p github.com/blockbench/benchmark/contracts/hyperledger-1+/go/transfer

# Init
CORE_PEER_ADDRESS=peer0.org1.example.com:7051 peer chaincode instantiate -o orderer.example.com:7050 --tls true --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem -C aacc -n $CHAINCODEA -l golang -v 1.0 -c '{"Args":["init","a"]}'
CORE_PEER_ADDRESS=peer0.org1.example.com:7051 peer chaincode instantiate -o orderer.example.com:7050 --tls true --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem -C bacc -n $CHAINCODEB -l golang -v 1.0 -c '{"Args":["init","b"]}'

# Create Accounts
peer chaincode invoke -o orderer.example.com:7050 --tls true --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem --peerAddresses peer0.org1.example.com:7051 --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt --peerAddresses peer1.org1.example.com:8051 --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/peers/peer1.org1.example.com/tls/ca.crt -C aacc -n $CHAINCODEA -c '{"Args":["create","a1","20"]}'

peer chaincode invoke -o orderer.example.com:7050 --tls true --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem --peerAddresses peer0.org1.example.com:7051 --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt --peerAddresses peer1.org1.example.com:8051 --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/peers/peer1.org1.example.com/tls/ca.crt -C aacc -n $CHAINCODEA -c '{"Args":["create","a2","30"]}'

peer chaincode invoke -o orderer.example.com:7050 --tls true --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem --peerAddresses peer0.org1.example.com:7051 --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt --peerAddresses peer1.org1.example.com:8051 --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/peers/peer1.org1.example.com/tls/ca.crt -C bacc -n $CHAINCODEB -c '{"Args":["create","b1","20"]}'

peer chaincode invoke -o orderer.example.com:7050 --tls true --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem --peerAddresses peer0.org1.example.com:7051 --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt --peerAddresses peer1.org1.example.com:8051 --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/peers/peer1.org1.example.com/tls/ca.crt -C bacc -n $CHAINCODEB -c '{"Args":["create","b2","30"]}'




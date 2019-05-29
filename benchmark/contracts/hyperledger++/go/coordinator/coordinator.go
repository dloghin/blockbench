package main

import (
	"fmt"
	"strconv"

	"github.com/hyperledger/fabric/core/chaincode/shim"
	"github.com/hyperledger/fabric/protos/peer"
)

type Coordinator struct {}

// var STATE_STARTED string = "1"
var STATE_PREPARING string = "2"
var STATE_COMMITTED string = "3"
var STATE_ABORTED string = "4"

var txTab string = "txState_"
var prepareLogTab string = "prep_"
var shardTab string = "nshards_" // how many shards are expected

func toChaincodeArgs(args ...string) [][]byte {
	bargs := make([][]byte, len(args))
	for i, arg := range args {
		bargs[i] = []byte(arg)
	}
	return bargs
}

func main() {
	err := shim.Start(new(Coordinator))
	if err != nil {
		fmt.Printf("Error starting coordinator: %s", err)
	}
}

func (t *Coordinator) Init(stub shim.ChaincodeStubInterface) peer.Response {
	return shim.Success(nil)
}

func (t *Coordinator) Invoke(stub shim.ChaincodeStubInterface) peer.Response {
  function, args := stub.GetFunctionAndParameters()

	if function == "beginTx" {
		return t.beginTx(stub, args)
	} else if function == "updatePrepare" {
		return t.updatePrepare(stub, args)
	} else if function == "updatePrepareCheck" {
		return t.updatePrepareCheck(stub, args)
	} else if function == "updateCommitCheck" {
		t.updateCommitCheck(stub, args)
	} else if function == "query" {
    return t.query(stub, args)
  }

  return shim.Error("Received unknown function invocation: " + function)
}

// start a tx by initializing the log and state table
// args: nstates - the number of states to be locked
func (t *Coordinator) beginTx(stub shim.ChaincodeStubInterface, args []string) peer.Response {
  nstates := args[0]
  txid := stub.GetTxID()
  stub.PutState(txTab + txid, []byte(STATE_PREPARING))
  stub.PutState(shardTab + txid, []byte(nstates))
  return shim.Success([]byte(txid))
}

// add PrepareOK or PrepareNotOK message to the log
// update the count and state accordingly
// args: txid, status ("0" failed, "1" if OK)
func (t *Coordinator) updatePrepare(stub shim.ChaincodeStubInterface, args []string) peer.Response {
  txid := args[0]
  status := args[2]
  if val, _ := stub.GetState(prepareLogTab + txid); val == nil {
    stub.PutState(prepareLogTab + txid, []byte(status))
  } else {
    stub.PutState(prepareLogTab + txid, []byte(string(val) + ":" + status))
  }

  // fail, transition to ARBORT right away
  if status == "0" { 
    stub.PutState(txTab + txid, []byte(STATE_ABORTED))
    return shim.Success(nil)
  }

  val, _ := stub.GetState(shardTab + txid)
  count, _ := strconv.Atoi(string(val))
  count--
  stub.PutState(shardTab + txid, []byte(strconv.Itoa(count))) 
  if count == 0 {
    stub.PutState(txTab + txid, []byte(STATE_COMMITTED))
  }

  return shim.Success(nil)
}

// add PrepareOK or PrepareNotOK message to the log
// update the count and state accordingly
// args: txid, status ("0" failed, "1" if OK)
func (t *Coordinator) updatePrepareCheck(stub shim.ChaincodeStubInterface, args []string) peer.Response {
  txid := args[0]
  key := args[1]
  txChannel := args[2]
  txChaincode := args[3]

  // check lock
  status := "1"
  chainCodeArgs := toChaincodeArgs("checkLock", key, txid)
  response := stub.InvokeChaincode(txChaincode, chainCodeArgs, txChannel)
  if response.Status != shim.OK {
    status = "0"
  }

  if val, _ := stub.GetState(prepareLogTab + txid); val == nil {
    stub.PutState(prepareLogTab + txid, []byte(status))
  } else {
    stub.PutState(prepareLogTab + txid, []byte(string(val) + ":" + status))
  }

  // fail, transition to ARBORT right away
  if status == "0" { 
    stub.PutState(txTab + txid, []byte(STATE_ABORTED))
    return shim.Success(nil)
  }

  val, _ := stub.GetState(shardTab + txid)
  count, _ := strconv.Atoi(string(val))
  count--
  stub.PutState(shardTab + txid, []byte(strconv.Itoa(count))) 
  if count == 0 {
    stub.PutState(txTab + txid, []byte(STATE_COMMITTED))
  }

  return shim.Success(nil)
}

// add PrepareOK or PrepareNotOK message to the log
// update the count and state accordingly
// args: txid, status ("0" failed, "1" if OK)
func (t *Coordinator) updateCommitCheck(stub shim.ChaincodeStubInterface, args []string) peer.Response {
  txid := args[0]
  txChannel := args[1]
  txChaincode := args[2]

  // check lock
  status := "1"
  chainCodeArgs := toChaincodeArgs("checkCommit", txid)
  response := stub.InvokeChaincode(txChaincode, chainCodeArgs, txChannel)
  if response.Status != shim.OK {
    status = "0"
  }

  if val, _ := stub.GetState(prepareLogTab + txid); val == nil {
    stub.PutState(prepareLogTab + txid, []byte(status))
  } else {
    stub.PutState(prepareLogTab + txid, []byte(string(val) + ":" + status))
  }

  // fail, transition to ARBORT right away
  if status == "0" { 
    stub.PutState(txTab + txid, []byte(STATE_ABORTED))
    return shim.Success(nil)
  }

  val, _ := stub.GetState(shardTab + txid)
  count, _ := strconv.Atoi(string(val))
  count--
  stub.PutState(shardTab + txid, []byte(strconv.Itoa(count))) 
  if count == 0 {
    stub.PutState(txTab + txid, []byte(STATE_COMMITTED))
  }

  return shim.Success(nil)
}

// args: txid
// return: current state (PREPARING, ABORTED or COMMITTED)
func (t *Coordinator) query(stub shim.ChaincodeStubInterface, args []string) peer.Response {
  // return stateTab for the tx, either abort or commit
  txid := args[0]
  val, err := stub.GetState(txTab + txid)
  if (err != nil || val == nil) {
    return shim.Error("Tx doesn't exist")
  } else {
    return shim.Success(val)
  }
}


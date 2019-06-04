package main

import (
	"fmt"

	"github.com/hyperledger/fabric/core/chaincode/shim"
	"github.com/hyperledger/fabric/protos/peer"
)

type KVStore struct {}

var lockTab string = "lock"
var prepareTab string = "prepared"

func main() {
	err := shim.Start(new(KVStore))
	if err != nil {
		fmt.Printf("Error starting kv-store: %s", err)
	}
}

// Init the kv-store
func (t *KVStore) Init(stub shim.ChaincodeStubInterface) peer.Response {
	return shim.Success(nil)
}

func (t *KVStore) Invoke(stub shim.ChaincodeStubInterface) peer.Response {
  function, args := stub.GetFunctionAndParameters()

	if function == "write" {
		return t.write(stub, args)
	} else if function == "delete" {
		return t.del(stub, args)
	} else if function == "write_multikey" {
    return t.write_multikey(stub, args) 
  } else if function == "prepare_multiwrite" {
    return t.prepare_multiwrite(stub, args) 
  } else if function == "abort_multiwrite" {
    return t.abort_multiwrite(stub, args) 
  } else if function == "commit_multiwrite" {
    return t.commit_multiwrite(stub, args) 
  } else if function == "read" {
    return t.read(stub, args)
  }

	return shim.Error("Received unknown function invocation: " + function)
}

func (t *KVStore) write(stub shim.ChaincodeStubInterface, args []string) peer.Response {
	var key, value string
	var err error

	if len(args) != 2 {
		return shim.Error("Incorrect number of arguments. Expecting 2. name of the key and value to set")
	}

	key = args[0]
	value = args[1]
	err = stub.PutState(key, []byte(value))
	if err != nil {
		return shim.Error(err.Error())
	}

	return shim.Success(nil)
}

// args contains a list of keys, 
// ending with the value
// this will write (k1,val), (k2,val), ...
func (t *KVStore) write_multikey(stub shim.ChaincodeStubInterface, args []string) peer.Response {
  if len(args) < 2{
  	return shim.Error("Incorrect number of arguments. Expecting 2. name of the key and value to set")
  }

  keys := args[:len(args)-1]
  value := args[len(args)-1]
  for i := 0; i < len(keys); i++ {
	  if err := stub.PutState(keys[i], []byte(value)); err!=nil {
		  return shim.Error(err.Error())
	  }
  }

	return shim.Success(nil)
}

// args is a list of keys
// only prepare OK if all locks are not held
func (t *KVStore) prepare_multiwrite(stub shim.ChaincodeStubInterface, args []string) peer.Response {

  for _, key := range(args) {
    lockKey := lockTab + "_" + key
    if lockVal, _ := stub.GetState(lockKey); string(lockVal) == "1" {
      return shim.Error("Cannot prepare, holding lock for " + key)
    }
  }

  for _, key := range(args) {
    lockKey := lockTab +"_"+key
    stub.PutState(lockKey, []byte("1"))
  }
  stub.PutState(prepareTab+"_"+stub.GetTxID(), []byte("0"))
  return shim.Success(nil)
}

// first arg is the txid,
// rest are the keys to unlock
func (t *KVStore) abort_multiwrite(stub shim.ChaincodeStubInterface, args []string) peer.Response {
  for _, key := range(args[1:]) { 
    lockKey := lockTab + "_" + key
    stub.PutState(lockKey, []byte("0"))
  }
  return shim.Success(nil)
}

func (t *KVStore) commit_multiwrite(stub shim.ChaincodeStubInterface, args []string) peer.Response {
  if txVal, _:= stub.GetState(prepareTab + "_" + args[0]); string(txVal) == "1" {
    return shim.Error("Tx " + args[0] + " not prepared")
  }

  stub.PutState(prepareTab + "_" + args[0], []byte("1"))

  // write k,v
  keys := args[1:len(args)-1]
  val  := args[len(args)-1]
  for _,key := range(keys) {
    stub.PutState(key, []byte(val))
    stub.PutState(lockTab + "_" + key, []byte("0"))
  }

  return shim.Success(nil)
}

func (t *KVStore) del(stub shim.ChaincodeStubInterface, args []string) peer.Response {
	var key string
	var err error

	if len(args) != 1 {
		return shim.Error("Incorrect number of arguments. Expecting name of the key to delete")
	}

	key = args[0]
	err = stub.DelState(key)
	if err != nil {
		return shim.Error(err.Error())
	}

	return shim.Success(nil)
}

func (t *KVStore) read(stub shim.ChaincodeStubInterface, args []string) peer.Response {
	var key string
	var err error

	if len(args) != 1 {
		return shim.Error("Incorrect number of arguments. Expecting name of the key to query")
	}

	key = args[0]
	valAsbytes, err := stub.GetState(key)
	if err != nil {
		return shim.Error("{\"Error\":\"Failed to get state for " + key + "\"}")
	}

	return shim.Success(valAsbytes)
}

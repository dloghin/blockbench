package main

import (
	"fmt"

	"github.com/hyperledger/fabric/core/chaincode/shim"
	"github.com/hyperledger/fabric/protos/peer"
)

type KVStore struct {
}

func main() {
	err := shim.Start(new(KVStore))
	if err != nil {
		fmt.Printf("Error starting kv-store: %s", err)
	}
}

// Init
func (t *KVStore) Init(stub shim.ChaincodeStubInterface) peer.Response {
  fmt.Printf("In init.\n")
	return shim.Success(nil)
}

// Invoke
func (t *KVStore) Invoke(stub shim.ChaincodeStubInterface) peer.Response {
  function, args := stub.GetFunctionAndParameters()

	if function == "write" {
		return t.write(stub, args)
	} else if function == "delete" {
		return t.del(stub, args)
  } else if function == "read" {
    return t.read(stub, args)
  } else if function == "write_multikey" {
    return t.write_multikey(stub, args) 
	}

  return shim.Error("Received unknown function invocation: " + function)
}

func (t *KVStore) write(stub shim.ChaincodeStubInterface, args []string) peer.Response {
	var key, value string
	var err error

	if len(args) != 2 {
		return shim.Error("Incorrect number of arguments. Expecting 2 arguments: key and value")
	}

	key = args[0]
	value = args[1]
	err = stub.PutState(key, []byte(value))
	if err != nil {
		return shim.Error(err.Error())
	}

	return shim.Success(nil)
}

func (t *KVStore) write_multikey(stub shim.ChaincodeStubInterface, args []string) peer.Response {
  if len(args) < 2{
  	return shim.Error("Incorrect number of arguments. Expecting 2 arguments: key and value")
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
	var key, jsonResp string
	var err error

	if len(args) != 1 {
		return shim.Error("Incorrect number of arguments. Expecting name of the key to query")
	}

	key = args[0]
	valAsbytes, err := stub.GetState(key)
	if err != nil {
		jsonResp = "{\"Error\":\"Failed to get state for " + key + "\"}"
		return shim.Error(jsonResp)
	}

	return shim.Success(valAsbytes)
}

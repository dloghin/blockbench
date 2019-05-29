package main

import (
	"fmt"

	"github.com/hyperledger/fabric/core/chaincode/shim"
	"github.com/hyperledger/fabric/protos/peer"
)

type DoNothing struct {
}

func main() {
	err := shim.Start(new(DoNothing))
	if err != nil {
		fmt.Printf("Error starting donothing: %s", err)
	}
}

func (t *DoNothing) Init(stub shim.ChaincodeStubInterface) peer.Response {
	return shim.Success(nil)
}

func (t *DoNothing) Invoke(stub shim.ChaincodeStubInterface) peer.Response {
  function, _ := stub.GetFunctionAndParameters()
	if function == "donothing" {
		return shim.Success(nil)
	}
	return shim.Error("Received unknown function invocation: " + function)
}


package main

import (
	"fmt"
	"strconv"

	"github.com/hyperledger/fabric/core/chaincode/shim"
	"github.com/hyperledger/fabric/protos/peer"
)

type SmallBank struct {}

var MAX_ACCOUNTS int = 1000000
var BALANCE int = 10000
var accountTab string = "accounts"
var savingTab string = "saving"
var checkingTab string = "checking"
var lockTab string = "locks"  // map to lock
var prepareTab string = "prepared" // map to prepared txn_id

func main() {
	err := shim.Start(new(SmallBank))
	if err != nil {
		fmt.Printf("Error starting smallbank: %s", err)
	}
}

func (t *SmallBank) Init(stub shim.ChaincodeStubInterface) peer.Response {
  return shim.Success(nil)
}

func (t *SmallBank) Invoke(stub shim.ChaincodeStubInterface) peer.Response  {
  function, args := stub.GetFunctionAndParameters()

	if function == "amalgate" {
		return t.almagate(stub, args)
	} else if function == "getBalance" {
		return t.getBalance(stub, args)
	} else if function == "updateBalance" {
		return t.updateBalance(stub, args)
	} else if function == "updateSaving" {
		return t.updateSaving(stub, args)
	} else if function == "sendPayment" {
		return t.sendPayment(stub, args)
	} else if function == "writeCheck" {
		return t.writeCheck(stub, args)
	} else if function == "prepare_sendPayment" {
    return t.prepare_sendPayment(stub, args)
  } else if function == "prepare_sendPayment_NoContention" {
    return t.prepare_sendPayment_NoContention(stub, args)
  } else if function == "commit_sendPayment" {
    return t.commit_sendPayment(stub, args)
  } else if function == "commit_sendPayment_NoContention" {
    return t.commit_sendPayment_NoContention(stub, args)
  } else if function == "abort_sendPayment" {
    return t.abort_sendPayment(stub, args)
  } else if function == "get_lock" {
    return t.get_lock(stub, args)
  }

  return shim.Error("Received unknown function invocation: " + function)
}

func (t *SmallBank) get_lock(stub shim.ChaincodeStubInterface, args []string) peer.Response {
  key := checkingTab + "_" + args[0] 
  lockKey := lockTab + "_" + key
  if val, _ := stub.GetState(lockKey); string(val) == "1" {
    return shim.Success([]byte("locked"))
  } else {
    return shim.Success(nil)
  }
}

// prepare phase for SendPayment transactions
// args: account, type (payer or payee), balance
func (t *SmallBank) prepare_sendPayment(stub shim.ChaincodeStubInterface, args []string) peer.Response {
  // 1. get lock first
  key := checkingTab + "_" + args[0]
  lockKey := lockTab + "_" + key

  lockVal, err := stub.GetState(lockKey) 
  if err != nil {
    return shim.Error("Error reading lock")
  }
  if err == nil && string(lockVal) == "1" {
    return shim.Error("Cannot prepare, holding locks acc " + lockKey)
  }

  // check fund if payer
  if args[1] == "payer" {
    bal, err := stub.GetState(key)
    amount, _ := strconv.Atoi(args[2])
    if err != nil || bal == nil {
      stub.PutState(key, []byte(strconv.Itoa(BALANCE)))
    } else if b, _ := strconv.Atoi(string(bal)); b < amount {
      return shim.Error("Cannot prepared, insufficient fund")
    }
  }

  // if all ok 
  stub.PutState(lockKey, []byte("1"))
  // uuid is completely random
  stub.PutState(prepareTab + "_" + stub.GetTxID(), []byte("0"))
  return shim.Success(nil)
}

// prepare phase for SendPayment transactions
// args: account, type (payer or payee), balance
func (t *SmallBank) prepare_sendPayment_NoContention(stub shim.ChaincodeStubInterface, args []string) peer.Response {
  // 1. get lock first
  key := checkingTab + "_" + args[0]
  lockKey := lockTab + "_" + key
  stub.GetState(lockKey) 
  stub.PutState(lockKey, []byte("1"))
  stub.PutState(prepareTab + "_" + stub.GetTxID(), []byte("0"))
  return shim.Success(nil)
}

// args: txid, account
func (t *SmallBank) abort_sendPayment(stub shim.ChaincodeStubInterface, args []string) peer.Response {
  // 1. check that the txn is prepared
  lockKey := lockTab + "_" + args[1]
  stub.PutState(lockKey, []byte("0"))
  return shim.Success(nil)
}

// args: txid, account, type (payer or payee), balance
func (t *SmallBank) commit_sendPayment_NoContention(stub shim.ChaincodeStubInterface, args []string) peer.Response {
  // 1. check that the txn is prepared
  prepareKey := prepareTab + "_" + args[0]
  stub.PutState(prepareKey, []byte("1"))

  // 2. check type and commit accordingly
  accId := checkingTab + "_" + args[1]
  bal, _ := stub.GetState(accId)
  b, _ := strconv.Atoi(string(bal))
  amount, _ := strconv.Atoi(args[3])
  stub.PutState(accId, []byte(strconv.Itoa(b-amount)))

  // unlock
  stub.PutState(lockTab + "_" + accId, []byte("0"))
  // remove from prepare
  return shim.Success(nil)
}

// args: txid, account, type (payer or payee), balance
func (t *SmallBank) commit_sendPayment(stub shim.ChaincodeStubInterface, args []string) peer.Response {
  // 1. check that the txn is prepared
  prepareKey := prepareTab + "_" + args[0]
  if val, err := stub.GetState(prepareKey); err != nil || val == nil || string(val) == "1" { // 1 if duplicate
    return shim.Error("Txid not prepared " + string(val))
  } 
  stub.PutState(prepareKey, []byte("1"))

  // 2. check type and commit accordingly
  accId := checkingTab + "_" + args[1]
  bal, _ := stub.GetState(accId)
  b, _ := strconv.Atoi(string(bal))
  amount, _ := strconv.Atoi(args[3])
  if args[2] == "payer" {
    stub.PutState(accId, []byte(strconv.Itoa(b-amount)))
  } else {
    stub.PutState(accId, []byte(strconv.Itoa(b+amount)))
  }

  // unlock
  stub.PutState(lockTab + "_" + accId, []byte("0"))
  // remove from prepare
  return shim.Success(nil)
}

func (t *SmallBank) almagate(stub shim.ChaincodeStubInterface, args []string) peer.Response {
	var bal1, bal2 int
	var err error
	bal_str1, err := stub.GetState(savingTab + "_" + args[0])
	if err != nil || bal_str1 == nil {
		bal_str1 = []byte(strconv.Itoa(BALANCE))
	}
	bal_str2, err := stub.GetState(checkingTab + "_" + args[1])
	if err != nil || bal_str2 == nil {
		bal_str2 = []byte(strconv.Itoa(BALANCE))
	}

	bal1, err = strconv.Atoi(string(bal_str1))
	if err != nil {
		bal1 = BALANCE
	}
	bal2, err = strconv.Atoi(string(bal_str2))
	if err != nil {
		bal2 = BALANCE
	}
	bal1 += bal2

	err = stub.PutState(checkingTab + "_" + args[0], []byte(strconv.Itoa(0)))
	if err != nil {
		return shim.Error(err.Error())
	}

	err = stub.PutState(savingTab + "_" + args[1], []byte(strconv.Itoa(bal1)))
	if err != nil {
		return shim.Error(err.Error())
	}
  return shim.Success(nil)
}

func (t *SmallBank) getBalance(stub shim.ChaincodeStubInterface, args []string) peer.Response {
	var bal1, bal2 int
	var err error
	bal_str1, err := stub.GetState(savingTab + "_" + args[0])
	if err != nil || bal_str1 == nil {
		bal_str1 = []byte(strconv.Itoa(BALANCE))
	}
	bal_str2, err := stub.GetState(checkingTab + "_" + args[0])
	if err != nil || bal_str2 == nil {
		bal_str2 = []byte(strconv.Itoa(BALANCE))
	}

	bal1, err = strconv.Atoi(string(bal_str1))
	if err != nil {
		bal1 = BALANCE
	}
	bal2, err = strconv.Atoi(string(bal_str2))
	if err != nil {
		bal2 = BALANCE
	}
	bal1 += bal2

  return shim.Success(nil)
}

func (t *SmallBank) updateBalance(stub shim.ChaincodeStubInterface, args []string) peer.Response {
	bal_str, err2 := stub.GetState(checkingTab + "_" + args[0])
	if err2 != nil || bal_str == nil {
		bal_str = []byte(strconv.Itoa(BALANCE))
	}

	var bal1, bal2 int
	var err error
	bal1, err = strconv.Atoi(string(bal_str))
	if err != nil {
		bal1 = BALANCE
	}
	bal2, err = strconv.Atoi(args[1])
	if err != nil {
		return shim.Error(err.Error())
	}
	bal1 += bal2

	err = stub.PutState(checkingTab+"_"+args[0], []byte(strconv.Itoa(bal1)))
	if err != nil {
		return shim.Error(err.Error())
	}
  return shim.Success(nil)
}

func (t *SmallBank) updateSaving(stub shim.ChaincodeStubInterface, args []string) peer.Response {
	bal_str3, err3 := stub.GetState(savingTab + "_" + args[0])
	if err3 != nil || bal_str3 == nil {
		bal_str3 = []byte(strconv.Itoa(BALANCE))
	}
	var bal1, bal2 int
	var err error

	bal1, err = strconv.Atoi(string(bal_str3))
	if err != nil {
		bal1 = BALANCE
	}
	bal2, err = strconv.Atoi(args[1])
	if err != nil {
		return shim.Error(err.Error())
	}
	bal1 += bal2

	err = stub.PutState(savingTab + "_" + args[0], []byte(strconv.Itoa(bal1)))
	if err != nil {
		return shim.Error(err.Error())
	}
  return shim.Success(nil)
}

func (t *SmallBank) sendPayment(stub shim.ChaincodeStubInterface, args []string) peer.Response {
	var bal1, bal2, amount int
	var err error

	bal_str1, err := stub.GetState(checkingTab + "_" + args[0])
	if err != nil || bal_str1 == nil {
		bal_str1 = []byte(strconv.Itoa(BALANCE))
	}
	bal_str2, err := stub.GetState(checkingTab + "_" + args[1])
	if err != nil || bal_str2 == nil {
		bal_str2 = []byte(strconv.Itoa(BALANCE))
	}
	amount, err = strconv.Atoi(args[2])

	bal1, err = strconv.Atoi(string(bal_str1))
	if err != nil {
		bal1 = BALANCE
	}
	bal2, err = strconv.Atoi(string(bal_str2))
	if err != nil {
		bal2 = BALANCE
	}
	bal1 -= amount
	bal2 += amount

	err = stub.PutState(checkingTab + "_" + args[0], []byte(strconv.Itoa(bal1)))
	if err != nil {
		return shim.Error(err.Error())
	}

	err = stub.PutState(checkingTab + "_" + args[1], []byte(strconv.Itoa(bal2)))
	if err != nil {
		return shim.Error(err.Error())
	}

  return shim.Success(nil)
}

func (t *SmallBank) writeCheck(stub shim.ChaincodeStubInterface, args []string) peer.Response {
	bal_str2, err2 := stub.GetState(checkingTab + "_" + args[0])
	if err2 != nil || bal_str2 == nil {
		bal_str2 = []byte(strconv.Itoa(BALANCE))
	}
	bal_str3, err3 := stub.GetState(savingTab + "_" + args[0])
	if err3 != nil || bal_str3 == nil {
		bal_str3 = []byte(strconv.Itoa(BALANCE))
	}

	var bal1, bal2 int
	var err error
	var amount int
	bal1, err = strconv.Atoi(string(bal_str2))
	if err != nil {
		bal1 = BALANCE
	}
	bal2, err = strconv.Atoi(string(bal_str3))
	if err != nil {
		bal2 = BALANCE
	}
	amount, err = strconv.Atoi(args[1])
	if amount < bal1 + bal2 {
		err = stub.PutState(checkingTab + "_" + args[0], []byte(strconv.Itoa(bal1-amount-1)))
	} else {
		err = stub.PutState(checkingTab + "_" + args[0], []byte(strconv.Itoa(bal1-amount)))
	}
	if err != nil {
		return shim.Error(err.Error())
	}

  return shim.Success(nil)
}

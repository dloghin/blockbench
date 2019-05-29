package main

import (
	"fmt"
	"strconv"
	"strings"

	"github.com/hyperledger/fabric/core/chaincode/shim"
	"github.com/hyperledger/fabric/protos/peer"
)

var accountTab = "acc_"
var lockTab = "lock_"
var commitTab = "commit_"

var prefix string = ""

type Transfer struct{}

// Transform arguments into an array
func toChaincodeArgs(args ...string) [][]byte {
	bargs := make([][]byte, len(args))
	for i, arg := range args {
		bargs[i] = []byte(arg)
	}
	return bargs
}

func main() {
	err := shim.Start(new(Transfer))
	if err != nil {
		fmt.Printf("Error starting transfer: %s", err)
	}
}

// Init
func (t *Transfer) Init(stub shim.ChaincodeStubInterface) peer.Response {
	_, args := stub.GetFunctionAndParameters()
	if len(args) != 1 {
		return shim.Error("Init expecting one argument: account prefix")
	}
	prefix = args[0]
	return shim.Success(nil)
}

// Invoke
func (t *Transfer) Invoke(stub shim.ChaincodeStubInterface) peer.Response {
	function, args := stub.GetFunctionAndParameters()

	if function == "create" {
		return t.create(stub, args)
	} else if function == "transfer" {
		return t.transfer(stub, args)
	} else if function == "crossDeposit" {
		return t.crossDeposit(stub, args)
	} else if function == "deposit" {
		return t.deposit(stub, args)
	} else if function == "withdraw" {
		return t.withdraw(stub, args)
	} else if function == "rollbackWithdraw" {
		return t.rollbackWithdraw(stub, args)
	} else if function == "lockAccount" {
		return t.lockAccount(stub, args)
	} else if function == "unlockAccount" {
		return t.unlockAccount(stub, args)
	} else if function == "checkLock" {
		return t.checkLock(stub, args)
	} else if function == "checkCommit" {
		return t.checkCommit(stub, args)
	} else if function == "checktx" {
		return t.checktx(stub, args)
	} else if function == "query" {
		return t.query(stub, args)
	}
	return shim.Error("Received unknown function invocation: " + function)
}

/**
 * Create account with a certain value.
 */
func (t *Transfer) create(stub shim.ChaincodeStubInterface, args []string) peer.Response {
	var account string
	var value int
	var err error

	if len(args) != 2 {
		return shim.Error("Incorrect number of arguments. Expecting 2: account and value")
	}

	account = args[0]
	value, err = strconv.Atoi(args[1])
	if err != nil {
		return shim.Error("Invalid account value: " + args[1])
	}

	if !strings.HasPrefix(account, prefix) {
		return shim.Error("Invalid account: " + account)
	}

	key := accountTab + account
	err = stub.PutState(key, []byte(strconv.Itoa(value)))
	if err != nil {
		return shim.Error(err.Error())
	}

	return shim.Success(nil)
}

/**
 * Transfer inside the same channel / shard.
 */
func (t *Transfer) transfer(stub shim.ChaincodeStubInterface, args []string) peer.Response {
	if len(args) != 3 {
		return shim.Error("Incorrect number of arguments. Expecting 3: source, destination and amount")
	}

	src := args[0]
	dst := args[1]
	amount, err := strconv.Atoi(args[2])
	if err != nil {
		return shim.Error("Invalid amount value")
	}

	if !strings.HasPrefix(src, prefix) || !strings.HasPrefix(dst, prefix) {
		return shim.Error("Invalid accounts for current shard")
	}

	key_src := accountTab + src
	ret, err := stub.GetState(key_src)
	if err != nil {
		return shim.Error("Error getting balance")
	}
	src_balance, err := strconv.Atoi(string(ret))
	if err != nil {
		return shim.Error("Invalid balance value")
	}

	if amount > src_balance {
		return shim.Error("Insufficient funds")
	}

	key_dst := accountTab + dst
	ret, err = stub.GetState(key_dst)
	if err != nil {
		return shim.Error("Error getting balance")
	}
	dst_balance, err := strconv.Atoi(string(ret))
	if err != nil {
		return shim.Error("Invalid balance value")
	}

	updated_src_balance := src_balance - amount
	updated_dst_balance := dst_balance + amount

	err = stub.PutState(key_src, []byte(strconv.Itoa(updated_src_balance)))
	if err != nil {
		return shim.Error(err.Error())
	}

	err = stub.PutState(key_dst, []byte(strconv.Itoa(updated_dst_balance)))
	if err != nil {
		stub.PutState(src, []byte(strconv.Itoa(src_balance)))
		return shim.Error(err.Error())
	}

	return shim.Success(nil)
}

/**
 * Prepare by locking accounts for a specific transaction.
 */
func (t *Transfer) lockAccount(stub shim.ChaincodeStubInterface, args []string) peer.Response {
	if len(args) != 2 {
		return shim.Error("Incorrect number of arguments. Expecting 2: account, txid")
	}

	account := args[0]
	txid := args[1]
	key := lockTab + account
	lock, err := stub.GetState(key)
	fmt.Print(string(lock))
	if err != nil || lock != nil {
		return shim.Error("Account already locked: " + account)
	}

	err = stub.PutState(key, []byte(txid))
	if err != nil {
		return shim.Error(err.Error())
	}

	return shim.Success(lock)
}

/**
 * To be called by coordinator
 */
func (t *Transfer) checkLock(stub shim.ChaincodeStubInterface, args []string) peer.Response {
	if len(args) != 2 {
		return shim.Error("Incorrect number of arguments. Expecting 2: state_key, txid")
	}

	account := args[0]
	txid := args[1]
	key := lockTab + account
	lock, err := stub.GetState(key)
	if err != nil && string(lock) != txid {
		return shim.Error("Invalid lock")
	}

	return shim.Success(nil)
}

func (t *Transfer) unlockAccount(stub shim.ChaincodeStubInterface, args []string) peer.Response {
	if len(args) != 1 {
		return shim.Error("Incorrect number of arguments. Expecting 1: account")
	}

	account := args[0]
	key := lockTab + account
	stub.DelState(key)

	return shim.Success(nil)
}

/**
 * Withdraw and update the commit tab.
 */
func (t *Transfer) withdraw(stub shim.ChaincodeStubInterface, args []string) peer.Response {
	if len(args) != 3 {
		return shim.Error("Incorrect number of arguments. Expecting 3: account, amount, txid")
	}

	account := args[0]
	amount, err := strconv.Atoi(args[1])
	if err != nil {
		return shim.Error("Invalid amount value")
	}
	txid := args[2]

	if !strings.HasPrefix(account, prefix) {
		return shim.Error("Invalid account")
	}

	key := accountTab + account
	ret, err := stub.GetState(key)
	if err != nil {
		return shim.Error("Error getting balance")
	}
	balance, err := strconv.Atoi(string(ret))
	if err != nil {
		return shim.Error("Invalid balance value")
	}

	if amount > balance {
		return shim.Error("Insufficient funds")
	}

	balance = balance - amount

	err = stub.PutState(key, []byte(strconv.Itoa(balance)))
	if err != nil {
		return shim.Error(err.Error())
	}

	key = commitTab + txid
	err = stub.PutState(key, []byte(strconv.Itoa(amount)))
	if err != nil {
		return shim.Error(err.Error())
	}

	return shim.Success([]byte(txid))
}

func (t *Transfer) rollbackWithdraw(stub shim.ChaincodeStubInterface, args []string) peer.Response {
	if len(args) != 2 {
		return shim.Error("Incorrect number of arguments. Expecting 2: account, txid")
	}

	account := args[0]
	txid := args[1]

	if !strings.HasPrefix(account, prefix) {
		return shim.Error("Invalid account")
	}
	
	keyCommit := commitTab + txid
	ret, err := stub.GetState(keyCommit)
	if err != nil {
		return shim.Error(err.Error())
	}
	amount, err := strconv.Atoi(string(ret))
	if err != nil {
		return shim.Error("Invalid amount value")
	}
	
	keyAccount := accountTab + account
	ret, err = stub.GetState(keyAccount)
	if err != nil {
		return shim.Error("Error getting balance")
	}
	balance, err := strconv.Atoi(string(ret))
	if err != nil {
		return shim.Error("Invalid balance value")
	}
	
	balance = balance + amount
	
	err = stub.PutState(keyAccount, []byte(strconv.Itoa(balance)))
	if err != nil {
		return shim.Error(err.Error())
	}
	
	stub.DelState(keyCommit)
	
	return shim.Success([]byte(txid))
}

/**
 * Check a withdraw/deposit transaction by its id.
 */
func (t *Transfer) checktx(stub shim.ChaincodeStubInterface, args []string) peer.Response {
	if len(args) != 2 {
		return shim.Error("Incorrect number of arguments. Expecting 2: txid and amount")
	}

	txid := args[0]
	amount, err := strconv.Atoi(args[1])
	if err != nil {
		return shim.Error("Invalid amount value")
	}

	key := commitTab + txid
	ret, err := stub.GetState(key)
	if err != nil {
		return shim.Error("Error getting txid")
	}
	saved_amount, err := strconv.Atoi(string(ret))
	if err != nil {
		return shim.Error("Invalid saved amount value")
	}

	if amount != saved_amount {
		return shim.Error("Requested and saved amounts do not match")
	}

	return shim.Success([]byte(txid))
}

/**
 * Check a withdraw/deposit transaction by its id.
 */
func (t *Transfer) checkCommit(stub shim.ChaincodeStubInterface, args []string) peer.Response {
	if len(args) != 1 {
		return shim.Error("Incorrect number of arguments. Expecting 2: txid")
	}

	txid := args[0]
	key := commitTab + txid
	_, err := stub.GetState(key)
	if err != nil {
		return shim.Error("Error getting txid")
	}

	return shim.Success([]byte(txid))
}

/**
 * Deposit in the same channel / shard.
 */
func (t *Transfer) deposit(stub shim.ChaincodeStubInterface, args []string) peer.Response {
	if len(args) != 3 {
		return shim.Error("Incorrect number of arguments. Expecting 3: account, amount, txid")
	}

	account := args[0]
	amount, err := strconv.Atoi(args[1])
	if err != nil {
		return shim.Error("Invalid amount value")
	}
	txid := args[2]

	if !strings.HasPrefix(account, prefix) {
		return shim.Error("Invalid account")
	}

	key := accountTab + account
	ret, err := stub.GetState(key)
	if err != nil {
		return shim.Error("Error getting balance")
	}
	balance, err := strconv.Atoi(string(ret))
	if err != nil {
		return shim.Error("Invalid balance value")
	}

	balance = balance + amount

	err = stub.PutState(key, []byte(strconv.Itoa(balance)))
	if err != nil {
		return shim.Error(err.Error())
	}
	
	key = commitTab + txid
	err = stub.PutState(key, []byte(strconv.Itoa(amount)))
	if err != nil {
		return shim.Error(err.Error())
	}

	return shim.Success(nil)
}

/**
 * Deposit in this channel but check withdraw transaction from a different channel.
 * Parameters:
 * - destination account (current channel)
 * - amount (must match withdraw amount)
 * - source_chaincode_name (chaincode name on the withdraw channel)
 * - source_channel_name (withdraw channel name)
 * - withdraw_txid (withdraw transaction id, returned by withdraw transaction and cross-cheched here)
 */
func (t *Transfer) crossDeposit(stub shim.ChaincodeStubInterface, args []string) peer.Response {
	if len(args) != 5 {
		return shim.Error("Incorrect number of arguments. Expecting 5: destination, amount, source_chaincode_name, source_channel_name, txid")
	}

	dst_account := args[0]
	if !strings.HasPrefix(dst_account, prefix) {
		return shim.Error("Invalid destination account for current shard")
	}
	amount, err := strconv.Atoi(args[1])
	if err != nil {
		return shim.Error("Invalid amount value: " + err.Error())
	}
	src_cc := args[2]
	src_channel := args[3]
	txid := args[4]

	key_dst := accountTab + dst_account
	ret, err := stub.GetState(key_dst)
	if err != nil {
		return shim.Error("Error getting balance for destination")
	}
	dst_balance, err := strconv.Atoi(string(ret))
	if err != nil {
		return shim.Error("Invalid balance value")
	}

	// check txid in this channel (double-deposit)
	key := commitTab + txid
	ret, err = stub.GetState(key)
	if err == nil {
		return shim.Error(err.Error())
	}

	// check txid on remote channel (valid tx)
	chainCodeArgs := toChaincodeArgs("checktx", txid, strconv.Itoa(amount))
	response := stub.InvokeChaincode(src_cc, chainCodeArgs, src_channel)

	if response.Status != shim.OK {
		return shim.Error(response.Message)
	}

	updated_dst_balance := dst_balance + amount
	err = stub.PutState(key_dst, []byte(strconv.Itoa(updated_dst_balance)))
	if err != nil {
		return shim.Error(err.Error())
	}

	// save commit txid
	key = commitTab + txid
	err = stub.PutState(key, []byte(strconv.Itoa(amount)))
	if err != nil {
		return shim.Error(err.Error())
	}

	return shim.Success(nil)
}

/**
 * Query account value.
 */
func (t *Transfer) query(stub shim.ChaincodeStubInterface, args []string) peer.Response {
	if len(args) != 1 {
		return shim.Error("Incorrect number of arguments. Expecting 1: account")
	}

	account := args[0]
	if !strings.HasPrefix(account, prefix) {
		return shim.Error("Invalid account")
	}

	key := accountTab + account
	ret, err := stub.GetState(key)
	if err != nil {
		return shim.Error("Error getting balance")
	}

	return shim.Success([]byte("Balance: " + string(ret)))
}

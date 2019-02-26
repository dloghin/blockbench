NS=[8]
NODES=['10.0.0.{}'.format(x) for x in range(82,90)]

CLIENTS=['10.0.0.{}'.format(x) for x in range(90,98)]
PORT='8545'
#THREADS=[2,4,8,16,32]
#RATES=[1,2,4,8,12,16]
THREADS=[8]
RATES=[8]
TIMETORUN=300
DEPLOY_TIME=60

HOME_DIR='/data/dumi/blockbench/benchmark/parity'
CHAIN_DATA='/tmp/chain-data'
LOG_DIR='/data/dumi/blockbench/benchmark/parity/logs'
PARITY_EXE='/users/dumi/git/parity-ethereum/target/release/parity'
CLIENT_LOG='client_parity'

CLIENT_DRIVER='start_ycsb_client.sh'

enode_command = 'curl --data \'{{"jsonrpc": "2.0", "method": "parity_enode", "params":[], "id": 0}}\' -H "Content-Type: application/json" -X POST {}:{}'
add_peer = 'curl --data \'{{"jsonrpc": "2.0", "method": "parity_addReservedPeer", "params":["{}"], "id": 0}}\' -H "Content-Type: application/json" -X POST {}:{}'
kill_command = 'ssh -o StrictHostKeyChecking=no dinhtta@{} "killall -KILL {}"'
ssh_command = 'ssh -o StrictHostKeyChecking=no dinhtta@{} {}'

partition_cmd = './partition.sh {} {} {} &'
TIMEOUT=100

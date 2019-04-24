NS=[4]
NODES=['192.168.100.111', '192.168.100.112', '192.168.100.61', '192.168.100.62']
NODESUSERS=['ubuntu@192.168.100.111', 'ubuntu@192.168.100.112', 'pi@192.168.100.61', 'pi@192.168.100.62']

CLIENTS=['192.168.100.{}'.format(x) for x in range(202,206)]
PORT='8545'
#THREADS=[2,4,8,16,32]
#RATES=[1,2,4,8,12,16]
THREADS=[8]
RATES=[32]
TIMETORUN=300
DEPLOY_TIME=120

HOME_DIR='/home/ubuntu/git/blockbench/benchmark/parity'
CHAIN_DATA='/tmp/chain-data'
LOG_DIR='/home/ubuntu/git/blockbench/benchmark/parity/logs'
PARITY_EXE='/home/ubuntu/git/parity-ethereum/target/release/parity'
CLIENT_LOG='client_parity'

CLIENT_DRIVER='start_ycsb_client.sh'

enode_command = 'curl --data \'{{"jsonrpc": "2.0", "method": "parity_enode", "params":[], "id": 0}}\' -H "Content-Type: application/json" -X POST {}:{}'
add_peer = 'curl --data \'{{"jsonrpc": "2.0", "method": "parity_addReservedPeer", "params":["{}"], "id": 0}}\' -H "Content-Type: application/json" -X POST {}:{}'
kill_command = 'ssh -o StrictHostKeyChecking=no {} "killall -KILL {}"'
ssh_command = 'ssh -o StrictHostKeyChecking=no {} {}'

partition_cmd = './partition.sh {} {} {} &'
TIMEOUT=100

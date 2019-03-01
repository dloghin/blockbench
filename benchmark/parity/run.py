#!/bin/python
import os
import subprocess
import sys
from config import *
from partition import partition
import time
import datetime

MASTER_LOG_DIR=""

def execute(cmd):
  print(cmd)
  os.system(cmd)

def start_parity():
  # generate scripts
  os.system('python gen_config.py {}'.format(len(NODES)))

  idx = 1
  for node in NODES:
    cmd = "scp chain_spec.json config.toml.{} {}:{}".format(idx, node, HOME_DIR)
    execute(cmd)
    idx = idx + 1

  parity_script = '. {}/start_parity.sh {} {} {} {} {}'
  count=1
  for node in NODES:
    cmd = ssh_command.format(node, parity_script.format(HOME_DIR, CHAIN_DATA, node, LOG_DIR, PARITY_EXE, count))
    count = count +1
    execute(cmd)

def start_clients(threads,rate, log_dir, workload='ycsb'):
  cs = zip(CLIENTS,NODES)
  client_script = '. {}/start_{}_client.sh {} {}:{} {}/client_{}_{}_nodes_{}_threads_{}_rate {} {}'
  for c in CLIENTS:
    cmd = "ssh {} \"rm -rf {} && mkdir -p {}\"".format(c,LOG_DIR,LOG_DIR)
    execute(cmd)
  for (c,s) in cs:
    cmd = ssh_command.format(c, client_script.format(HOME_DIR, workload, threads, s, PORT, LOG_DIR, s, len(NODES), threads, rate, rate, DEPLOY_TIME))
    execute(cmd)

def copy_logs():
  global MASTER_LOG_DIR
  if MASTER_LOG_DIR != "":
    log_dir = MASTER_LOG_DIR
  else:
    log_dir = "parity-logs-{}".format(datetime.datetime.fromtimestamp(time.time()).strftime('%Y-%m-%d-%H-%M-%S'))
  cmd = "mkdir {}".format(log_dir)
  execute(cmd)
  for s in NODES:
    cms = "scp {}:{}/log {}/node-log-{}".format(s, LOG_DIR, log_dir, s)
    execute(cms)
  for c in CLIENTS:
    cmd = "scp {}:{}/client* {}/".format(c, LOG_DIR, log_dir)
    execute(cmd)

def get_enodes():
  results=[]
  for node in NODES:
     print enode_command.format(node,PORT)
     p = os.popen(enode_command.format(node,PORT)).read()
     p = p.split('"')
     for l in p:
      if l.startswith('enode'):
        results.append(l)
        break
  print results
  return results

def add_peers():
  enodes = get_enodes()
  for node in NODES:
    for en in enodes:
      os.system(add_peer.format(en,node,PORT))

def drop(nodes, n):
  # drop the last n nodes:
  for node in nodes[-n:]:
    print "Dropping node {}".format(node)
    os.system(kill_command.format(node, 'parity'))

def kill():
  for client in CLIENTS:
    os.system(kill_command.format(client, 'driver'))
  for node in NODES:
    os.system(kill_command.format(node, 'parity'))

def run_exp(log_file, threads, rates, sleep_time, is_security=False, dropping=False, workload='ycsb'):
  print("Parity {} benchmark {} nodes {} clients {} threads {} txrate".format(workload, len(NODES), len(CLIENTS), threads, rates))
  start_parity()
  time.sleep(30)
  add_peers()
  time.sleep(30)
  start_clients(threads, rates, log_file, workload)
  if (not is_security) and (not dropping):
    time.sleep(sleep_time)
  else:
    if is_security:
      # for security part
      time.sleep(100)
      partition(NODES, TIMEOUT)
      time.sleep(sleep_time-100-TIMEOUT)
    else: # is dropping
      time.sleep(250)
      drop(NODES, 4)
      time.sleep(sleep_time-250)
  kill()
  copy_logs()
  time.sleep(5)

def driver(is_security=False, is_fixed=False, is_drop=False, workload='ycsb'):
  global NODES, CLIENTS #ugly hack
  tmp_nodes = NODES
  tmp_clients = CLIENTS 
  if is_fixed or is_drop:
    tmp_clients = CLIENTS[:8]

  if '10.0.0.15' in tmp_nodes:
    tmp_nodes.remove('10.0.0.15')

  for n in NS: 
    NODES = tmp_nodes[:n]
    nclients = n
    if is_fixed or is_drop:
      nclients = 8

    CLIENTS = tmp_clients[:(nclients/2)] + tmp_clients[:(nclients/2)]
    print NODES
    print CLIENTS
    if sys.argv[1]=='start':
      os.system('mkdir -p {}'.format(CLIENT_LOG))
      for t in THREADS:
        for r in RATES: 
          run_exp(CLIENT_LOG, t, r, TIMETORUN, is_security, is_drop, workload)

    elif sys.argv[1]=='kill':
      kill()

if __name__=='__main__':
  error_msg = 'python run.py <start/kill> [-security/-fixed/-drop]\n'\
            + '     start/kill:     start or kill the processes\n'\
            + '                     with no othe argument, this will run the same\n'\
            + '                     number of clients and servers\n'\
            + '     -security:   run the security benchmark\n'\
            + '     -fixed:      run the scale benchmark with fixed node\n'\
            + '     -drop:       run the failure benchmark\n'\
            + '     -smallbank:  run the smallbank benchmark\n'\
            + '     -donothing:   run the donothing benchmark\n'
  if len(sys.argv)<2:
    print error_msg
    sys.exit(1)

  if len(sys.argv)>=4:
    RATES=[sys.argv[3]]

  if len(sys.argv)>=5:
    MASTER_LOG_DIR=sys.argv[4]

  if len(sys.argv)==2:
    driver(False, False, False, 'ycsb')
  elif sys.argv[2]=='-security':
    driver(True, False, False, 'ycsb')
  elif sys.argv[2]=='-fixed':
    driver(False, True, False, 'ycsb')
  elif sys.argv[2]=='-drop':
    driver(False, False, True, 'ycsb')
  elif sys.argv[2]=='-ycsb':
    driver(False, False, False, 'ycsb')
  elif sys.argv[2]=='-smallbank':
    driver(False, False, False, 'smallbank')
  elif sys.argv[2]=='-donothing':
    driver(False, False, False, 'donothing')
  else:
    print error_msg
    sys.exit(1)


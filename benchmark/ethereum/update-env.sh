#!/bin/bash

. env.sh

# copy the latest env.sh to nodes and clients
for host in `cat $HOSTS`; do
  scp -oStrictHostKeyChecking=no env.sh $HOSTS $CLIENTS $host:$ETH_HOME/
done

for host in `cat $CLIENTS`; do
  scp -oStrictHostKeyChecking=no env.sh $HOSTS $CLIENTS $host:$ETH_HOME/
done


#!/bin/bash

cd `dirname ${BASH_SOURCE-$0}`

killall -9 peer

./start-slave.sh 10.0.0.82 7

/usr/bin/time ./join.sh

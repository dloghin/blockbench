#!/bin/bash

BENCH_DIR=""
BIN_DIR=""

if ! [ -d "$BENCH_DIR" ] || [ -d "$BIN_DIR" ]; then
	echo "Please set BENCH_DIR and BIN_DIR first"
	exit 1
fi

cd $BENCH_DIR
./start_parity.sh /tmp/chain-data 127.0.0.1 logs $BIN_DIR 1

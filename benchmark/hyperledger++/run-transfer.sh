#!/bin/bash
#
# (c) Dumi Loghin 2019
#
SCRIPTS_DIR=$(dirname "$0")
cd $SCRIPTS_DIR

echo -e "\e[31mRun Transfer v1...\e[0m"

# Create channels
$SCRIPTS_DIR/create-channels.sh

# Install chaincodes
$SCRIPTS_DIR/install-transfer.sh

# Do some transfers
$SCRIPTS_DIR/transfer-v1.sh

#!/bin/bash
#
# (c) Dumi Loghin 2019
#
SCRIPTS_DIR=$(dirname "$0")
cd $SCRIPTS_DIR

echo -e "\e[31mRun Transfer v2...\e[0m"

# Create channels
$SCRIPTS_DIR/create-channels.sh

# Install chaincodes
$SCRIPTS_DIR/install-transfer-v2.sh

# Do some transfers
$SCRIPTS_DIR/transfer-v2-coordinator.sh
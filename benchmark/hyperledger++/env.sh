#!/bin/bash
#
# (c) Dumi Loghin 2019
#
export VER_FILE="chaincode_version.txt"
if [ -f $VER_FILE ]; then
	export VER=`cat $VER_FILE`
	if [ "$1" == "install" ]; then	
		VER=$(($VER+1))
		echo $VER > $VER_FILE
	fi
	export CHAINCODEA="transfercca$VER"
	export CHAINCODEB="transferccb$VER"
	export CHAINCODEC="coordinator$VER"
else
	export CHAINCODEA="transfercca"
	export CHAINCODEB="transferccb"
	export CHAINCODEC="coordinator"
	echo "0" > $VER_FILE
fi

export CHANNELA="aacc"
export CHANNELB="bacc"
export CHANNELC="coord"
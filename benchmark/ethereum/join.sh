#!/bin/bash

cd `dirname ${BASH_SOURCE-$0}`

TIME=0
WAITTIME=0.2
MAXTIP=`./get-tip.sh`
if [ -z "$MAXTIP" ] || [ $MAXTIP -eq 0 ]; then
	MAXTIP=300
fi
echo "Fast mode"
echo "Max tip: $MAXTIP"
./stop.sh
sleep 3
./init.sh 8
sleep 3
./start-mining.sh
CURRTIP=`./get-tip.sh`
while [ $CURRTIP -lt $MAXTIP ]; do
	#echo "C $CURRTIP"
	sleep $WAITTIME
	TIME=`echo $TIME+$WAITTIME | bc -l`
	CURRTIP=`./get-tip.sh`
done
echo "Last tip: $CURRTIP"
echo "Time: $TIME"

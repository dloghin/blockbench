#!/bin/bash

cd `dirname ${BASH_SOURCE-$0}`

EXTRA_FLAGS=""
TIME=0
WAITTIME=0.2
MAXTIP=`./get-tip.sh`
if [ -z "$MAXTIP" ] || [ $MAXTIP -eq 0 ]; then
	MAXTIP=300
fi
echo "Extra Flags: $EXTRA_FLAGS"
echo "Max tip: $MAXTIP"
./start_parity_extra.sh $EXTRA_FLAGS
CURRTIP=`./get-tip.sh`
while [ $CURRTIP -lt $MAXTIP ]; do
	#echo "C $CURRTIP"
	sleep $WAITTIME
	TIME=`echo $TIME+$WAITTIME | bc -l`
	CURRTIP=`./get-tip.sh`
done
echo "Last tip: $CURRTIP"
echo "Time: $TIME"

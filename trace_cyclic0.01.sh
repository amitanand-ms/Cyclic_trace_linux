#!/bin/bash
#Script Created by Amit Anand to take cyclic traces on Linux
#Need input as -d duration to run in seconds
#Need input for -r rotation period in seconds to rotate file 
#Need input in -f min  for file feeping period. 
#e.g if you want to take capture for 24 hours, rotate file every 5 minutes and keep trace files for last two hours use below command. 
#./trace_cyclic.sh -d 86400 -r 300 -f 120 > /dev/null 2>&1 &
while [ $# -gt 0 ]
do
        case "$1" in
           -d)dur="$2";shift;;
           -r)rotation="$2";shift;;
           -f)filetime="$2";shift;;
           *)echo >&2 \
            "Invalid input usage: valid options: -d <total duration to run in minutes>, -r <time duration to rotate in seconds>, -f <time duration for keeping files in minutes>"
             exit 1;;
           esac
shift
done
if [ -z $dur ] || [ -z $rotation ] || [ -z $filetime ] 
then
echo >&2 \
            "Invalid input usage: valid options: -d <total duration to run in minutes>, -r <time duration to rotate in seconds>, -f <time duration for keeping files in minutes>
             All three are must to give"
             exit 1
fi
mkdir ./capturedtraces
cd ./capturedtraces
i=1
while [ $i -lt  $dur ]
do
tcpdump -i any -w `date +%y%m%d-%H:%M:%S`.pcap -G $rotation -W 1
i=`expr $i + "$rotation"`;
find ./ -mmin +$filetime -type f -exec rm -fv {} \;&
done

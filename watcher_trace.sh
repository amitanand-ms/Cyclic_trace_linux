#!/bin/bash
#Script Created by Amit Anand to work as log watcher and triger cyclic traces stop or start based on condition 
#This works as watcher to trace_cyclic to start and / OR stop based on logs monitoring
#Need input as -d duration to run in seconds
#Need input for -r rotation period in seconds to rotate file
#Need input in -f min  for file feeping period.
#Need to set flag -w to stop or start operation
#Need input in -F as filename with path to monitor logs in 
#Need input in -s string to monitor in file
#optional input for check interval, by default it's 60 seconds but you could reset it using ci flag
#e.g if you want to start watcher to monitor /var/log/app.log for string "start the traces" and start capture for 24  hours file rotation 300sec and file retention for 120 mins.
#./watcher_trace.sh -w start -F /var/log/app.log -s "start the traces" -d 8400 -r 300 -f 120 2>&1 &
#By Default the check interval is 60 seconds which means it will check for string condition in log file after every 60 seconds. 
#You could modify it using optional ci flag, I.E if you want script to check for condition in log file every 10 seconds. 
#./watcher_trace.sh -w start -F /var/log/app.log -s "start the traces" -d 8400 -r 300 -f 120 -ci 10 2>&1 & 
while [ $# -gt 0 ]
do
        case "$1" in
           -d)dur="$2";shift;;
           -r)rotation="$2";shift;;
           -f)filetime="$2";shift;;
           -w)oper="$2";shift;;
           -F)filename="$2";shift;;
           -s)string="$2";shift;;
           -ci)ci="$2";shift;; 
           *)echo >&2 \
            "Invalid input usage: valid options: -d <total duration to run in minutes>, -r <time duration to rotate in seconds>, -f <time duration for keeping files in minutes>
             -F < File name to monitor >, -w < Stop or start > , -s <Log string to start or stop capture>, -ci <optional check interval in seconds>"
             exit 1;;
           esac
shift
done
echo $dur" " $rotation" " $filetime" " $oper" " $filename" " $string
if [ -z $ci ]
then
ci=60
fi
if [ ! -f $filename ]
then
date=`/usr/bin/date +%y%m%d-%H:%M:%S`
/usr/bin/echo $date "Cyclic trace watcher coudl not find file given to monitor" >> /var/log/messages
/usr/bin/echo $date "Cyclic trace watcher coudl not find file given to monitor"
exit
fi
tracefile=`/usr/bin/ls -larth ./trace_cyclic* | /usr/bin/head -n 1| /usr/bin/awk '{print $9}'`
if [ ! -f $tracefile ]
then 
date=`/usr/bin/date +%y%m%d-%H:%M:%S`
/usr/bin/echo $date "Cyclic trace script not found in watcher script directory exiting" >> /var/log/messages
/usr/bin/echo $date "Cyclic trace script not found in watcher script directory exiting"
fi
i=0 
while [ $i == 0 ]
do
case "$oper" in

start)
     if [ -z $dur ] || [ -z $rotation ] || [ -z $filetime ] || [ $dur -lt $rotation ]
     then
      echo >&2 \
            "Invalid input usage: valid options: -d <total duration to run in minutes>, -r <time duration to rotate in seconds>, -f <time duration for keeping files in minutes>
             All three are must to give and make sure that duration is higher than rotation period"
             exit 1
      fi
count=`/usr/bin/grep -i "$string" $filename | /usr/bin/wc -l`
if [ $count -gt 0 ]
then
runcheck=`/usr/bin/ps -aef | /usr/bin/grep -i trace_cyclic | wc -l`
if [ $runcheck -gt 1 ]
then
date=`/usr/bin/date +%y%m%d-%H:%M:%S`
/usr/bin/echo $date "Condition mathched but Cyclic traces already running exiting" >> /var/log/messages
exit
else
./$tracefile -d $dur -r $rotation -f $filetime  > /dev/null 2>&1 &
date=`/usr/bin/date +%y%m%d-%H:%M:%S`
/usr/bin/echo $date "Condition matched cyclic traces started" >>/var/log/messages
i=1
fi
fi
sleep $ci
;;
stop)
runcheck=`/usr/bin/ps -aef | /usr/bin/grep -i trace_cyclic | wc -l`
if [ $runcheck -eq 0 ]
then
#Cyclic traces not running exiting the script
date=`/usr/bin/date +%y%m%d-%H:%M:%S`
/usr/bin/echo $date "Trace cyclic not running could not run watcher in stop mode exiting" >> /var/log/messages
exit
else 
count=`/usr/bin/grep -i "$string" $filename | /usr/bin/wc -l`
if [ $count -gt 0 ]
then
/usr/bin/ps -aef | /usr/bin/grep trace_cyclic | /usr/bin/awk '{print "kill -9 " $2 }' | bash
date=`/usr/bin/date +%y%m%d-%H:%M:%S`
/usr/bin/echo $date "Condition matched stopping trace_cyclic script" >> /var/log/messages
i=1
fi
fi
sleep $ci
;;
*)/usr/bin/echo "Bad mode, watcher could run in either stop or start"
 exit;;
esac
done

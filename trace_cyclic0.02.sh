#!/bin/bash
#Script Created by Amit Anand to take cyclic traces on Linux
#Need input as -d duration to run in seconds
#Need input for -r rotation period in seconds to rotate file 
#Need input in -f min  for file feeping period. 
#e.g if you want to take capture for 24 hours, rotate file every 5 minutes and keep trace files for last two hours use below command. 
#./trace_cyclic.sh -d 86400 -r 300 -f 120 > /dev/null 2>&1 &
#-------------------------------------------------------------------------------------------
#Added new Features
# -h for help
# -z to zip file instead of purging
# -F to give capture filters
zip=0
filter=null

while [ $# -gt 0 ]
do
        case "$1" in
           -d)dur="$2";shift;;
           -r)rotation="$2";shift;;
           -f)filetime="$2";shift;;
	   -F)filter="$2";shift;;
	   -z)zip="$2";shift;;
	   -h)echo >&2 \
             " 
	      ----------------Usage----------------------
	      -d <total duration to run in seconds> 
	      -r <time duration to rotate capture file in seconds> 
	      -f <time duration for purging files in minutes, optional when zip is used instead of purge>
	      -z <Valid values 0 or 1 optional to set zipping of files to save space, purging is optional when zipping is used>
	      -F <Filter for tcpdump, make sure filter is correct and capturing network traffic>
	      This script will create folder in current directory as capturedtraces and will save files there"
             exit 1;;
           *)echo >&2 \
            "Invalid input usage: valid options: run with option -h to get help"
             exit 1;;
           esac
shift
done
if [ $zip == 0 ]
then
if [ -z $dur ] || [ -z $rotation ] || [ -z $filetime ] 
then
echo >&2 \
            "Invalid input usage: Use -h to get details about running script - Need Duration, Rotation and File keeping time to specify"
             exit 1
fi
else 
		if [ -z $dur ] || [ -z $rotation ]
		then
			echo >&2 \
            "Invalid input usage: valid options: -d <total duration to run in seconds>, -r <time duration to rotate in seconds> required when zip option is selected"
             exit 1
     fi
fi

i=1


case "$zip" in
	0)
		mkdir ./capturedtraces
                cd ./capturedtraces
        if [ "$filter" == "null" ]
           then
          while [ $i -lt  $dur ]
          do
          tcpdump -i any -w `date +%y%m%d-%H:%M:%S`.pcap -G $rotation -W 1
          i=`expr $i + "$rotation"`
          find ./ -mmin +$filetime -type f -exec rm -fv {} \;&
          done
	else
	   while [ $i -lt  $dur ]
          do
          tcpdump -i any -w `date +%y%m%d-%H:%M:%S`.pcap  "$filter" -G $rotation -W 1
          i=`expr $i + "$rotation"`
          find ./ -mmin +$filetime -type f -exec rm -fv {} \;&
          done
  fi
	  ;;
	1)
		mkdir ./capturedtraces
                cd ./capturedtraces
		ziptime=`expr $rotation \* 2`
		ziptime=`expr $ziptime / 60`
		if [ $filetime == 0 ]
		then
			filetime = 1
		fi

		if [ "$filter" == "null" ]
                 then
          while [ $i -lt  $dur ]
          do
          tcpdump -i any -w `date +%y%m%d-%H:%M:%S`.pcap -G $rotation -W 1
          i=`expr $i + "$rotation"`
          find ./ -mmin +$ziptime -type f  -name '*.pcap' -exec gzip -9 {} \;&
	  find ./ -mmin +$filetime -type f -exec rm -fv {} \;&
          done
               else
          while [ $i -lt  $dur ]
          do
          tcpdump -i any -w `date +%y%m%d-%H:%M:%S`.pcap "$filter" -G $rotation -W 1
          i=`expr $i + "$rotation"`
          find ./ -mmin +$ziptime -type f -name '*.pcap' -exec gzip -9 {} \;&
	  find ./ -mmin +$filetime -type f -exec rm -fv {} \;&
          done
  fi
          ;;
         *) echo >&2 \
            "Invalid input usage zip option could be either 1 or 0"
             exit 1;;
           esac
	


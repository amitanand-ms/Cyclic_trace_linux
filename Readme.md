This Script is created to take Cyclic network captures on Linux, 

We often use netsh in windows to keep on capturing traces in backend but do not have an equivalent in Linux. 

This program is designed to solve that purpose. 

To use this Script you need to provide three parameters. 

-d Total duration to run traces in seconds

-r Trace file rotation time in seconds

-f Time duration in minutes for which you want to keep traces

If you want to take capture for 24 hours, rotate file every 5 minutes and keep trace files for last two hours use below command.


#sudo ./trace_cyclic0.01.sh -d 86400 -r 300 -f 120 > /dev/null 2>&1 &

Script will create a folder in location from where you run it as capturedtraces

Once the issue reappears and you want to stop traces you may need to manually kill the script.

#sudo ps -aef | grep -i trace_cyclic

#kill -i pid shown by above command for trace_cyclic



For example

#ps -aef | grep -i trace

root     31340 30320  0 13:36 pts/2    00:00:00 sh -x trace_cyclic.sh -d 1440 -r 30 -f 10

Then command to stop is 

#sudo kill -9 31340

To get this script use below command. 

 #git clone https://github.com/amitanand-ms/Cyclic_trace_linux.git
 
 It will be in folder Cyclic_trace_linux

Trace file names would be in formay yymmdd-hh:mm:ss that way you based on the time of repro of the issue you could guess which file may have traces form that time. 

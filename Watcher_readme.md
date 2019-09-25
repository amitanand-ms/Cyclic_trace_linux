This Script could also be ran and monitored through Watcher. Watcher is develpoed to keep on monitoring a particular log file and take action to start or stop traces when issue triggers or gets away. To reduce human intervention for starting and stoping traces. 

By default check interval for triger in log file is 60 seconds, although with optional flag -ci this could be reduced or increased. This is the time frequency for watcher to go to log file and check for trigger. 

Imp: - Its required to purge the log file before starting watcher as it would monitor log file from the beigning. 

This works as watcher to trace_cyclic to start and / OR stop based on logs monitoring

For start operation.

Need input as -d duration to run in seconds
Need input for -r rotation period in seconds to rotate file
Need input in -f min  for file feeping period.
Need to set flag -w start for start operation
Need input in -F as filename with path to monitor logs in
Need input in -s string to monitor in file
optional input for check interval, by default it's 60 seconds but you could reset it using ci flag
e.g if you want to start watcher to monitor /var/log/app.log for string "start the traces" and start capture for 24  hours file rotation 300sec and file retention for 120 mins.
./watcher_trace.sh -w start -F /var/log/app.log -s "start the traces" -d 8400 -r 300 -f 120 2>&1 &

As shared above, by Default the check interval is 60 seconds which means it will check for string condition in log file after every 60 seconds.

You could modify it using optional ci flag

I.E if you want script to check for condition in log file every 10 seconds.

./watcher_trace.sh -w start -F /var/log/app.log -s "start the traces" -d 8400 -r 300 -f 120 -ci 10 2>&1 &


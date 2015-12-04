#!/bin/bash
#
# Sample automation script that 
#
# 1. Checks if passwordless login to server and client is working
# 2. Copies jar file to server and client machines
# 3. Runs server and waits for it to start listening to connections
# 4. Starts clients on client machines
# 5. Waits for clients to finish
# 6. Sends shut down signal to server and waits for it to shut down
# 7. Copies log files from client machine
# 8. Deletes log files from client and server machines
# 9. Processes log files
# 10. Plots the result with gnuplot
#

###############################
#
# Read command line arguments
#
###############################

function usage() {
	echo "Usage: --serverMachine=<address> --clientMachine=<address> --noOfClients=<int> --remoteUserName=<username> --experimentId=<id> --clientRunTime=<seconds>"
	exit -1
}



if [ "$#" != "9" ] 
then
	usage
fi



remoteUserName="ec2-user"


experimentId="$1"
noOfClients="$2" # per clientMachine
clientRunTime="$3"
workLoad="$4"
inThread="$5"
outThread="$6"
noOfMW="$7"
poolSize="$8"
repeatN="$9"

let totalClients=$noOfClients*$noOfMW


python client_RT_trace.py $experimentId $totalClients $inThread $outThread $noOfMW $poolSize $workLoad $repeatN
python middleware_TP_trace.py $experimentId $totalClients $inThread $outThread $noOfMW $poolSize $workLoad $repeatN



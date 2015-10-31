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
	echo "Usage: <exp_id(int)> <clientRunTime(seconds)> <workLoad={1,2,3,4}> <#InThread> <#OutThread> <#MW> <connexionPoolSize(int)>"
	exit -1
}

serverMachine1="52.29.91.37"
serverMachine2="52.29.90.169"

clientMachine1="52.29.90.219"
clientMachine2="52.29.90.228"
clientMachine3="52.29.90.183"
clientMachine4="52.29.90.181"
clientMachine5="52.28.234.141"
clientMachine6="52.29.90.233"

databaseMachine="52.29.90.229"
databasePort="4445"

if [ "$#" != "7" ] 
then
	usage
fi

remoteUserName="ec2-user"
experimentId="$1"
clientRunTime="$2"
workLoad="$3"
inThread="$4"
outThread="$5"
noOfMW="$6"
poolSize="$7"

experimentFolder='../experiments'

mkdir -p $experimentFolder/$experimentId

echo "Configuration : " >> $experimentFolder/$experimentId/config.txt
echo "   Workload design : $workLoad" >> $experimentFolder/$experimentId/config.txt
echo "   Client run time : $clientRunTime" >> $experimentFolder/$experimentId/config.txt
echo "   Number of InboxProcessingThreads : $inThread" >> $experimentFolder/$experimentId/config.txt
echo "   Number of OutboxProcessingThreads : $outThread" >> $experimentFolder/$experimentId/config.txt
echo "   Number of Middlewares : $noOfMW" >> $experimentFolder/$experimentId/config.txt
echo "   Database pool size : $poolSize" >> $experimentFolder/$experimentId/config.txt


# # Extract command line arguments
# TEMP=`getopt --long serverMachine:,clientMachine:,noOfClients:,remoteUserName:,experimentId:,clientRunTime: \
#      -n 'example.bash' -- "$@"`

# if [ $? != 0 ] ; then echo "Terminating..." >&2 ; exit 1 ; fi

# # Note the quotes around `$TEMP': they are essential!
# eval set -- "$TEMP"

# while true ; do
# 	echo "hhhh $1"
# 	echo "tttt $2"
#         case "$1" in
#                 --serverMachine1) serverMachine1="$2" ; shift 2 ;;
#                 --clientMachine1) clientMachine1="$2" ; shift 2 ;;
#                 --noOfClients) noOfClients="$2" ; shift 2 ;;
#                 --remoteUserName) remoteUserName="$2" ; shift 2 ;;
#                 --experimentId) experimentId="$2" ; shift 2 ;;
#                 --clientRunTime) clientRunTime="$2" ; shift 2 ;;
#                 --) shift ; break ;;
#                 *) echo "Internal error!" ; exit 1 ;;
#         esac
# done


# echo "server=${serverMachine1}"

# Check for correctness of the commandline arguments
# if [[ $serverMachine1 == "" || $clientMachine1 == "" || $noOfClients == "" || $remoteUserName == "" || $experimentId == "" ]]
# then
# 	usage $1
# fi

#####################################
#
# Copy server and clients to machines
#
#####################################

for i in 2 4 6 8 10
do

noOfClients="$i" # per clientMachine
let totalClients=$noOfClients*6

echo "Proceeding with number of Clients : $totalClients"

pathToRepo="."
rsa_key="/Users/florangmehlin/.ssh/ASL_Frankfurt.pem"
ec2Home="/home/ec2-user"

echo -ne "  Testing passwordless connection to the server machine and client machine... "
# Check if command can be run on server and client
success=$( ssh -i $rsa_key -o BatchMode=yes  $remoteUserName@$serverMachine1 echo ok 2>&1 )
if [ $success != "ok" ]
then
	echo "Passwordless login not successful for $remoteUserName on $serverMachine1. Exiting..."
	exit -1
fi

success=$( ssh -i $rsa_key -o BatchMode=yes  $remoteUserName@$clientMachine1 echo ok 2>&1 )
if [ $success != "ok" ]
then
	echo "Passwordless login not successful for $remoteUserName on $clientMachine1. Exiting..."
	exit -1
fi
echo "OK"



echo "  Copying server.jar to server machine: $serverMachine1 ... "
# Copy jar to server machine
scp -i $rsa_key "$pathToRepo"/asl_middleware/asl_middleware.jar $remoteUserName@$serverMachine1:.
echo "  Copying server.jar to server machine: $serverMachine2 ... "
# Copy jar to server machine
scp -i $rsa_key "$pathToRepo"/asl_middleware/asl_middleware.jar $remoteUserName@$serverMachine2:.

echo "  Copying client.jar to client machine: $clientMachine1 ... "
# Copy jar to client machine
scp -i $rsa_key "$pathToRepo"/asl_client/asl_client.jar $remoteUserName@$clientMachine1:.

echo "  Copying client.jar to client machine: $clientMachine2 ... "
# Copy jar to client machine
scp -i $rsa_key "$pathToRepo"/asl_client/asl_client.jar $remoteUserName@$clientMachine2:.

echo "  Copying client.jar to client machine: $clientMachine3 ... "
# Copy jar to client machine
scp -i $rsa_key "$pathToRepo"/asl_client/asl_client.jar $remoteUserName@$clientMachine3:.

echo "  Copying client.jar to client machine: $clientMachine4 ... "
# Copy jar to client machine
scp -i $rsa_key "$pathToRepo"/asl_client/asl_client.jar $remoteUserName@$clientMachine4:.

echo "  Copying client.jar to client machine: $clientMachine5 ... "
# Copy jar to client machine
scp -i $rsa_key "$pathToRepo"/asl_client/asl_client.jar $remoteUserName@$clientMachine5:.

echo "  Copying client.jar to client machine: $clientMachine6 ... "
# Copy jar to client machine
scp -i $rsa_key "$pathToRepo"/asl_client/asl_client.jar $remoteUserName@$clientMachine6:.


######################################
#
# Start database
#
######################################
#echo "  Starting the database"

#ssh -i $rsa_key $remoteUserName@$databaseMachine "$ec2Home/postgres/bin/pg_ctl -D $ec2Home/postgres/db -o \"-F -p $databasePort\" start > $ec2Home/db.out 2>&1" &

echo " Installing database"
ssh -i $rsa_key $remoteUserName@$databaseMachine "./partInstallDBEC2.sh"
while [ `ssh -i $rsa_key $remoteUserName@$databaseMachine "cat db.out | grep 'database system is ready to accept connections' | wc -l"` != 1 ]
do
	sleep 1
done 
echo "OK"

#echo " Resetting the database"
#ssh -i $rsa_key $remoteUserName@$databaseMachine "$ec2Home/postgres/bin/psql -p $databasePort -U asl_pg asl --command='select resetDB();'"

######################################
#
# Run server and clients
#
######################################


# Run server1
echo "  Starting the server"
ssh -i $rsa_key $remoteUserName@$serverMachine1 "java -jar asl_middleware.jar 1 $databaseMachine:$databasePort 4444 $inThread $outThread $poolSize 2>&1 > server.out " &

# Wait for the server to start up
echo -ne "  Waiting for the server1 to start up..."
sleep 1
while [ `ssh -i $rsa_key $remoteUserName@$serverMachine1 "cat server.out | grep 'Server listening' | wc -l"` != 1 ]
do
	sleep 1
done 
echo "OK"

# Run server2
echo "  Starting the server"
ssh -i $rsa_key $remoteUserName@$serverMachine2 "java -jar asl_middleware.jar 2 $databaseMachine:$databasePort 4444 $inThread $outThread $poolSize 2>&1 > server.out " &

# Wait for the server to start up
echo -ne "  Waiting for the server2 to start up..."
sleep 1
while [ `ssh -i $rsa_key $remoteUserName@$serverMachine2 "cat server.out | grep 'Server listening' | wc -l"` != 1 ]
do
	sleep 1
done 
echo "OK"



echo "  Start the clients on the client machine: $clientMachine1"
# Run the clients
clientIds=`seq $noOfClients`
pids=""
for clientId in $clientIds
do
	echo "    Start client: $clientId"
	ssh -i $rsa_key $remoteUserName@$clientMachine1 "java -jar asl_client.jar $serverMachine1 4444 $clientRunTime $workLoad $totalClients" &
	pids="$pids $!"
	ssh -i $rsa_key $remoteUserName@$clientMachine2 "java -jar asl_client.jar $serverMachine1 4444 $clientRunTime $workLoad $totalClients" &
	pids="$pids $!"
	ssh -i $rsa_key $remoteUserName@$clientMachine3 "java -jar asl_client.jar $serverMachine1 4444 $clientRunTime $workLoad $totalClients" &
	pids="$pids $!"
	ssh -i $rsa_key $remoteUserName@$clientMachine4 "java -jar asl_client.jar $serverMachine2 4444 $clientRunTime $workLoad $totalClients" &
	pids="$pids $!"
	ssh -i $rsa_key $remoteUserName@$clientMachine5 "java -jar asl_client.jar $serverMachine2 4444 $clientRunTime $workLoad $totalClients" &
	pids="$pids $!"
	ssh -i $rsa_key $remoteUserName@$clientMachine6 "java -jar asl_client.jar $serverMachine2 4444 $clientRunTime $workLoad $totalClients" &
	pids="$pids $!"
done

# Wait for the clients to finish
echo -ne "  Waiting for the clients to finish ... "
for f in $pids
do
	wait $f
done
echo "OK"

echo "  Sending shut down signal to server1"
# Send a shut down signal to the server
# Note: server.jar catches SIGHUP signals and terminates gracefully
ssh -i $rsa_key $remoteUserName@$serverMachine1 "killall java"

echo -ne "  Waiting for the server to shut down... "
# Wait for the server to gracefully shut down
while [ `ssh -i $rsa_key $remoteUserName@$serverMachine1 "cat server.out | grep 'Server shutting down' | wc -l"` != 1 ]
do
	sleep 1
done 
echo "OK"

echo "  Sending shut down signal to server2"
# Send a shut down signal to the server
# Note: server.jar catches SIGHUP signals and terminates gracefully
ssh -i $rsa_key $remoteUserName@$serverMachine2 "killall java"

echo -ne "  Waiting for the server to shut down... "
# Wait for the server to gracefully shut down
while [ `ssh -i $rsa_key $remoteUserName@$serverMachine2 "cat server.out | grep 'Server shutting down' | wc -l"` != 1 ]
do
	sleep 1
done 
echo "OK"

#echo "  Sending shut down signal to database"
# Send a shut down signal to the server
# Note: server.jar catches SIGHUP signals and terminates gracefully
#ssh -i $rsa_key $remoteUserName@$databaseMachine "killall postgres"

########################################
#
# Copy and process logs and plot graphs
#
########################################

# Copy log files from the clients

mkdir -p $experimentFolder/$experimentId/$totalClients
# mkdir -p $experimentId/MW1
# mkdir -p $experimentId/MW2
mkdir -p $experimentFolder/$experimentId/$totalClients/MW
mkdir -p $experimentFolder/$experimentId/$totalClients/DB
mkdir -p $experimentFolder/$experimentId/$totalClients/C

echo "  Copying log files from client machine1... "
scp -i $rsa_key $remoteUserName@$clientMachine1:./*.log $experimentFolder/$experimentId/$totalClients/C

echo "  Copying log files from client machine2... "
scp -i $rsa_key $remoteUserName@$clientMachine2:./*.log $experimentFolder/$experimentId/$totalClients/C

echo "  Copying log files from client machine3... "
scp -i $rsa_key $remoteUserName@$clientMachine3:./*.log $experimentFolder/$experimentId/$totalClients/C

echo "  Copying log files from client machine4... "
scp -i $rsa_key $remoteUserName@$clientMachine4:./*.log $experimentFolder/$experimentId/$totalClients/C

echo "  Copying log files from client machine5... "
scp -i $rsa_key $remoteUserName@$clientMachine5:./*.log $experimentFolder/$experimentId/$totalClients/C

echo "  Copying log files from client machine6... "
scp -i $rsa_key $remoteUserName@$clientMachine6:./*.log $experimentFolder/$experimentId/$totalClients/C

echo "  Copying log files from middleware machine1... "
scp -i $rsa_key $remoteUserName@$serverMachine1:./*.log* $experimentFolder/$experimentId/$totalClients/MW
# scp -i $rsa_key $remoteUserName@$serverMachine1:./server.out ./$experimentId/MW2

echo "  Copying log files from middleware machine2... "
scp -i $rsa_key $remoteUserName@$serverMachine2:./*.log* $experimentFolder/$experimentId/$totalClients/MW
# scp -i $rsa_key $remoteUserName@$serverMachine2:./server.out ./$experimentId/MW2

echo "  Copying log files from database machine... "
scp -i $rsa_key $remoteUserName@$databaseMachine:./db.out $experimentFolder/$experimentId/$totalClients/DB



# Cleanup
echo -ne "  Cleaning up files on client and server machines... "
ssh -i $rsa_key $remoteUserName@$clientMachine1 "rm ./*.log*"
ssh -i $rsa_key $remoteUserName@$clientMachine2 "rm ./*.log*"
ssh -i $rsa_key $remoteUserName@$clientMachine3 "rm ./*.log*"
ssh -i $rsa_key $remoteUserName@$clientMachine4 "rm ./*.log*"
ssh -i $rsa_key $remoteUserName@$clientMachine5 "rm ./*.log*"
ssh -i $rsa_key $remoteUserName@$clientMachine6 "rm ./*.log*"

ssh -i $rsa_key $remoteUserName@$serverMachine1 "rm ./*.log*"
ssh -i $rsa_key $remoteUserName@$serverMachine1 "rm ./*.out*"
ssh -i $rsa_key $remoteUserName@$serverMachine2 "rm ./*.log*"
ssh -i $rsa_key $remoteUserName@$serverMachine2 "rm ./*.out*"

ssh -i $rsa_key $remoteUserName@$databaseMachine "rm ./db.out"
ssh -i $rsa_key $remoteUserName@$databaseMachine "rm -rf /home/ec2-user/postgres/db"
ssh -i $rsa_key $remoteUserName@$databaseMachine "killall postgres"
echo "OK"

# Process the log files from the clients
echo "  Processing client log files"
cat $experimentFolder/$experimentId/$totalClients/C/*.log* | sort -n > $experimentFolder/$experimentId/$totalClients/C/allclients

done


if [ $workLoad == "1" ]
then
	python parseResponseTime_chain.py $experimentId $workLoad $inThread $outThread $noOfMW $poolSize

	python parseThroughput_chain.py $experimentId $workLoad $inThread $outThread $noOfMW $poolSize

	python parseDB_TPS.py $experimentId $workLoad $inThread $outThread $noOfMW $poolSize
elif [ $workLoad == "2" ]
then
	echo "2"
elif [ $workLoad == "3" ]
then
	echo "3"
elif [ $workLoad == "4" ]
then
	echo "4"
fi



# echo "  Generating trace.jpg with gnuplot"
# gnuplot << EOF
# set terminal jpeg
# set output '$experimentId/trace.jpg'
# set xlabel 'Time (s)'
# set ylabel 'Response Time (ms)'
# set title 'Trace log'
# set xrange [0:]
# set yrange [0:]
# plot '$experimentId/C/allclients' using (\$2/1000):2 with lp title "$experimentId"
# EOF


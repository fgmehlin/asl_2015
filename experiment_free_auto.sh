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

serverMachine1="52.29.92.171"
serverMachine2="52.29.89.232"
serverMachine3=""
serverMachine4=""

clientMachine1="52.29.116.73"
clientMachine2="52.28.226.121"
clientMachine3=""
clientMachine4=""

#databaseMachine="52.28.204.231"
#databasePort="4445"
databaseMachine="asl-db.cnq3qzzs08l2.eu-central-1.rds.amazonaws.com"
databasePort="5432"

if [ "$#" != "8" ] 
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

let totalClients=$noOfClients*$noOfMW

experimentFolder='../experiments'

mkdir -p $experimentFolder/$experimentId

echo "Configuration : " >> $experimentFolder/$experimentId/config.txt
echo "   Workload design : $workLoad" >> $experimentFolder/$experimentId/config.txt
echo "   Number of Clients per machine : $noOfClients" >> $experimentFolder/$experimentId/config.txt
echo "   Total number of Clients : $totalClients" >> $experimentFolder/$experimentId/config.txt
echo "   Client run time : $clientRunTime" >> $experimentFolder/$experimentId/config.txt
echo "   Number of InboxProcessingThreads : $inThread" >> $experimentFolder/$experimentId/config.txt
echo "   Number of OutboxProcessingThreads : $outThread" >> $experimentFolder/$experimentId/config.txt
echo "   Number of Middlewares : $noOfMW" >> $experimentFolder/$experimentId/config.txt
echo "   Database pool size : $poolSize" >> $experimentFolder/$experimentId/config.txt



#####################################
#
# Copy server and clients to machines
#
#####################################


pathToRepo="/Users/florangmehlin/Documents/ETHZ/Advanced Systems Lab_2015/project_repo"
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


if [ $noOfMW == "3" ]
then
	echo "  Copying server.jar to server machine: $serverMachine3 ... "
	# Copy jar to server machine
	scp -i $rsa_key "$pathToRepo"/asl_middleware/asl_middleware.jar $remoteUserName@$serverMachine3:.

	echo "  Copying client.jar to client machine: $clientMachine3 ... "
	# Copy jar to client machine
	scp -i $rsa_key "$pathToRepo"/asl_client/asl_client.jar $remoteUserName@$clientMachine3:.
fi
if [ $noOfMW == "4" ]
then
	echo "  Copying server.jar to server machine: $serverMachine3 ... "
	# Copy jar to server machine
	scp -i $rsa_key "$pathToRepo"/asl_middleware/asl_middleware.jar $remoteUserName@$serverMachine3:.
	echo "  Copying server.jar to server machine: $serverMachine4 ... "
	# Copy jar to server machine
	scp -i $rsa_key "$pathToRepo"/asl_middleware/asl_middleware.jar $remoteUserName@$serverMachine4:.

	echo "  Copying client.jar to client machine: $clientMachine3 ... "
	# Copy jar to client machine
	scp -i $rsa_key "$pathToRepo"/asl_client/asl_client.jar $remoteUserName@$clientMachine3:.
	echo "  Copying client.jar to client machine: $clientMachine4 ... "
	# Copy jar to client machine
	scp -i $rsa_key "$pathToRepo"/asl_client/asl_client.jar $remoteUserName@$clientMachine4:.	
fi



######################################
#
# Start database
#
######################################
#echo "  Starting the database"

# echo " Installing database"
# ssh -i $rsa_key $remoteUserName@$databaseMachine "./partInstallDBEC2.sh"
# while [ `ssh -i $rsa_key $remoteUserName@$databaseMachine "cat db.out | grep 'database system is ready to accept connections' | wc -l"` != 1 ]
# do
# 	sleep 1
# done 
# echo "OK"
#echo " Resetting the database"
#ssh -i $rsa_key $remoteUserName@$databaseMachine "$ec2Home/postgres/bin/psql -p $databasePort -U asl_pg asl --command='select resetDB();'"

######################################
#
# Run server and clients
#
######################################


# Run server1
echo "  Starting the server"
ssh -i $rsa_key $remoteUserName@$serverMachine1 "java -jar asl_middleware.jar 1 $databaseMachine:$databasePort 4444 $inThread $outThread $poolSize $noOfClients 2>&1 > server.out " &

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
ssh -i $rsa_key $remoteUserName@$serverMachine2 "java -jar asl_middleware.jar 2 $databaseMachine:$databasePort 4444 $inThread $outThread $poolSize $noOfClients 2>&1 > server.out " &

# Wait for the server to start up
echo -ne "  Waiting for the server2 to start up..."
sleep 1
while [ `ssh -i $rsa_key $remoteUserName@$serverMachine2 "cat server.out | grep 'Server listening' | wc -l"` != 1 ]
do
	sleep 1
done 
echo "OK"


if [ $noOfMW == "3" ]
then
	# Run server1
	echo "  Starting the server"
	ssh -i $rsa_key $remoteUserName@$serverMachine3 "java -jar asl_middleware.jar 1 $databaseMachine:$databasePort 4444 $inThread $outThread $poolSize $noOfClients 2>&1 > server.out " &

	# Wait for the server to start up
	echo -ne "  Waiting for the server1 to start up..."
	sleep 1
	while [ `ssh -i $rsa_key $remoteUserName@$serverMachine3 "cat server.out | grep 'Server listening' | wc -l"` != 1 ]
	do
		sleep 1
	done 
	echo "OK"
fi
if [ $noOfMW == "4" ]
then
	# Run server1
	echo "  Starting the server"
	ssh -i $rsa_key $remoteUserName@$serverMachine3 "java -jar asl_middleware.jar 1 $databaseMachine:$databasePort 4444 $inThread $outThread $poolSize $noOfClients 2>&1 > server.out " &

	# Wait for the server to start up
	echo -ne "  Waiting for the server1 to start up..."
	sleep 1
	while [ `ssh -i $rsa_key $remoteUserName@$serverMachine3 "cat server.out | grep 'Server listening' | wc -l"` != 1 ]
	do
		sleep 1
	done 
	echo "OK"

	# Run server1
	echo "  Starting the server"
	ssh -i $rsa_key $remoteUserName@$serverMachine4 "java -jar asl_middleware.jar 1 $databaseMachine:$databasePort 4444 $inThread $outThread $poolSize $noOfClients 2>&1 > server.out " &

	# Wait for the server to start up
	echo -ne "  Waiting for the server1 to start up..."
	sleep 1
	while [ `ssh -i $rsa_key $remoteUserName@$serverMachine4 "cat server.out | grep 'Server listening' | wc -l"` != 1 ]
	do
		sleep 1
	done 
	echo "OK"
fi


echo "  Start the clients on the client machine: $clientMachine1"
# Run the clients
clientIds=`seq $noOfClients`
pids=""
for clientId in $clientIds
do
	echo "    Start client: $clientId"
	ssh -i $rsa_key $remoteUserName@$clientMachine1 "java -jar asl_client.jar $serverMachine1 4444 $clientRunTime $workLoad $totalClients" &
	pids="$pids $!"
	ssh -i $rsa_key $remoteUserName@$clientMachine2 "java -jar asl_client.jar $serverMachine2 4444 $clientRunTime $workLoad $totalClients" &
	pids="$pids $!"



	if [ $noOfMW == "3" ]
	then
		ssh -i $rsa_key $remoteUserName@$clientMachine3 "java -jar asl_client.jar $serverMachine3 4444 $clientRunTime $workLoad $totalClients" &
		pids="$pids $!"
	fi

	if [ $noOfMW == "4" ]
	then
		ssh -i $rsa_key $remoteUserName@$clientMachine3 "java -jar asl_client.jar $serverMachine3 4444 $clientRunTime $workLoad $totalClients" &
		pids="$pids $!"	
		ssh -i $rsa_key $remoteUserName@$clientMachine4 "java -jar asl_client.jar $serverMachine4 4444 $clientRunTime $workLoad $totalClients" &
		pids="$pids $!"
	fi

	sleep 0.3
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


if [ $noOfMW == "3" ]
then
	echo "  Sending shut down signal to server3"
	# Send a shut down signal to the server
	# Note: server.jar catches SIGHUP signals and terminates gracefully
	ssh -i $rsa_key $remoteUserName@$serverMachine3 "killall java"

	echo -ne "  Waiting for the server to shut down... "
	# Wait for the server to gracefully shut down
	while [ `ssh -i $rsa_key $remoteUserName@$serverMachine3 "cat server.out | grep 'Server shutting down' | wc -l"` != 1 ]
	do
		sleep 1
	done 
	echo "OK"
fi

if [ $noOfMW == "4" ]
then
	echo "  Sending shut down signal to server3"
	# Send a shut down signal to the server
	# Note: server.jar catches SIGHUP signals and terminates gracefully
	ssh -i $rsa_key $remoteUserName@$serverMachine3 "killall java"

	echo -ne "  Waiting for the server to shut down... "
	# Wait for the server to gracefully shut down
	while [ `ssh -i $rsa_key $remoteUserName@$serverMachine3 "cat server.out | grep 'Server shutting down' | wc -l"` != 1 ]
	do
		sleep 1
	done 
	echo "OK"

	echo "  Sending shut down signal to server4"
	# Send a shut down signal to the server
	# Note: server.jar catches SIGHUP signals and terminates gracefully
	ssh -i $rsa_key $remoteUserName@$serverMachine4 "killall java"

	echo -ne "  Waiting for the server to shut down... "
	# Wait for the server to gracefully shut down
	while [ `ssh -i $rsa_key $remoteUserName@$serverMachine4 "cat server.out | grep 'Server shutting down' | wc -l"` != 1 ]
	do
		sleep 1
	done 
	echo "OK"
fi


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
mkdir -p $experimentFolder/$experimentId
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

echo "  Copying log files from server machine2... "
scp -i $rsa_key $remoteUserName@$serverMachine1:./*.log* $experimentFolder/$experimentId/$totalClients/MW

echo "  Copying log files from server machine2... "
scp -i $rsa_key $remoteUserName@$serverMachine2:./*.log* $experimentFolder/$experimentId/$totalClients/MW


if [ $noOfMW == "3" ]
then
	echo "  Copying log files from middleware machine3... "
	scp -i $rsa_key $remoteUserName@$serverMachine3:./*.log* $experimentFolder/$experimentId/$totalClients/MW

	echo "  Copying log files from client machine3... "
	scp -i $rsa_key $remoteUserName@$clientMachine3:./*.log* $experimentFolder/$experimentId/$totalClients/C
fi
if [ $noOfMW == "4" ]
then
	echo "  Copying log files from middleware machine3... "
	scp -i $rsa_key $remoteUserName@$serverMachine3:./*.log* $experimentFolder/$experimentId/$totalClients/MW

	echo "  Copying log files from client machine3... "
	scp -i $rsa_key $remoteUserName@$clientMachine3:./*.log* $experimentFolder/$experimentId/$totalClients/C

	echo "  Copying log files from middleware machine4... "
	scp -i $rsa_key $remoteUserName@$serverMachine4:./*.log* $experimentFolder/$experimentId/$totalClients/MW

	echo "  Copying log files from client machine4... "
	scp -i $rsa_key $remoteUserName@$clientMachine4:./*.log* $experimentFolder/$experimentId/$totalClients/C
fi


echo "  Copying log files from database machine... "
# scp -i $rsa_key $remoteUserName@$databaseMachine:./db.out $experimentFolder/$experimentId/$totalClients/DB



# Cleanup
echo -ne "  Cleaning up files on client and server machines... "
ssh -i $rsa_key $remoteUserName@$clientMachine1 "rm ./*.log*"
ssh -i $rsa_key $remoteUserName@$clientMachine2 "rm ./*.log*"

ssh -i $rsa_key $remoteUserName@$serverMachine1 "rm ./*.log*"
ssh -i $rsa_key $remoteUserName@$serverMachine1 "rm ./*.out*"
ssh -i $rsa_key $remoteUserName@$serverMachine2 "rm ./*.log*"
ssh -i $rsa_key $remoteUserName@$serverMachine2 "rm ./*.out*"

if [ $noOfMW == "3" ]
then
	ssh -i $rsa_key $remoteUserName@$clientMachine3 "rm ./*.log*"
	
	ssh -i $rsa_key $remoteUserName@$serverMachine3 "rm ./*.log*"
	ssh -i $rsa_key $remoteUserName@$serverMachine3 "rm ./*.out*"
fi
if [ $noOfMW == "4" ]
then
	ssh -i $rsa_key $remoteUserName@$clientMachine3 "rm ./*.log*"
	ssh -i $rsa_key $remoteUserName@$clientMachine4 "rm ./*.log*"

	ssh -i $rsa_key $remoteUserName@$serverMachine3 "rm ./*.log*"
	ssh -i $rsa_key $remoteUserName@$serverMachine3 "rm ./*.out*"
	ssh -i $rsa_key $remoteUserName@$serverMachine4 "rm ./*.log*"
	ssh -i $rsa_key $remoteUserName@$serverMachine4 "rm ./*.out*"
fi




# ssh -i $rsa_key $remoteUserName@$databaseMachine "rm ./db.out"
# ssh -i $rsa_key $remoteUserName@$databaseMachine "rm -rf /home/ec2-user/postgres/db"
# ssh -i $rsa_key $remoteUserName@$databaseMachine "killall postgres"
echo "OK"

Process the log files from the clients
echo "  Processing client log files"
cat $experimentFolder/$experimentId/$totalClients/C/*.log* | sort -n > $experimentFolder/$experimentId/$totalClients/C/allclients


echo "  Processing middleware log files"
cat $experimentFolder/$experimentId/$totalClients/MW/*1.log* | sort -n > $experimentFolder/$experimentId/$totalClients/MW/middleware_log_1_full.log
rm $experimentFolder/$experimentId/$totalClients/MW/*1.log*
cat $experimentFolder/$experimentId/$totalClients/MW/*2.log* | sort -n > $experimentFolder/$experimentId/$totalClients/MW/middleware_log_2_full.log
rm $experimentFolder/$experimentId/$totalClients/MW/*2.log*

if [ $noOfMW == "3" ]
then
	cat $experimentFolder/$experimentId/$totalClients/MW/*3.log* | sort -n > $experimentFolder/$experimentId/$totalClients/MW/middleware_log_3_full.log
	rm $experimentFolder/$experimentId/$totalClients/MW/*3.log*
fi
if [ $noOfMW == "4" ]
then
	cat $experimentFolder/$experimentId/$totalClients/MW/*3.log* | sort -n > $experimentFolder/$experimentId/$totalClients/MW/middleware_log_3_full.log
	rm $experimentFolder/$experimentId/$totalClients/MW/*3.log*
	cat $experimentFolder/$experimentId/$totalClients/MW/*4.log* | sort -n > $experimentFolder/$experimentId/$totalClients/MW/middleware_log_4_full.log
	rm $experimentFolder/$experimentId/$totalClients/MW/*4.log*
fi



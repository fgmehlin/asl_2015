#!/bin/bash

MW_JAR="asl_middleware/asl_middleware.jar"
CLI_JAR="asl_client/asl_client.jar"

serverMachine1="52.29.84.253"
clientMachine1="52.28.140.150"
serverMachine2="52.29.21.232"
clientMachine2="52.28.203.219"
username="ec2-user"


pathToRepo="/Users/florangmehlin/Documents/ETHZ/Advanced Systems Lab_2015/project_repo"
rsa_key="/Users/florangmehlin/.ssh/ASL_Frankfurt.pem"

# if [ -f "$MW_JAR" ]; then
# 	echo 'Deleting middleware jar'
#   	rm "$MW_JAR"
# fi

# if [ -f "$CLI_JAR" ]; then
# 	echo 'Deleting client jar'
#   	rm "$CLI_JAR"
# fi


# echo 'creating asl_middleware.jar'
# cd $pathToRepo/$MW_DIR
# ant jar
# echo 'creating asl_client.jar'
# cd $pathToRepo/$CLI_DIR
# ant jar



echo 'Copying middleware on server1 home'
scp -i $rsa_key "$pathToRepo/$MW_JAR" $username@$serverMachine1:.
echo 'Copying middleware on server2 home'
scp -i $rsa_key "$pathToRepo/$MW_JAR" $username@$serverMachine2:.
echo 'Copying client on client1 home'
scp -i $rsa_key "$pathToRepo/$CLI_JAR" $username@$clientMachine1:.
echo 'Copying client on client1 home'
scp -i $rsa_key "$pathToRepo/$CLI_JAR" $username@$clientMachine2:.






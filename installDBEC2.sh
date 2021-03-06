#!/bin/bash

PG_DB='postgresql-9.4.4' # your version of PG
PG_FOLDER='postgres'	
username='ec2-user'		 # your name
PORTNUMBER=4445			 # your port number
lcshit='en_US.UTF-8'
DB_DUMP='asl_db.pgsql'   # name of your DB dump
clusterHome="/home/ec2-user"
pathToPostgres="${clusterHome}/postgres"
PG_HBA="pg_hba.conf"
PSQL_CONF="postgresql.conf"


#if [ -d "/mnt/local/${fusername}" ]; then
#	echo "Creating /mnt/local/${username}"
#  	mkdir "/mnt/local/${username}"
#fi

#echo "cd /mnt/local/fgmehlin"
#cd "/mnt/local/${username}"
echo "------extracting postgres"
tar xjf "$PG_DB.tar.bz2"
cd "$PG_DB"
echo "------configuring"
./configure --prefix="/home/ec2-user/postgres"
echo "------postgres configured"
make
make install
echo "------postgres installed"

export LD_LIBRARY_PATH=$clusterHome/postgres/lib

LC_CTYPE=$lcshit

export LC_CTYPE

$pathToPostgres/bin/initdb -D $pathToPostgres/db 


cp -rf $clusterHome/$PG_HBA $pathToPostgres/db/
cp -rf $clusterHome/$PSQL_CONF $pathToPostgres/db/

$pathToPostgres/bin/postgres -D $pathToPostgres/db/ -p $PORTNUMBER -i -k $clusterHome > $clusterHome/db.out 2>&1 &

while [ `cat $clusterHome/db.out | grep 'database system is ready to accept connections' | wc -l` != 1 ]
do
	sleep 1
done 

$pathToPostgres/bin/createdb -p $PORTNUMBER -h $clusterHome

echo "Database created"


# Adapt this shit to your shit
$pathToPostgres/bin/psql -p $PORTNUMBER -h $clusterHome << EOF
create role asl_pg;
create database asl;
alter role asl_pg login;
alter database asl owner to asl_pg;
EOF

$pathToPostgres/bin/psql -p $PORTNUMBER -h $clusterHome -U asl_pg asl < $clusterHome/$DB_DUMP




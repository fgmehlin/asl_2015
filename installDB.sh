#!/bin/bash

PG_DB='postgresql-9.4.4'
PG_FOLDER='postgres'
username='fgmehlin'
PORTNUMBER=4445
lcshit='en_US.UTF-8'
DB_DUMP='asl_db.pgsql'
socketPath="/mnt/local/${username}"
pathToPostgres="${socketPath}/postgres"


if [ -d "/mnt/local/${fusername}" ]; then
	echo "Creating /mnt/local/${username}"
  	mkdir "/mnt/local/${username}"
fi

echo "cd /mnt/local/fgmehlin"
cd "/mnt/local/${username}"
echo "extracting postgres"
tar xjf "$PG_DB.tar.bz2"
cd "$PG_DB"
./configure --prefix="/mnt/local/${username}/postgres"
echo "postgres configured"
make
make install
echo "postgres installed"

export LD_LIBRARY_PATH=/mnt/local/$username/postgres/lib

LC_CTYPE=$lcshit

export LC_CTYPE

$pathToPostgres/bin/initdb -D $pathToPostgres/db 

$pathToPostgres/bin/postgres -D $pathToPostgres/db/ -p $PORTNUMBER -i -k $socketPath >/mnt/local/$username/db.out 2>&1 &

while [ `cat db.out | grep 'database system is ready to accept connections' | wc -l` != 1 ]
do
	sleep 1
done 

$pathToPostgres/bin/createdb -p 4445 -h $socketPath

echo "Database created"

$pathToPostgres/postgres/bin/psql -p 4445 -h $socketPath << EOF
create role asl_pg;
create database asl;
alter role asl_pg login;
alter database asl owner to asl_pg;
EOF

$pathToPostgres/postgres/bin/psql -p 4445 -h $socketPath -U asl_pg asl < $DB_DUMP




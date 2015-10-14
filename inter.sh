#!/bin/bash

PG_DB='postgresql-9.4.4'
PG_FOLDER='postgres'
username='fgmehlin'
PORTNUMBER=4445
lcshit='en_US.UTF-8'
DB_DUMP='asl_db.pgsql'
socketPath=/mnt/local/$username


/mnt/local/$username/postgres/bin/postgres -D /mnt/local/$username/postgres/db/ -p $PORTNUMBER -i -k $socketPath $>/mnt/local/$fgmehlin/db.out

/mnt/local/$username/postgres/bin/createdb -p 4445 -h $socketPath

echo "Database created"

/mnt/local/$username/postgres/bin/psql -p 4445 -h $socketPath << EOF
create role asl_pg;
create database asl;
alter role asl_pg login;
alter database asl owner to asl_pg;
EOF

/mnt/local/$username/postgres/bin/psql -p 4445 -h $socketPath -U asl_pg asl < $DB_DUMP




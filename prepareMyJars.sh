#!/bin/bash

MW_DIR="asl_middleware"
CLI_DIR="asl_client"

MW_JAR="asl_middleware/asl_middleware.jar"
CLI_JAR="asl_client/asl_client.jar"
DB_DUMP="asl_db.pgsql"
DB_CLEAN_DUMP="asl_db_clean.pgsql"
PG_DB="postgresql-9.4.4.tar.bz2"
SCRIPT_DB="installDB.sh"
EXP_SC="experiment.sh"
PG_HBA="pg_hba.conf"
PSQL_CONF="postgresql.conf"

cd "/Documents/ETHZ/Advanced Systems Lab_2015/project_repo"

if [ -f "$MW_JAR" ]; then
	echo 'Deleting middleware jar'
  	rm "$MW_JAR"
fi

if [ -f "$CLI_JAR" ]; then
	echo 'Deleting client jar'
  	rm "$CLI_JAR"
fi

if [ -f "$DB_DUMP" ]; then
	echo 'Deleting db dump'
  	rm "$DB_DUMP"
fi


echo 'creating asl_middleware.jar'
cd "$MW_DIR"
ant jar
echo 'creating asl_client.jar'
cd ../"$CLI_DIR"
ant jar
cd ..

echo 'copying clean database dump'

cp "$DB_CLEAN_DUMP" "$DB_DUMP"

if ! (ssh fgmehlin@dryad02.ethz.ch '[ -d /mnt/local/fgmehlin ]'); then
	ssh fgmehlin@dryad02.ethz.ch 'mkdir /mnt/local/fgmehlin'
fi

if ! (ssh fgmehlin@dryad03.ethz.ch '[ -d /mnt/local/fgmehlin ]'); then
	ssh fgmehlin@dryad03.ethz.ch 'mkdir /mnt/local/fgmehlin'
fi

if ! (ssh fgmehlin@dryad04.ethz.ch '[ -d /mnt/local/fgmehlin ]'); then
	ssh fgmehlin@dryad04.ethz.ch 'mkdir /mnt/local/fgmehlin'
fi

if ! (ssh fgmehlin@dryad07.ethz.ch '[ -d /mnt/local/fgmehlin ]'); then
	ssh fgmehlin@dryad07.ethz.ch 'mkdir /mnt/local/fgmehlin'
fi


ssh fgmehlin@dryad02.ethz.ch 'rm ~/asl/*.jar'

#echo 'Removing files on dryad02:/mnt/local/fgmehlin/*'
#ssh fgmehlin@dryad02.ethz.ch 'rm /mnt/local/fgmehlin/*'
#echo 'Removing files on dryad03:/mnt/local/fgmehlin/*'
#ssh fgmehlin@dryad03.ethz.ch 'rm /mnt/local/fgmehlin/*'
#echo 'Removing files on dryad04:/mnt/local/fgmehlin/*'
#ssh fgmehlin@dryad04.ethz.ch 'rm /mnt/local/fgmehlin/*'
#echo 'Removing files on dryad07:/mnt/local/fgmehlin/*'
#ssh fgmehlin@dryad07.ethz.ch 'rm /mnt/local/fgmehlin/*'
echo 'Removing files on dryad07:~/asl'
ssh fgmehlin@dryad04.ethz.ch 'rm ~/asl/*'

echo 'Copying middleware on remote home'
scp "$MW_JAR" fgmehlin@dryad02.ethz.ch:~/asl
echo 'Copying middleware on remote home'
scp "$MW_JAR" fgmehlin@dryad03.ethz.ch:~/asl
echo 'Copying client on remote home'
scp "$CLI_JAR" fgmehlin@dryad04.ethz.ch:~/asl
echo 'Copying experiment.sh on remote home'
scp "$EXP_SC" fgmehlin@dryad04.ethz.ch:~/asl
echo 'Copying pg_hba.conf on remote home'
scp "$PG_HBA" fgmehlin@dryad04.ethz.ch:~/asl
echo 'Copying postgresql.conf on remote home'
scp "$PSQL_CONF" fgmehlin@dryad04.ethz.ch:~/asl
echo 'Copying database on dryad07:/mnt/local/fgmehlin/'
scp "$DB_DUMP" fgmehlin@dryad07.ethz.ch:/mnt/local/fgmehlin/
scp "$PG_DB" fgmehlin@dryad07.ethz.ch:/mnt/local/fgmehlin/
scp "$SCRIPT_DB" fgmehlin@dryad07.ethz.ch:/mnt/local/fgmehlin/






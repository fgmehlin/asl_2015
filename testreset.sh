#!/bin/bash

'/Applications/pgAdmin3.app/Contents/SharedSupport/psql' --host 'asl-xlarge.cnq3qzzs08l2.eu-central-1.rds.amazonaws.com' --port 5432 --username 'asl_pg' 'asl' << EOF
select resetDB();
EOF
#!/bin/bash

source ./step0_envs.sh
source ./functions/ssh_and_run.sh

SSH_USER=$SSH_USER
SSH_SERVER="$SSH_SERVER"
SSH_KEY="$SSH_KEY"

ssh_and_run <<-STDIN

    sudo systemctl enable postgresql-13
    sudo /usr/pgsql-13/bin/postgresql-13-setup initdb
    sudo systemctl start postgresql-13

STDIN

scp -i "$SSH_KEY" ./sql/provision_db.sql ${SSH_USER}@${SSH_SERVER}:/home/${SSH_USER}/

ssh_and_run <<-STDIN

    sudo cp ./provision_db.sql /var/lib/pgsql/
    rm ./provision_db.sql
    sudo su -u postgres
    export LECTOR_PSQL_USER=$SSH_USER
    export LECTOR_PSQL_DATABASE="lector_chile"
    psql -f ./provision_db.sql
    createdb $SSH_USER
    exit

STDIN

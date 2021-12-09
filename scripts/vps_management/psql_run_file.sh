#!/bin/bash

set -e

source ../vps_setup/step0_envs.sh
source ../functions/ssh_and_run.sh

while getopts f: file
do
    case "$file" in
        f) SQL_FILE_PATH=${OPTARG} && SQL_FILE=$(basename "$OPTARG")
            ;;
    esac
done

if [ -z "SQL_FILE" ]; then echo "Please provide a -f <sql_file> option!" >&2; exit 1; fi

scp -i "$SSH_KEY" "$SQL_FILE_PATH" ${SSH_USER}@${SSH_SERVER}:/home/${SSH_USER}/

ssh_and_run <<-STDIN
    psql -f ./${SQL_FILE}
    rm ./${SQL_FILE}
STDIN

echo "Finished executing sql file"

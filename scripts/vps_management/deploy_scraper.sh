#!/bin/bash

source ../vps_setup/step0_envs.sh
source ../functions/ssh_and_run.sh

scp -i "$SSH_KEY" -r ../../scraper ${SSH_USER}@${SSH_SERVER}:/home/${SSH_USER}/srv/

ssh_and_run <<-STDIN
    cd srv/scraper
    poetry install
STDIN

if [ "$?" -eq "0" ]; then
    echo "Scraper copied over correctly"
    exit 0
else 
    echo "Something went wrong - status code: $?"
    exit 1
fi

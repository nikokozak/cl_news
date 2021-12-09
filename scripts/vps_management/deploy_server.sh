#!/bin/bash

set -e

source ../vps_setup/step0_envs.sh
source ../functions/ssh_and_run.sh

cd ../../

sudo docker build -f deploy.Dockerfile --no-cache --output release .
sudo chown niko release

scp -i "$SSH_KEY" -r ./release/* ${SSH_USER}@${SSH_SERVER}:/home/${SSH_USER}/srv/server/

ssh_and_run <<-STDIN
    cd srv/server/
STDIN

if [ "$?" -eq "0" ]; then
    echo "Server copied over correctly"
    exit 0
else 
    echo "Something went wrong - status code: $?"
    exit 1
fi

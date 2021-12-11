#!/bin/bash

set -e

source ../vps_setup/step0_envs.sh
source ../functions/ssh_and_run.sh

cd ../../

rm -rf server/_build

sudo docker build -f deploy.Dockerfile --no-cache --output release .
sudo chown niko release

RELEASE_FILE=./release/*.tar.gz
RELEASE_FILENAME=$(basename "$RELEASE_FILE")

scp -i "$SSH_KEY" release/release.tar.gz ${SSH_USER}@${SSH_SERVER}:/home/${SSH_USER}/

ssh_and_run <<-STDIN
    mkdir -p srv/server/ 
    rm -rf srv/server/*
    cp release.tar.gz srv/server/
    rm release.tar.gz
    cd srv/server/
    sudo tar -zxvf release.tar.gz

    sudo chcon -R -t bin_t /home/lector/srv/server/bin/
STDIN

# The last command above changes the SELinux policy, allowing us to run lector as a service

if [ "$?" -eq "0" ]; then
    echo "Server copied over correctly"
    exit 0
else 
    echo "Something went wrong - status code: $?"
    exit 1
fi

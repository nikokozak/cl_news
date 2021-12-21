#!/bin/bash

set -e

# Generate a random num from 8000 - 9000
LECTOR_PORT=$((8000 + $RANDOM % 1000))

source ../vps_setup/step0_envs.sh
source ../functions/ssh_and_run.sh

cd ../../

rm -rf server/_build

sudo docker build -f deploy.Dockerfile --no-cache --output release .
sudo chown niko release

RELEASE_FILE=./release/*.tar.gz
RELEASE_FILENAME=$(basename "$RELEASE_FILE")

scp -i "$SSH_KEY" release/release.tar.gz ${SSH_USER}@${SSH_SERVER}:/home/${SSH_USER}/

cat <<-EOF > ../caddy.conf/Caddyfile
    lectorchile.com

    reverse_proxy 127.0.0.1:${LECTOR_PORT}
EOF

ssh_and_run <<-STDIN
    mkdir -p srv/server/ 
    rm -rf srv/server/*
    cp release.tar.gz srv/server/
    rm release.tar.gz
    cd srv/server/
    sudo tar -zxvf release.tar.gz

    export LECTOR_PORT=${LECTOR_PORT}

    sudo chown $SSH_USER /home/${SSH_USER}/srv/server
    sudo chcon -R -t bin_t /home/${SSH_USER}/srv/server/bin/

    sudo systemctl reload caddy

    systemctl stop lector
    systemctl start lector
STDIN

# The last command above changes the SELinux policy, allowing us to run lector as a service

if [ "$?" -eq "0" ]; then
    echo "Server copied over correctly"
    exit 0
else 
    echo "Something went wrong - status code: $?"
    exit 1
fi

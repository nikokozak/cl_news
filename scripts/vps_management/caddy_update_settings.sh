#!/bin/bash

source ../vps_setup/step0_envs.sh
source ../functions/ssh_and_run.sh

scp -i "$SSH_KEY" ../caddy.conf/Caddyfile ${SSH_USER}@${SSH_SERVER}:/home/${SSH_USER}/

ssh_and_run <<-STDIN
    sudo cp ./Caddyfile /etc/caddy/Caddyfile
    rm ./Caddyfile
    sudo systemctl start caddy
    sudo systemctl reload caddy
    sudo systemctl status caddy --no-pager
STDIN

if [ "$?" -eq "0" ]; then
    echo "Caddy settings updated." >&1;
    exit 0;
else
    echo "Something went wrong." >&2;
    exit 1;
fi

#!/bin/bash

source ./step0_envs.sh
source ./functions/ssh_and_run.sh

SSH_USER=$SSH_USER
SSH_SERVER="$SSH_SERVER"
SSH_KEY="$SSH_KEY"

scp -i "$SSH_KEY" ./caddy.conf/Caddyfile ${SSH_USER}@${SSH_SERVER}:/home/${SSH_USER}/

ssh_and_run <<-STDIN

    sudo cp ./Caddyfile /etc/caddy/Caddyfile
    rm ./Caddyfile
    sudo systemctl enable caddy
    sudo systemctl start caddy

STDIN

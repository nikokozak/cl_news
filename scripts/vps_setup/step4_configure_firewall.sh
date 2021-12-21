#!/bin/bash

source ./step0_envs.sh
source ./functions/ssh_and_run.sh

SSH_USER=$SSH_USER
SSH_SERVER="$SSH_SERVER"
SSH_KEY="$SSH_KEY"

ssh_and_run <<-STDIN

    sudo systemctl start firewalld
    sudo firewall-cmd --add-service=http
    sudo firewall-cmd --add-service=https
    sudo firewall-cmd --runtime-to-permanent
    sudo firewall-cmd --set-target=DROP --permanent
    sudo firewall-cmd --add-icmp-block-inversion
    sudo firewall-cmd --add-icmp-block=echo-reply
    sudo firewall-cmd --add-icmp-block=echo-request
    sudo firewall-cmd --add-icmp-block=time-exceeded
    sudo firewall-cmd --add-icmp-block=fragmentation-needed

    sudo systemctl enable fail2ban
    sudo systemctl start fail2ban
STDIN

scp -i "$SSH_KEY" ./fail2ban.conf/jail.local ${SSH_USER}@${SSH_SERVER}:/home/${SSH_USER}/jail.local

ssh_and_run <<-STDIN
    sudo cp jail.local /etc/fail2ban/jail.local
    rm jail.local
    sudo systemctl restart fail2ban
STDIN


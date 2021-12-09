#!/bin/bash

source ../vps_setup/step0_envs.sh
source ../functions/ssh_and_run.sh

scp -i "$SSH_KEY" ../fail2ban.conf/jail.local ${SSH_USER}@${SSH_SERVER}:/home/${SSH_USER}/

ssh_and_run <<-STDIN
    sudo cp ./jail.local /etc/fail2ban/jail.local
    rm ./jail.local
    sudo systemctl start fail2ban
    sudo systemctl restart fail2ban
    sudo systemctl status fail2ban --no-pager
STDIN

if [ "$?" -eq "0" ]; then
    echo "Fail2Ban settings updated." >&1;
    exit 0;
else
    echo "Something went wrong." >&2;
    exit 1;
fi

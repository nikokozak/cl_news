#!/bin/bash
# POSITIONAL: $NEW_USER
# Sets up a user with sudo permissions, removes the root account.

set -e -o pipefail

source ./step0_envs.sh
source ./functions/ssh_and_run.sh

SSH_USER="root"
SSH_SERVER="$SERVER"
SSH_KEY="$SSH_KEY"

NEW_USER=$1
if [ -z "$NEW_USER" ]; then NEW_USER="$USER"; fi

# Add user, copy over SSH keys from root, make user sudo priviledged, lock root
ssh_and_run <<-STDIN 
    useradd $NEW_USER
    passwd -d $NEW_USER
    su - $NEW_USER -c 'mkdir ~/.ssh'
    su - $NEW_USER -c 'touch ~/.ssh/authorized_keys'
    cat /root/.ssh/authorized_keys >> /home/$NEW_USER/.ssh/authorized_keys
    chmod 600 /home/$NEW_USER/.ssh/authorized_keys
    chmod 700 /home/$NEW_USER/.ssh
    usermod -a -G wheel $NEW_USER

    passwd -l root
STDIN

# SSH as the new user
SSH_USER="$NEW_USER"

# Remove root account
ssh_and_run <<-STDIN
    sudo chage -E 0 root     
    mkdir ~/srv
STDIN

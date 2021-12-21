#!/bin/bash

source ./step0_envs.sh
source ./functions/ssh_and_run.sh

SSH_USER=$SSH_USER
SSH_SERVER=$SSH_SERVER
SSH_KEY=$SSH_KEY

ssh_and_run <<-STDIN
    
    echo "TERM=vt100" >> ~/.ssh/environment

STDIN

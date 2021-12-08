#!/bin/bash
# Removes a user, logging in with root account

set -e -o pipefail

source ./envs.sh
source ./functions/ssh_and_run.sh

SSH_USER="root"
SSH_SERVER="$SERVER"
USER_TO_REMOVE="$1"

ssh_and_run <<-STDIN
    userdel --remove $USER_TO_REMOVE
STDIN

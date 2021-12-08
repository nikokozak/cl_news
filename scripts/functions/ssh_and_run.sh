#!/bin/bash

# SSH's into a given SSH_SERVER, using SSH_USER and SSH_KEY, runs a <<-STDIN heredoc block
DIR=$(dirname "$0")

source $DIR/functions/log.sh
source $DIR/functions/log_error.sh

function ssh_and_run () {
    if [ -z "$SSH_SERVER" ]; then log_error "Please set a SSH_SERVER variable"; exit 1; fi
    if [ -z "$SSH_USER" ]; then log_error "Please set a SSH_USER variable"; exit 1; fi
    if [ -z "$SSH_KEY" ]; then log_error "Please set an SSH_KEY variable"; exit 1; fi

    local SSH_ARGS="-i ${SSH_KEY} ${SSH_USER}@${SSH_SERVER}"
    ssh $SSH_ARGS 'bash -s' $@ 
}

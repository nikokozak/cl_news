#!/bin/bash

source ./envs.sh
source ./functions/ssh_and_run.sh

SSH_USER="testuser"
SSH_SERVER="$SERVER"
SSH_KEY="$SSH_KEY"

ssh_and_run <<-STDIN
    sudo dnf update -y
    sudo dnf -y install dnf-plugins-core
    sudo dnf install firewalld -y
    sudo dnf install -y git openssl-devel ncurses-devel
    sudo dnf install "Development tools" -y

    sudo dnf install https://download.postgresql.org/pub/repos/yum/reporpms/EL-8-x86_64/pgdg-redhat-repo-latest.noarch.rpm -y
    sudo dnf -qy module disable postgresql
    sudo dnf install postgresql13 postgresql13-server -y
    sudo systemctl enable postgresql-13
    sudo /usr/pgsql-13/bin/postgresql-13-setup initdb
    sudo systemctl start postgresql-13

    sudo dnf install python39 -y
STDIN

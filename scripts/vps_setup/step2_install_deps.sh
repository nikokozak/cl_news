#!/bin/bash

source ./step0_envs.sh
source ./functions/ssh_and_run.sh

SSH_USER=$SSH_USER
SSH_SERVER="$SSH_SERVER"
SSH_KEY="$SSH_KEY"

ssh_and_run <<-STDIN

    sudo dnf update -y
    sudo dnf -y install dnf-plugins-core

    sudo dnf install -y git openssl-devel ncurses-devel
    sudo dnf install "Development tools" -y
    sudo dnf install epel-release -y

    sudo dnf install firewalld -y
    sudo dnf install fail2ban

    sudo dnf install https://download.postgresql.org/pub/repos/yum/reporpms/EL-8-x86_64/pgdg-redhat-repo-latest.noarch.rpm -y
    sudo dnf -qy module disable postgresql
    sudo dnf install postgresql13 postgresql13-server -y
    sudo dnf install postgresql13-contrib -y

    sudo dnf install python39 -y
    curl -sSL https://raw.githubusercontent.com/python-poetry/poetry/master/get-poetry.py | python3 -

    sudo dnf install 'dnf-command(copr)' -y
    sudo dnf copr enable @caddy/caddy -y
    sudo dnf install caddy -y

    sudo systemctl enable crond.service
    sudo systemctl start crond.service

STDIN

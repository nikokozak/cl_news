#!/bin/bash

source ../vps_setup/step0_envs.sh
source ../functions/ssh_and_run.sh

scp -i "$SSH_KEY" -r ../../scraper ${SSH_USER}@${SSH_SERVER}:/home/${SSH_USER}/srv/

ssh_and_run <<-STDIN

    cd srv/scraper
    rm scraper/logs/log.txt

    # Install deps
    ~/.poetry/bin/poetry install

    # Create and add our cron file
    echo "*/15 * * * * ${SSH_USER} bash /home/${SSH_USER}/srv/scraper/run_scraper.sh" > scraper_cron
    sudo cp scraper_cron /etc/cron.d/
    rm scraper_cron

STDIN

if [ "$?" -eq "0" ]; then
    echo "Scraper copied over correctly"
    exit 0
else 
    echo "Something went wrong - status code: $?"
    exit 1
fi

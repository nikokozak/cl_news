#!/bin/bash

set -e

# Generate a random num from 8000 - 9000
LECTOR_PORT=$((8000 + $RANDOM % 1000))

source ../vps_setup/step0_envs.sh
source ../functions/ssh_and_run.sh

cd ../../

# Remove the _build folder otherwise compilation isn't entirely fresh every time.
rm -rf server/_build

# Cross-compile build, output it to a local `release` folder. 
sudo docker build -f deploy.Dockerfile --no-cache --output release .
sudo chown niko release

RELEASE_FILE=./release/*.tar.gz
RELEASE_FILENAME=$(basename "$RELEASE_FILE")

scp -i "$SSH_KEY" release/release.tar.gz ${SSH_USER}@${SSH_SERVER}:/home/${SSH_USER}/

# Copy over our systemd unit file
scp -i "$SSH_KEY" scripts/lector.service/lector.service ${SSH_USER}@${SSH_SERVER}:/home/${SSH_USER}

# Write our new Caddyfile with new port
cat <<-EOF > scripts/caddy.conf/Caddyfile
    lectorchile.com

    reverse_proxy 127.0.0.1:${LECTOR_PORT}
EOF

ssh_and_run <<-STDIN

    # Make the required folders for --user space systemd service
    mkdir -p /home/${SSH_USER}/.config/systemd/user/
    cp lector.service /home/${SSH_USER}/.config/systemd/user/
    rm lector.service

    # Untar our release, replace previous files with new ones
    mkdir -p srv/server/ 
    rm -rf srv/server/*
    cp release.tar.gz srv/server/
    rm release.tar.gz
    cd srv/server/
    sudo tar -zxvf release.tar.gz

    # Change ownership of new files, SELinux perms for server systemd execution
    sudo chown $SSH_USER /home/${SSH_USER}/srv/server
    sudo chcon -R -t bin_t /home/${SSH_USER}/srv/server/bin/

    sudo systemctl reload caddy

    # Start systemd process
    systemctl --user daemon-reload
    systemctl --user set-environment LECTOR_PORT=${LECTOR_PORT}
    systemctl --user stop lector
    systemctl --user start lector

STDIN

# NOTES:

# The `chcon` command above changes the SELinux policy, allowing us to run lector as a service
# We use the --user space for the server explicitly. Env variables must be passed in via set-env or similar to systemd user processes (these don't inherit from .bashrc, etc.).

if [ "$?" -eq "0" ]; then
    echo "Server copied over correctly"
    exit 0
else 
    echo "Something went wrong - status code: $?"
    exit 1
fi

#!/bin/bash

# Sets environment variables necessary for the rest of our script

set -a

[ -z "$SSH_SERVER" ] && SSH_SERVER=159.223.147.156
[ -z "$SSH_USER" ] && SSH_USER="lector"
[ -z "$SSH_KEY" ] && SSH_KEY="~/.ssh/id_ed25519.digital_ocean"
[ -z "$DB_NAME" ] && DB_NAME="lector_chile"

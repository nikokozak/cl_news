#!/bin/bash

# Sets environment variables necessary for the rest of our script

set -a

[ -z "$SERVER" ] && SERVER=159.223.139.47
[ -z "$USER" ] && USER="lector"
[ -z "$SSH_KEY" ] && SSH_KEY="~/.ssh/id_ed25519.digital_ocean"
[ -z "$DB_NAME" ] && DB_NAME="lector_chile"

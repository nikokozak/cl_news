#!/bin/bash

# Logging convenience function. Logs to $LOG_FILE if set, otherwise "./log.txt"

[ -z "$LOG_FILE" ] && LOG_FILE=./log.txt

function log () {
    local MESSAGE=$@
    echo "$(date +"%b-%d %T") $@" | tee -a $LOG_FILE >&1
}

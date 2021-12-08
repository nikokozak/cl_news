#!/bin/bash

# Logging convenience function. Logs to $LOG_ERROR_FILE if set, otherwise "./log_err.txt"

[ -z "$LOG_ERROR_FILE" ] && LOG_ERROR_FILE=./log_err.txt

function log_error () {
    local MESSAGE=$@
    echo "$(date +"%b-%d %T") $@" | tee -a $LOG_ERROR_FILE >&2
}

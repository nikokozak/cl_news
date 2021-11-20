#!/bin/bash

# Removes the LECTOR_PSQL_DATABASE and users

function check_for_envs ()
{
    if [[ -z $LECTOR_PSQL_USER ]]; then
        echo 'Please set a LECTOR_PSQL_USER environment variable prior to running this script.'
        exit 1
    fi

    if [[ -z $LECTOR_PSQL_PASS ]]; then
        echo 'Please set a LECTOR_PSQL_PASS environment variable prior to running this script.'
        exit 1
    fi

    if [[ -z $LECTOR_PSQL_DATABASE ]]; then
        echo 'Please set a LECTOR_PSQL_DATABASE environment variable prior to running this script.'
        exit 1
    fi
}

function remove_db ()
{
    psql -c "DROP DATABASE IF EXISTS $LECTOR_PSQL_DATABASE"
}

function remove_user ()
{
    psql -c "DROP USER IF EXISTS $LECTOR_PSQL_USER"
}

check_for_envs
remove_db
remove_user

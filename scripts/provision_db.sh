#!/bin/bash

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

function init_psql ()
{
    brew services start postgresql
}

function provision_db ()
{
    psql -f ./sql/provision_db.sql
}

check_for_envs
init_psql
provision_db

echo "Database $LECTOR_PSQL_DATABASE and User $LECTOR_PSQL_USER provisioned correctly"

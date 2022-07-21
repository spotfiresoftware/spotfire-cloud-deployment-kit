#!/bin/bash

if [ "${DO_NOT_CREATE_USER}" == "true" ]; then
    arg_do_not_create_user="--do-not-create-user";
fi

config.sh create-db \
    --driver-class="${DBSERVER_CLASS}" \
    --database-url="${DBSERVER_URL}" \
    --admin-username="${DBSERVER_ADMIN_USERNAME}" \
    --admin-password="${DBSERVER_ADMIN_PASSWORD}" \
    --spotfiredb-username="${SPOTFIREDB_USERNAME}" \
    --spotfiredb-password="${SPOTFIREDB_PASSWORD}"  \
    ${SPOTFIREDB_DBNAME:+--spotfiredb-dbname="${SPOTFIREDB_DBNAME}"} \
    ${ORACLE_ROOT_FOLDER:+--oracle-rootfolder="${ORACLE_ROOT_FOLDER}"} \
    ${ORACLE_TABLESPACE_PREFIX:+--oracle-tablespace-prefix="${ORACLE_TABLESPACE_PREFIX}"} \
    ${VARIANT:+--variant="${VARIANT}"} \
    ${arg_do_not_create_user:-} \
    --no-prompt \
    --timeout-seconds="${BOOTSTRAP_TIMEOUT_SECONDS}" \
    --delay-interval-seconds="${BOOTSTRAP_DELAY_INTERVAL_SECONDS}"

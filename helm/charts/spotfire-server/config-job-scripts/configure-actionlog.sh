#!/bin/bash

function configure_action_log() {
    # echo "Running configure_actionlog with ACTIONLOG_CATEGORIES=${ACTIONLOG_CATEGORIES} ACTIONLOG_WEB_CATEGORIES=${ACTIONLOG_WEB_CATEGORIES}
    config.sh config-action-logger --categories="${ACTIONLOG_CATEGORIES:-all}" --file-logging-enabled="${ACTIONLOG_FILE_LOGGING}" --database-logging-enabled="${ACTIONLOG_DB_LOGGING}"  --configuration="${CONFIGURATION_FILE}" --bootstrap-config="${BOOTSTRAP_FILE}"
    config.sh config-action-log-web-service --categories="${ACTIONLOG_WEB_CATEGORIES:-all}" --configuration="${CONFIGURATION_FILE}" --bootstrap-config="${BOOTSTRAP_FILE}"
}

function create_actionlog_db() {

    if [ "${ACTIONDB_DO_NOT_CREATE_USER}" == "true" ]; then
        arg_do_not_create_user="--do-not-create-user";
    fi

    config.sh create-actionlogdb \
        --driver-class="${ACTIONDB_CLASS}" \
        --database-url="${ACTIONDB_ADMIN_URL}" \
        --admin-username="${ACTIONDB_ADMIN_USERNAME}" \
        --admin-password="${ACTIONDB_ADMIN_PASSWORD}" \
        --actiondb-dbname="${ACTIONDB_DBNAME}" \
        --actiondb-username="${ACTIONDB_USERNAME}" \
        --actiondb-password="${ACTIONDB_PASSWORD}" \
        ${ACTIONDB_ORACLE_ROOT_FOLDER:+--oracle-rootfolder="${ACTIONDB_ORACLE_ROOT_FOLDER}"} \
        ${ACTIONDB_ORACLE_TABLESPACE_PREFIX:+--oracle-tablespace-prefix="${ACTIONDB_ORACLE_TABLESPACE_PREFIX}"} \
        ${arg_do_not_create_user:-} \
        ${ACTIONDB_VARIANT:+--variant="${ACTIONDB_VARIANT}"} \
        ${ACTIONDB_CREATE_TIMEOUT_SECONDS:+--timeout-seconds="${ACTIONDB_CREATE_TIMEOUT_SECONDS}"} \
        --no-prompt
}

function configure_actionlog_db() {

    # echo "Running configure_actionlog_db with ACTIONDB_CONFIG_ARGS=${ACTIONDB_CONFIG_ARGS}"
    config.sh config-action-log-database-logger \
      --configuration="${CONFIGURATION_FILE}" \
      --bootstrap-config="${BOOTSTRAP_FILE}" \
      --driver-class="${ACTIONDB_CLASS}" \
      --database-url="${ACTIONDB_URL}" \
      --username="${ACTIONDB_USERNAME}" \
      --password="${ACTIONDB_PASSWORD}" \
       ${ACTIONDB_CONFIG_ARGS}
}

echo "Check create actionlog db ${ACTIONDB_CREATE}."
# ACTIONDB_CREATE will only be set (to true) if ACTIONLOG_DB_LOGGING is also true
if [ "${ACTIONDB_CREATE}" == "true" ]; then
    create_actionlog_db
fi

echo "Configure action logging."
if [ "${ACTIONLOG_DB_LOGGING}" == "true" ] || [ "${ACTIONLOG_FILE_LOGGING}" == "true" ]; then
    configure_action_log
fi

if [ "${ACTIONLOG_DB_LOGGING}" == "true" ]; then
    configure_actionlog_db
fi

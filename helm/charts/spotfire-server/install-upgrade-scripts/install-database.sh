#!/bin/bash

config.sh create-db \
    --driver-class="${DBSERVER_CLASS}" \
    --database-url="${DBSERVER_URL}" \
    --admin-username="${DBSERVER_ADMIN_USERNAME}" \
    --admin-password="${DBSERVER_ADMIN_PASSWORD}" \
    --spotfire-dbname="${SPOTFIREDB_DBNAME}" \
    --spotfire-username="${SPOTFIREDB_USERNAME}" \
    --spotfire-password="${SPOTFIREDB_PASSWORD}"  \
    --no-prompt \
    --timeout-seconds="${BOOTSTRAP_TIMEOUT_SECONDS}" \
    --delay-interval-seconds="${BOOTSTRAP_DELAY_INTERVAL_SECONDS}"

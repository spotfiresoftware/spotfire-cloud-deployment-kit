#!/bin/bash

set -o errexit
set -o nounset

## Check if the pre-requisite are present for Spotfire server.
startupcheck_delay_interval_seconds="5"

if [ "${STARTUPCHECK_ADMIN_USER}" = "Y" ]; then
    arg_check_admin_user="--admin-user"
fi

if [ "${STARTUPCHECK_VALID_DEPLOYMENT}" = "Y" ]; then
    arg_check_valid_deployment="--valid-deployment"
fi

/opt/tibco/tss/tomcat/spotfire-bin/config.sh check-prerequisites \
    --tool-password="${TOOL_PASSWORD}" \
    ${arg_check_admin_user:-} \
    ${arg_check_valid_deployment:-} \
    --timeout-seconds="${STARTUPCHECK_TIMEOUT_SECONDS}" \
    --delay-interval-seconds="${startupcheck_delay_interval_seconds}"

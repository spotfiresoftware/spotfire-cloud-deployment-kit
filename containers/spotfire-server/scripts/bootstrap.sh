#!/bin/bash

set -o errexit
# set -o nounset

##
## Define variables
##
startupcheck_delay_interval_seconds="5"

bootstrap_file=/opt/tibco/tss/tomcat/webapps/spotfire/WEB-INF/bootstrap.xml

## Bootstrapping the Spotfire server
if [ -f "${bootstrap_file}" ]; then
    echo "${bootstrap_file} already exists. Skipping bootstrapping"
    exit 0
fi

# Default to host ip address
hostname=$(hostname -i)

## Use environment variable as hostname (the address that other nodes can access this node on) is set
if [ "${SERVER_IP_ADDRESS:-}" ]; then
    hostname="${SERVER_IP_ADDRESS}"
fi

echo "Using hostname: $hostname"

/opt/tibco/tss/tomcat/spotfire-bin/config.sh bootstrap \
    --no-prompt \
    --driver-class="${SPOTFIREDB_CLASS}" \
    --database-url="${SPOTFIREDB_URL}" \
    --username="${SPOTFIREDB_USERNAME}" \
    --password="${SPOTFIREDB_PASSWORD}" \
    --site-name="${SITE_NAME}" \
    --enable-config-tool=true \
    --tool-password="${TOOL_PASSWORD}" \
    --timeout-seconds="${STARTUPCHECK_TIMEOUT_SECONDS}" \
    --delay-interval-seconds="${startupcheck_delay_interval_seconds}" \
    -A"${hostname}" \
    ${SERVER_BACKEND_ADDRESS:+-A"${SERVER_BACKEND_ADDRESS}"} \
    ${ENCRYPTION_PASSWORD:+--encryption-password="${ENCRYPTION_PASSWORD}"} \
    ${BOOTSTRAP_OPTS}

exit_code=$?
if [ ${exit_code} -ne 0 ]; then
    echo -e "Error while creating bootstrap.\nExiting."
fi
exit ${exit_code}

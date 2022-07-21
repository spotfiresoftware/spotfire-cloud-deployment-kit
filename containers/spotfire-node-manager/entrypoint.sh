#!/usr/bin/env bash

# set -o nounset

trap stop SIGTERM

stop() {
    echo "Exiting trapped SIGTERM..."
    exit
}

# Default to host ip address
hostname=$(hostname -i)

## Use environment variable as hostname (the address that other nodes can access this node on) is set
if [ "${NODEMANAGER_HOST_NAMES:-}" ]; then
    hostname="${NODEMANAGER_HOST_NAMES}"
fi

## Use environment variable as hostname (the address that other nodes can access this node on) is set
if [ "${NODEMANAGER_IP_ADDRESS:-}" ]; then
    hostname="${NODEMANAGER_IP_ADDRESS}"
fi

echo "Using hostname: $hostname"


# Setup logging
scripts/setup-logging.sh || exit $?

# Additional configuration
scripts/configure-nodemanager.sh || exit $?
scripts/configure-service.sh || exit $?

# Configure ports and addresses
./configure -m "${NODEMANAGER_REGISTRATION_PORT}" -c "${NODEMANAGER_COMMUNICATION_PORT}" -s "${SERVER_BACKEND_ADDRESS}" -r "${SERVER_BACKEND_REGISTRATION_PORT}" -b "${SERVER_BACKEND_COMMUNICATION_PORT}" -n "${hostname}" || exit $?

# Establish trust
nm/init.sh

# Restart the node once it is trusted, use exec to forward SIGTERM et al
exec nm/init.sh

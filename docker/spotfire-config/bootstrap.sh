#!/bin/bash

set -o errexit
set -o nounset

## Bootstrapping the Spotfire server
if [ -f "${BOOTSTRAP_FILE}" ]; then
    echo "${BOOTSTRAP_FILE} already exists. Skipping."
    exit 0
fi

config.sh bootstrap \
    --no-prompt \
    --driver-class="${SPOTFIREDB_CLASS}" \
    --database-url="${SPOTFIREDB_URL}" \
    --username="${SPOTFIREDB_USERNAME}" \
    --password="${SPOTFIREDB_PASSWORD}" \
    --tool-password="${TOOL_PASSWORD}" \
    "${BOOTSTRAP_FILE}"


exit_code=$?
if [ ${exit_code} -ne 0 ]; then
    echo -e "Error while creating ${BOOTSTRAP_FILE}"
fi

echo
echo 'Example usage:'
echo 'config.sh export-config --tool-password="${TOOL_PASSWORD}" --bootstrap-config="${BOOTSTRAP_FILE}" configuration.xml'
exit ${exit_code}
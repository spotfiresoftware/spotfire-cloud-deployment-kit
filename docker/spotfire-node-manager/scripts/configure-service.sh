#!/bin/bash

default_conf=/opt/tibco/tsnm/nm/config/default.conf
if [ ! -f "${default_conf}" ]; then
    echo "${default_conf} does not exists. Skipping additional service configuration"
    exit 0
fi

echo "Naming service instance to ${HOSTNAME}"
content="$(HOSTNAME=$HOSTNAME jq '.services[0].customName = env.HOSTNAME' ${default_conf})"
cp "${default_conf}" "${default_conf}.orig"
echo "${content}" > "${default_conf}"

if [[ -v TSWP_RESOURCEPOOL ]]; then
    echo "Assigning service instance to resource pool '${TSWP_RESOURCEPOOL}'"
    content="$(TSWP_RESOURCEPOOL=$TSWP_RESOURCEPOOL jq '.services[0].resourcePool = env.TSWP_RESOURCEPOOL' ${default_conf})"
    cp "${default_conf}" "${default_conf}.hostname"
    echo "${content}" > "${default_conf}"
fi
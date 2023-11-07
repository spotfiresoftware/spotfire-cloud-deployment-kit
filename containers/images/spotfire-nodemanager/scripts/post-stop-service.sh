#!/bin/bash

set -o verbose

if [ ! -d "/opt/spotfire/troubleshooting" ]; then
    echo "Troubleshooting directory /opt/spotfire/troubleshooting not found, not performing any post stop actions"
    exit 0;
fi

function copyGlobIfExist() {
    local glob=$1
    if compgen -G "${glob}" > /dev/null; then
        cp -v -u ${glob} /opt/spotfire/troubleshooting/
    fi
}

# Make sure to copy files in the logs folder that is useful for diagnostics to the troubleshooting folder
copyGlobIfExist "/opt/spotfire/nodemanager/nm/logs/hanging_process*.txt"
copyGlobIfExist "/opt/spotfire/nodemanager/nm/logs/*.dmp"
copyGlobIfExist "/opt/spotfire/nodemanager/nm/logs/*.mdmp"
copyGlobIfExist "/opt/spotfire/nodemanager/nm/services/*/hs_err_pid*.log"

# Core dump will be written to /opt/spotfire/nodemanager/nm/services/{TERR,PYTHON}/core if ENGINE_DISABLE_JAVA_CORE_DUMPS=FALSE
if compgen -G "/opt/spotfire/nodemanager/nm/services/*/core" > /dev/null; then
    timestamp=$(date +%Y-%m-%d-%H%M%S | xargs)
    for corefile in /opt/spotfire/nodemanager/nm/services/*/core; do
        mv -v "${corefile}" "/opt/spotfire/troubleshooting/core_${timestamp}"
    done
fi

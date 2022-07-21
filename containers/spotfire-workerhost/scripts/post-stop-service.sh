#!/bin/bash

if [ ! -d "/opt/tibco/troubleshooting" ]; then
    echo "Troubleshooting directory /opt/tibco/troubleshooting not found, not performing any post stop actions"
    exit 0;
fi

function copyGlobIfExist() {
    local glob=$1
    if compgen -G "${glob}" > /dev/null; then
        cp -v -u ${glob} /opt/tibco/troubleshooting/
    fi
}

# Make sure to copy files in the logs folder that is useful for diagnostics to the troubleshooting folder
copyGlobIfExist "/opt/tibco/tsnm/nm/logs/hanging_process*.txt"
copyGlobIfExist "/opt/tibco/tsnm/nm/logs/*.dmp"
copyGlobIfExist "/opt/tibco/tsnm/nm/logs/*.mdmp"
copyGlobIfExist "/opt/tibco/tsnm/nm/services/*/hs_err_pid*.log"

# Core dump will be written to /opt/tibco/tsnm/nm/services/{TERR,PYTHON}/core if ENGINE_DISABLE_JAVA_CORE_DUMPS=FALSE
timestamp=$(date +%Y-%m-%d-%H%M%S | xargs)
for corefile in /opt/tibco/tsnm/nm/services/*/core; do
    test -e "${corefile}" && mv "${corefile}" "/opt/tibco/troubleshooting/core_${timestamp}"
done

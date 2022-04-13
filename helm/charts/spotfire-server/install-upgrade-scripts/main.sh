#!/bin/bash

function printStack () {
    echo "${1:-Stack trace}"

    local depth
    depth=${#FUNCNAME[@]}

    for ((i=1; i<depth; i++)); do
        local function="${FUNCNAME[$i]}"
        local line="${BASH_LINENO[$((i-1))]}"
        local file="${BASH_SOURCE[$((i-1))]}"
        echo " $function(), $file, line $line"
    done
}

function logHeader() {
    echo
    echo "******************************************************"
    echo "$@"
    echo "******************************************************"
    echo
}

function logSubHeader() {
    echo
    echo "$@"
    echo "======================================================"
    echo
}

# Export existing config OR create default config 
function export_config() {
    if [ "${JOB_USE_EXISTING_CONFIGURATION}" = "true" ]; then
        logHeader "Exporting existing configuration"
        config.sh export-config --force --tool-password="${TOOL_PASSWORD}" --bootstrap-config="${BOOTSTRAP_FILE}" || config.sh create-default-config --force 
    else
        logHeader "Creating default configuration"
        config.sh create-default-config --force
    fi
    cp -- "${CONFIGURATION_FILE}" "${CONFIGURATION_FILE}".original
}

# Import configuration if needed
function import_config() {
    logHeader "Import configuration"

    if [ ! -f "${CONFIGURATION_FILE}" ]; then
        echo "${CONFIGURATION_FILE} does not exist - skipping import"
        return
    fi

    if diff "${CONFIGURATION_FILE}".original "${CONFIGURATION_FILE}"; then
        echo "${CONFIGURATION_FILE}.original and ${CONFIGURATION_FILE} are identical. No config changes made. Skipping import."
        return
    fi

    echo "${CONFIGURATION_FILE}.original" and "${CONFIGURATION_FILE}" "differ. Will apply the following diff:"
    diff "${CONFIGURATION_FILE}.original" "${CONFIGURATION_FILE}" || :
    echo "Importing updated configuration file"
    config.sh import-config --bootstrap-config=bootstrap.xml --tool-password="${TOOL_PASSWORD}" -c "${JOB_CONFIGURATION_COMMENT}"
}

function command_scripts() {
    logHeader "Running command scripts"
    for f in /opt/tibco/command-scripts/*; do
        if [ -f "${f}" ]; then
            logSubHeader "Running extra commands steps ${f}"
            config.sh run --include-environment --fail-on-undefined-variable "${f}"
        fi
    done
}

# Exit on error and print stack trace
set -o errexit
set -o nounset
trap 'printStack' ERR

if [ "${LOG_LEVEL}" = "DEBUG" ] ; then
    set -v
elif [ "${LOG_LEVEL}" = "TRACE" ] ; then
    set -x
fi

# Install database
if [ "${JOB_INSTALL}" = "true" ]; then
    logHeader "Install database"
    /opt/tibco/scripts/install-database.sh
fi

# Bootstrap
logHeader "Bootstrapping"
/opt/tibco/bootstrap.sh

# Database upgrade
if [ "${JOB_DATABASE_UPGRADE}" = "true" ]; then
    logHeader "Database upgrade"
    /opt/tibco/scripts/database-upgrade.sh
fi


# export config
export_config

# Default kubernetes configuration
if [ "${JOB_DEFAULT_CONFIGURE}" = "true" ]; then
    logHeader "Applying default kubernetes configuration"
    config.sh run --include-environment --fail-on-undefined-variable /opt/tibco/scripts/default-kubernetes-config.txt
fi

# Custom configuration scripts
logHeader "Running configuration scripts"
for f in /opt/tibco/configuration-scripts/*; do
    if [ -f "${f}" ]; then
        logSubHeader "Running extra config step ${f}"
        config.sh run --include-environment --fail-on-undefined-variable "${f}"
    fi
done

# import config
import_config

# Deployment
logHeader "Deploying sdn / spk files"
/opt/tibco/scripts/deploy.sh

# Add user, set public address
logHeader "Running default commands"
config.sh run --include-environment --fail-on-undefined-variable /opt/tibco/scripts/default-commands.txt

command_scripts

logHeader "Done."

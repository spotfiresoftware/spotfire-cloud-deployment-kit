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
# Export existing OR create default config
function export_or_create_default_config() {
    # configuration.xml.original: Already existing configuration in database, or empty if none exists from the start
    # configuration.xml: Configuration that will be modified in this script
    if [ "${JOB_PREFER_EXISTING_CONFIG}" = "true" ]; then
        logSubHeader "Exporting existing configuration"
        config.sh export-config --force --tool-password="${TOOL_PASSWORD}" --bootstrap-config="${BOOTSTRAP_FILE}" "${CONFIGURATION_FILE}" || touch "${CONFIGURATION_FILE}"
        cp -- "${CONFIGURATION_FILE}" "${CONFIGURATION_FILE}".original

        if [ ! -s "${CONFIGURATION_FILE}".original ]; then
            echo "Creating default configuration because non was present in database"
            config.sh create-default-config --force "${CONFIGURATION_FILE}"
        fi
    else
        logSubHeader "Creating default configuration"
        touch "${CONFIGURATION_FILE}".original
        config.sh create-default-config --force "${CONFIGURATION_FILE}"
    fi
}



# Import configuration if needed
function import_config() {
    logSubHeader "Import configuration"

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

function pre_config_command_scripts() {
    logSubHeader "Running pre-configuration scripts"
    for f in /opt/tibco/pre-config-command-scripts/*; do
        if [ -f "${f}" ]; then
            logSubHeader "Running pre-config step ${f}"
            config.sh run --include-environment --fail-on-undefined-variable "${f}"
        fi
    done
}

function command_scripts() {
    logSubHeader "Running command scripts"
    for f in /opt/tibco/command-scripts/*; do
        if [ -f "${f}" ]; then
            logSubHeader "Running extra commands steps ${f}"
            config.sh run --include-environment --fail-on-undefined-variable "${f}"
        fi
    done
}

function configuration_scripts() {
    logSubHeader "Running configuration scripts"
    for f in /opt/tibco/configuration-scripts/*; do
        if [ -f "${f}" ]; then
            logSubHeader "Running config step ${f}"
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

# Version information
logHeader "Version"
config.sh version

# Install database
if [ "${JOB_CREATE_DATABASE}" = "true" ]; then
    logHeader "Installing database"
    /opt/tibco/scripts/install-database.sh
fi

# Bootstrap
logHeader "Bootstrapping"
/opt/tibco/bootstrap.sh

# Database upgrade
if [ "${JOB_UPGRADE_DATABASE}" = "true" ]; then
    logHeader "Upgrading database"
    /opt/tibco/scripts/database-upgrade.sh
fi

# Configure public address
logHeader "Configuration and setup"

# If check-prerequisites are met, there is a configured spotfire database hence no new installation
if config.sh check-prerequisites --tool-password="${TOOL_PASSWORD}" > /dev/null 2>&1; then
    is_install="false"
    echo "An existing configuration was found. It is NOT a new installation."
else
    is_install="true"
    echo "An existing configuration was NOT found. It is a new installation."
fi

# Don't apply configuration if externally managed, unless helm release is installed i.e initial setup
if [ "${JOB_WHEN_TO_APPLY_CONFIG,,}" = "initialsetup" ] && [ "${is_install}" = "true" ]; then
    apply_configuration="true"
elif [ "${JOB_WHEN_TO_APPLY_CONFIG,,}" = "initialsetup" ] && [ "${is_install}" = "false" ]; then
    apply_configuration="false"
elif [ "${JOB_WHEN_TO_APPLY_CONFIG,,}" = "always" ]; then
    apply_configuration="true"
elif [ "${JOB_WHEN_TO_APPLY_CONFIG,,}" = "never" ]; then
    apply_configuration="false"
else
    echo 'ERROR $JOB_WHEN_TO_APPLY_CONFIG is not one of initialsetup, always, never'
    exit 1
fi

echo -n "JOB_WHEN_TO_APPLY_CONFIG is set to '${JOB_WHEN_TO_APPLY_CONFIG}' and is_install is '${is_install}'. "
if [ "${apply_configuration}" = "false" ]; then
    echo "Configuration will not be applied."
else
    echo "Configuration will be applied."
fi

if [ "${apply_configuration}" = "true" ]; then
    export_or_create_default_config

    if [ ! -z "${SITE_PUBLIC_ADDRESS}" ]; then
        config.sh set-public-address --bootstrap-config=bootstrap.xml --tool-password="${TOOL_PASSWORD}" --site-name="${SITE_NAME}" --url="${SITE_PUBLIC_ADDRESS}"
    fi

    # Configure action logging
    logSubHeader "Configure action logging"
    config.sh run --include-environment --fail-on-undefined-variable /opt/tibco/scripts/action-logging.txt

    # Default kubernetes configuration
    logSubHeader "Applying default kubernetes configuration"
    config.sh run --include-environment --fail-on-undefined-variable /opt/tibco/scripts/default-kubernetes-config.txt

    pre_config_command_scripts

    # Custom configuration scripts
    configuration_scripts

    # Import config if, but only if it has changed
    import_config
fi


if [ "${JOB_DO_DEPLOY}" = "true" ]; then
    logSubHeader "Deploying sdn / spk files"
    /opt/tibco/scripts/deploy.sh
fi

if [ "${apply_configuration}" = "true" ]; then

    # Add admin user
    if [ "${JOB_CREATE_ADMIN}" = "true" ]; then
        logSubHeader "Creating admin user"
        config.sh run --include-environment --fail-on-undefined-variable /opt/tibco/scripts/create-user.txt
    fi

    command_scripts

fi

logHeader "Done."

#!/bin/bash

set -o nounset
set -o errexit

startupcheck_timeout_seconds="60"
startupcheck_delay_interval_seconds="5"

##
## Get filenames in a dir
##
function getFilenames() {
    dir="$1"
    filenames=""
    # SDNs/SPKs to deploy in the folder
    for file in "${dir}"*.{sdn,spk}; do
        if [ -f "${file}" ]; then
            if [ "${filenames}" ]; then
                filenames="${filenames},"
            fi
            filenames="${filenames}${file}"
        fi
    done
    echo "${filenames}"
}

##
## Update deployment
##
function updateDeployment() {
    filenames=$1
    dir=$2

    clear=""
    if [ "${JOB_DO_DEPLOY_CLEAR}" = "true" ]; then
        clear="--clear"
    fi

    if [ "${filenames}" ]; then
        config.sh update-deployment \
            --tool-password="${TOOL_PASSWORD}" \
            --bootstrap-config="${BOOTSTRAP_FILE}" \
            --area="${areaname}" \
            ${clear} \
            "${filenames}"
    else
        echo "No files to deploy in path ${dir}"
    fi
}

##
## Deploy Packages
##
function deployPackages () {
    shopt -s nocaseglob
    # Update deployment needs configuration
    config.sh check-prerequisites \
        --bootstrap-config="${BOOTSTRAP_FILE}" \
        --tool-password="${TOOL_PASSWORD}" \
        --timeout-seconds="${startupcheck_timeout_seconds}" \
        --delay-interval-seconds="${startupcheck_delay_interval_seconds}"

    # Loop through directory and create deployment areas based on folder names
    echo "Listing deployment folders"
    ls -lah /opt/spotfire/spotfireconfigtool/deployments/

    for dir in /opt/spotfire/spotfireconfigtool/deployments/*/; do
        if [ -d "${dir}" ]; then
            if [[ "${LOG_LEVEL^^}" =~ ^(DEBUG|TRACE) ]] ; then
                echo "Listing content of ${dir}"
                ls -lah "${dir}"
            fi

            areaname=$(basename "$dir")
            config.sh create-deployment-area \
                --tool-password "${TOOL_PASSWORD}" \
                --bootstrap-config "${BOOTSTRAP_FILE}" \
                --area-name "${areaname}" \
                --ignore-existing=true

            filenames="$(getFilenames "${dir}")"
            updateDeployment "${filenames}" "${dir}"
        fi
    done
}

deployPackages
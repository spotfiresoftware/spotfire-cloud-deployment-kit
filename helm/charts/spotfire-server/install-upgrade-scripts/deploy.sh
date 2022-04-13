#!/bin/bash

set -o nounset
set -o errexit

# bootstrap_timeout_seconds="40"
# bootstrap_delay_interval_seconds="5"
startupcheck_timeout_seconds="60"
startupcheck_delay_interval_seconds="5"
bootstrap_file="bootstrap.xml"

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
    if [ "${filenames}" ]; then
        config.sh update-deployment \
            --tool-password="${TOOL_PASSWORD}" \
            --bootstrap-config="${bootstrap_file}" \
            --area="${areaname}" \
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
        --bootstrap-config="${bootstrap_file}" \
        --tool-password="${TOOL_PASSWORD}" \
        --timeout-seconds="${startupcheck_timeout_seconds}" \
        --delay-interval-seconds="${startupcheck_delay_interval_seconds}"

    # Loop through directory and create deployment areas based on folder names
    for dir in /opt/tibco/spotfireconfigtool/deployments/*/; do
        if [ -d "${dir}" ]; then
            areaname=$(basename "$dir")
            config.sh create-deployment-area \
                --tool-password "${TOOL_PASSWORD}" \
                --bootstrap-config "${bootstrap_file}" \
                --area-name "${areaname}" \
                --ignore-existing=true

            filenames="$(getFilenames "${dir}")"
            updateDeployment "${filenames}" "${dir}"
        fi
    done
}

deployPackages
#!/bin/bash

function print_usage() {
    echo "Usage: $0 <namespace> [options]"
    echo ""
    echo "Options:"
    echo "  -h, --help                          Show help"
    echo "  -o, --output <FILE_OR_DIRECTORY>    Specify output. Will be an archive if it ends with .tar.gz (default: <namespace>-<datetime>.tar.gz)"
    echo "  -v, --verbose                       Enable verbose mode"
    echo "  -k, --kinds KINDS                   Kubernetes object kinds to collect (comma-separated). Run 'kubectl api-resources' to list all available kinds"
    echo "  --add KINDS                         Add kinds to the list of kinds to collect (comma-separated)"
    echo "  --remove KINDS                      Remove kinds from the list of kinds to collect (comma-separated)"
    echo "  --no-helm                           Do not collect helm releases and values"
    echo "  --no-cluster-info                   Do not collect cluster information"
    echo
    echo "This script generates a troubleshooting bundle tar.gz. for a given namespace."
    echo
    echo "Example of the information that will be collected:"
    echo "  - Helm releases and values"
    echo "  - Kubernetes cluster information"
    echo "  - Container standard out"
    echo "  - Spotfire application logs"
    echo "  - Kubernetes objects (default kinds: $(export IFS=,; echo "${KUBERNETES_KINDS[*]}"))"
}

ERROR_CODE_HELP=1
ERROR_CODE_FILE_NOT_FOUND=2
ERROR_CODE_INVALID_ARGUMENTS=3
ERROR_CODE_COMMAND_NOT_FOUND=4

# Defaults
VERBOSE=false
KUBERNETES_KINDS=("LimitRange" "ResourceQuota" "Endpoints" "PersistentVolumeClaim" "ServiceAccount" "Service" "ControllerRevision" "Deployment" "ReplicaSet" "StatefulSet" "Job" "Ingress" "NetworkPolicy" "PodDisruptionBudget")

# Parse command line options
parsed_options=$(getopt -o ho:ivt: --long help,output:,verbose,kinds:,add:,remove:,no-helm,no-cluster-info -- "$@")
if [ $? != 0 ]; then
    print_usage
    exit ${ERROR_CODE_INVALID_ARGUMENTS}
fi
eval set -- $parsed_options

while true; do
    case "$1" in
        -h|--help) print_usage; exit ${ERROR_CODE_HELP} ;;
        -o|--output) OUTPUT_FILE_OR_DIRECTORY="$2"; shift ;;
        -v|--verbose) VERBOSE=true ;;
        -k|--kinds) IFS=',' read -ra ADD_KINDS <<< "$2"; KUBERNETES_KINDS=("${ADD_KINDS[@]}"); shift ;;
        --add) IFS=',' read -ra ADD_KINDS <<< "$2"; KUBERNETES_KINDS+=("${ADD_KINDS[@]}"); shift ;;
        --remove) IFS=',' read -ra REMOVE_KINDS <<< "$2"; KUBERNETES_KINDS=("${KUBERNETES_KINDS[@]/${REMOVE_KINDS[@]}/}"); shift ;;
        --no-helm) NO_HELM=true ;;
        --no-cluster-info) NO_CLUSTER_INFO=true ;;
        --) shift; break ;;
        *) echo "Invalid option: $1"; print_usage; exit ${ERROR_CODE_INVALID_ARGUMENTS} ;;
    esac
    shift
done

NAMESPACE="$1"
if [[ -z $NAMESPACE ]]; then
    echo "❌ Error: Namespace is required." >&2
    print_usage
    exit ${ERROR_CODE_INVALID_ARGUMENTS}
fi
shift

# Keep all entries in KUBERNETES_KINDS if it is a non-empty string
KUBERNETES_KINDS=(${KUBERNETES_KINDS[@]:-})

if [[ $# -gt 0 ]]; then
    echo "❌ Error: Unexpected positional parameters after options: $@" >&2
    print_usage
    exit ${ERROR_CODE_INVALID_ARGUMENTS}
fi

# Check if OUTPUT_FILE_OR_DIRECTORY is a directory or already exists
if [[ -d "${OUTPUT_FILE_OR_DIRECTORY}" || -f "${OUTPUT_FILE_OR_DIRECTORY}" ]]; then
    echo "❌ Error: Output file already exists." >&2
    exit ${ERROR_CODE_FILE_NOT_FOUND}
fi

# Set default output file if not provided
if [[ -z "${OUTPUT_FILE_OR_DIRECTORY}" ]]; then
    timestamp=$(date +"%Y%m%d%H%M%S")
    OUTPUT_FILE_OR_DIRECTORY="${NAMESPACE}-${timestamp}.tar.gz"
fi

# Check that kubectl and helm commands are available
if ! command -v kubectl &> /dev/null; then
    echo "❌ kubectl command not found." >&2
    exit ${ERROR_CODE_COMMAND_NOT_FOUND}
fi

if [[ "${NO_HELM}" != "true" ]] && ! command -v helm &> /dev/null; then
    echo "❌ helm command not found." >&2
    exit ${ERROR_CODE_COMMAND_NOT_FOUND}
fi

# Check if namespace exists
if ! kubectl get -- namespace "$NAMESPACE" >/dev/null 2>&1; then
    echo "❌ Namespace '$NAMESPACE' does not exist or you are unable to access it."
    exit ${ERROR_CODE_INVALID_ARGUMENTS}
fi

#
# Functions
#

function collect_info() {
    local command="$1"
    local output_file="$2"

    echo "📄 ${output_file}" >&2
    [[ "${VERBOSE}" == true ]] && echo "⚙️ ${command}" >&2
    mkdir -p "$(dirname "${output_file}")"
    eval "${command}" > "${output_file}" || return $?
}

function copy_applogs() {
    local pod="$1"
    local container="$2"
    local filepath="$3"
    local output_dir="${OUTPUT_DIR}/pod-${pod}/logs/"

    # Get the status of the container and check the status code
    if ! container_status=$(kubectl get pod "${pod}" --namespace "${NAMESPACE}" -o jsonpath="{.status.containerStatuses[?(@.name=='${container}')].state}"); then
        echo "⚠️ Warning: Failed to get the status of container ${container} in pod ${pod}."
        return 1
    fi

    # Check if the container is running
    if [[ "${container_status}" != *"running"* ]]; then
        echo "⚠️ Warning: Container ${container} is not running in pod ${pod}. Logs cannot be copied." >&2
        return 1
    fi

    echo "📁 ${output_dir}"
    kubectl cp -n "${NAMESPACE}" -c "${container}" "${pod}:${filepath}" "${output_dir}"
    return $?
}

function fetch_pod_info_and_logs() {
    local pod=$1
    local pod_output_dir="${OUTPUT_DIR}/pod-${pod}"

    # Collect pod information using 'kubectl describe pod' command
    collect_info "kubectl --namespace '${NAMESPACE}' describe pod '${pod}'" "${pod_output_dir}/describe.txt" || return 1

    # Get the list of containers in the pod
    containers=$(kubectl get pod "${pod}" --namespace "${NAMESPACE}" --output=jsonpath='{.spec.containers[*].name}' 2>/dev/null)
    if [[ $? -ne 0 ]]; then
        echo "❌ Error: Failed to get the list of containers for pod ${pod}."
        return 1
    fi

    # Collect logs for each container in the pod
    for container in ${containers}; do
        collect_info "kubectl --namespace '${NAMESPACE}' logs '${pod}' -c '${container}'" "${pod_output_dir}/stdout-${container}.log"
    done

    local main_container_restart_count=$(kubectl get pod ${pod} -n ${NAMESPACE} -o jsonpath='{.status.containerStatuses[0].restartCount}')
    if [ "${main_container_restart_count}" -gt 0 ]; then
        collect_info "kubectl --namespace '${NAMESPACE}' logs --previous '${pod}'" "${pod_output_dir}/stdout-previous.log"
    fi 
}

##
## Main
##

# Create a temporary folder if the output is an archive
if [[ "${OUTPUT_FILE_OR_DIRECTORY}" == *.tar.gz ]]; then
    archive=true
    TEMP_DIR=$(mktemp -d)

    # Paths should be relative to <TEMP_DIR> so <basename>.tar.gz file contains a single directory <basename>
    pushd "${TEMP_DIR}" > /dev/null
    OUTPUT_DIR="$(basename "${OUTPUT_FILE_OR_DIRECTORY%.tar.gz}")"

    cleanup() {
        rm -rf "${TEMP_DIR}"
    }
    trap cleanup EXIT SIGINT SIGTERM
else
    archive=false
    OUTPUT_DIR="${OUTPUT_FILE_OR_DIRECTORY}"
fi

mkdir -p "${OUTPUT_DIR}"


# Redirect all output to a log file included in the tar.gz
tbtoollog="${OUTPUT_DIR}/tbtool.log"
exec > >(tee -a ${tbtoollog}) 2>&1
echo "🔍 Collecting information for namespace ${NAMESPACE}"

if [[ "${NO_HELM}" != "true" ]]; then
    # Helm (consider yaml/json output)
    collect_info "helm list --namespace '${NAMESPACE}'" "${OUTPUT_DIR}/helm-releases.txt"

    # All helm releases containing spotfire components
    helmReleases=$(kubectl get pods --namespace "${NAMESPACE}" -l app.kubernetes.io/managed-by=Helm,app.kubernetes.io/part-of=spotfire --output=jsonpath='{.items[*].metadata.labels.app\.kubernetes\.io\/instance}' | tr ' ' '\n' | sort -u | tr '\n' ' ')
    for helmRelease in ${helmReleases}; do
        collect_info "helm get values '${helmRelease}' --namespace '${NAMESPACE}'" "${OUTPUT_DIR}/helm-release-${helmRelease}-values.yaml"
    done
else
    echo "ℹ️ Skipping helm releases and values"
fi

# Cluster info
if [[ "${NO_CLUSTER_INFO}" != "true" ]]; then
    collect_info "kubectl cluster-info" "${OUTPUT_DIR}/cluster-info.txt"
    collect_info "kubectl get nodes -o yaml" "${OUTPUT_DIR}/nodes.yaml"
    collect_info "kubectl version" "${OUTPUT_DIR}/version.txt"
else
    echo "ℹ️ Skipping cluster information"
fi

# Namespaced objects
for kind in "${KUBERNETES_KINDS[@]:-${DEFAULT_KUBERNETES_TYPES[@]}}"; do
    collect_info "kubectl get '${kind}' --namespace '${NAMESPACE}' -o yaml" "${OUTPUT_DIR}/${kind}.yaml"
    collect_info "kubectl describe '${kind}' --namespace '${NAMESPACE}'" "${OUTPUT_DIR}/${kind}.txt"
done

# Events
kubectl_events_nowatch_columns="FirstSeen:.firstTimestamp,LastSeen:.lastTimestamp,Count:.count,From:.source.component,Kind:.involvedObject.kind,Object:.involvedObject.name,Type:.type,Reason:.reason,Message:.message"
collect_info "kubectl get events --namespace '${NAMESPACE}' --sort-by=.metadata.creationTimestamp -o custom-columns='${kubectl_events_nowatch_columns}'" "${OUTPUT_DIR}/events.txt"

spotfire_selector="app.kubernetes.io/part-of=spotfire"
# Spotfire pods container stdout
allPods=$(kubectl --namespace "${NAMESPACE}" get pods --output=jsonpath='{.items[*].metadata.name}' --selector="${spotfire_selector}")
for pod in ${allPods}; do
    fetch_pod_info_and_logs "${pod}"
done

# Job pods container stdout
allJobs=$(kubectl --namespace "${NAMESPACE}" get jobs --output=jsonpath='{.items[*].metadata.name}' --selector="${spotfire_selector}")
for job in ${allJobs}; do
    collect_info "kubectl --namespace '${NAMESPACE}' logs job/${job}" "${OUTPUT_DIR}/job-${job}-log.txt"
done

# Loop to copy server logs
server_selector="app.kubernetes.io/component=server"
serverPods=$(kubectl --namespace "${NAMESPACE}" get pods --output=jsonpath='{.items[*].metadata.name}' --selector=${server_selector})
for serverPod in ${serverPods}; do
    copy_applogs "${serverPod}" "spotfire-server" "spotfireserver/tomcat/logs" || :
done

# Loop to copy component logs
components="webplayer automationservices pythonservice terrservice rservice"
for component in ${components}; do
    component_selector="app.kubernetes.io/component=${component}"
    componentPods=$(kubectl --namespace "${NAMESPACE}" get pods --output=jsonpath='{.items[*].metadata.name}' --selector="${component_selector}")
    for componentPod in ${componentPods}; do
        containers=$(kubectl get pod "${componentPod}" --namespace "${NAMESPACE}" --output=jsonpath='{.spec.containers[*].name}')
        for container in ${containers}; do
            if [[ ${container} == spotfire-* ]]; then
                copy_applogs "${componentPod}" "${container}" "nm/logs" || :
            fi
        done
    done
done

if [[ "${archive}" == "true" ]]; then
    popd
    echo "📦 Adding files to archive ${OUTPUT_FILE_OR_DIRECTORY}"
    tar -czf "${OUTPUT_FILE_OR_DIRECTORY}" -C "${TEMP_DIR}" --remove-files "${OUTPUT_DIR}"
else
    echo "🗂️ Files are located in $(realpath "${OUTPUT_DIR}")"
    trap - EXIT SIGINT SIGTERM
fi

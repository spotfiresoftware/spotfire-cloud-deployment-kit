{{/*
Pod Deletion Cost updater script
*/}}
{{- define "spotfire-common.poddeletioncost.script.update-poddeletioncost.sh" -}}
#!/bin/bash

set -o errexit
set -o nounset

if [ "$#" -ne 6 ]; then
    echo "Usage: $0 <pod_selector> <cost_formula> <sleep_interval_seconds> <threshold_percent> <min_abs_delta> <target_container_name>" >&2
    exit 2
fi

POD_SELECTOR="$1"
COST_FORMULA="$2"
SLEEP_INTERVAL_SECONDS="$3"
THRESHOLD_PERCENT="$4"
MIN_ABS_DELTA="$5"
TARGET_CONTAINER_NAME="$6"

if ! [[ "$SLEEP_INTERVAL_SECONDS" =~ ^[0-9]+$ ]]; then
    echo "SLEEP_INTERVAL_SECONDS must be an integer (seconds): $SLEEP_INTERVAL_SECONDS" >&2
    exit 1
fi

if ! [[ "$THRESHOLD_PERCENT" =~ ^[0-9]+$ ]]; then
    echo "THRESHOLD_PERCENT must be an integer: $THRESHOLD_PERCENT" >&2
    exit 1
fi

if ! [[ "$MIN_ABS_DELTA" =~ ^[0-9]+$ ]]; then
    echo "MIN_ABS_DELTA must be an integer: $MIN_ABS_DELTA" >&2
    exit 1
fi

echo "[$(date -Iseconds)] [ ] Starting Spotfire Pod Deletion Cost Updater with the following parameters..."
echo "[$(date -Iseconds)]     POD_SELECTOR: $POD_SELECTOR"
echo "[$(date -Iseconds)]     COST_FORMULA: $COST_FORMULA"
echo "[$(date -Iseconds)]     SLEEP_INTERVAL_SECONDS: $SLEEP_INTERVAL_SECONDS"
echo "[$(date -Iseconds)]     THRESHOLD_PERCENT: $THRESHOLD_PERCENT"
echo "[$(date -Iseconds)]     MIN_ABS_DELTA: $MIN_ABS_DELTA"
echo "[$(date -Iseconds)]     TARGET_CONTAINER_NAME: $TARGET_CONTAINER_NAME"

while true; do
    echo "[$(date -Iseconds)] [ ] Fetching pod information..."
    PODS_JSON=$(kubectl get pods -l "$POD_SELECTOR" --field-selector=status.phase=Running -o json 2>/dev/null)

    if [ -z "$PODS_JSON" ] || [ "$(echo "$PODS_JSON" | jq '.items | length')" -eq 0 ]; then
        echo "[$(date -Iseconds)] [!] No running pods found."
        sleep "$SLEEP_INTERVAL_SECONDS"
        continue
    fi

    echo "$PODS_JSON" | jq -c '.items[]' | while read -r pod; do
        POD_NAME=$(echo "$pod" | jq -r '.metadata.name')

        # Check that the target service container is both started and ready
        TARGET_STARTED=$(echo "$pod" | jq -r --arg targetContainerName "$TARGET_CONTAINER_NAME" '.status.containerStatuses[] | select(.name==$targetContainerName) | .started // false')
        TARGET_READY=$(echo "$pod" | jq -r --arg targetContainerName "$TARGET_CONTAINER_NAME" '.status.containerStatuses[] | select(.name==$targetContainerName) | .ready // false')
        if [ "$TARGET_STARTED" != "true" ] || [ "$TARGET_READY" != "true" ]; then
            echo "[$(date -Iseconds)] [-] Skipping $POD_NAME: $TARGET_CONTAINER_NAME container not started and ready (started=$TARGET_STARTED, ready=$TARGET_READY)"
            continue
        fi

        # NO DEFAULTS: Extract annotations. If they don't exist, jq returns 'null'
        PROM_PATH=$(echo "$pod" | jq -r '.metadata.annotations["prometheus.io/path"]')
        PROM_PORT=$(echo "$pod" | jq -r '.metadata.annotations["prometheus.io/port"]')
        POD_IP=$(echo "$pod" | jq -r '.status.podIP')

        # Strictly skip if annotations or IP are missing
        if [ "$PROM_PATH" == "null" ] || [ "$PROM_PORT" == "null" ] || [ -z "$POD_IP" ] || [ "$POD_IP" == "null" ]; then
            echo "[$(date -Iseconds)] [-] Skipping $POD_NAME due to missing annotations or IP (PROM_PATH=$PROM_PATH, PROM_PORT=$PROM_PORT, POD_IP=$POD_IP)"
            continue
        fi

        # 1. Fetch all metrics from the pod
        METRICS_DATA=$(curl -s --connect-timeout 5 "http://${POD_IP}:${PROM_PORT}${PROM_PATH}")
        if [ -z "$METRICS_DATA" ]; then
            echo "[$(date -Iseconds)] [!] Failed to fetch metrics for $POD_NAME"
            continue
        fi

        # 2. Evaluate cost using AWK from formula and fetched prometheus metrics
        FORMULA=$(echo "${METRICS_DATA}" | awk -v formula="$COST_FORMULA" -f /scripts/extract-formula-with-values.awk)
        NEW_COST=$(awk "BEGIN {printf \"%.0f\", $FORMULA}")

        if [ -z "$NEW_COST" ]; then
            echo "[$(date -Iseconds)] [!] Failed to calculate new cost for $POD_NAME"
            continue
        fi

        # 3. Apply Delta Logic
        # baseline is 0 (K8s default)
        CURRENT_COST=$(echo "$pod" | jq -r '.metadata.annotations["controller.kubernetes.io/pod-deletion-cost"] // "0"')
        DIFF=$(( NEW_COST - CURRENT_COST ))
        ABS_DIFF=${DIFF#-}

        UPDATE_NEEDED=false
        if [ "$ABS_DIFF" -ge "$MIN_ABS_DELTA" ]; then
            UPDATE_NEEDED=true
        elif [ "$CURRENT_COST" -ne 0 ]; then
            PCT=$(( (ABS_DIFF * 100) / (CURRENT_COST < 0 ? -CURRENT_COST : CURRENT_COST) ))
            if [ "$PCT" -ge "$THRESHOLD_PERCENT" ]; then UPDATE_NEEDED=true; fi
        fi

        # Only patch if cost changed by % or min absolute delta
        if [ "$UPDATE_NEEDED" == "true" ]; then
            echo "[$(date -Iseconds)] [+] Calculated $NEW_COST for $POD_NAME (Prev: $CURRENT_COST)"
            kubectl annotate pod "$POD_NAME" "controller.kubernetes.io/pod-deletion-cost=$NEW_COST" --overwrite

            # Small sleep to prevent API burst if multiple pods need updating
            sleep 0.2
        else
            echo "[$(date -Iseconds)] [-] No significant change for $POD_NAME: $CURRENT_COST (New: $NEW_COST)"
        fi
    done

    sleep "$SLEEP_INTERVAL_SECONDS"
  done
{{- end -}}

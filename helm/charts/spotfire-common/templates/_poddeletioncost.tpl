{{/*
Pod Deletion Cost name
*/}}
{{- define "spotfire-common.poddeletioncost.name" -}}
{{- printf "%s-%s-%s" .Release.Name .Chart.Name "pdc" | trunc 63 | trimSuffix "-" }}
{{- end -}}

{{/*
Pod Deletion Cost config map
*/}}
{{- define "spotfire-common.poddeletioncost.configMap" -}}
{{- $componentName := printf "%s-pdc" .componentName -}}
apiVersion: v1
kind: ConfigMap
metadata:
  annotations:
    use-subpath: "true"
  creationTimestamp: null
  labels:
    {{- include "spotfire-common.spotfire-service.labels" (mergeOverwrite (dict) . (dict "componentName" $componentName)) | nindent 4 }}
  name: {{ include "spotfire-common.poddeletioncost.name" . }}
data:
  extract-formula-with-values.awk: |
{{ include "spotfire-common.poddeletioncost.script.extract-formula-with-values.awk" . | nindent 4 }}
  update-poddeletioncost.sh: |
{{ include "spotfire-common.poddeletioncost.script.update-poddeletioncost.sh" . | nindent 4 }}
{{- end -}}

{{/*
Pod Deletion Cost service account
*/}}
{{- define "spotfire-common.poddeletioncost.serviceAccount" -}}
{{- $componentName := printf "%s-pdc" .componentName -}}
apiVersion: v1
kind: ServiceAccount
metadata:
  name: {{ include "spotfire-common.poddeletioncost.name" . }}
  labels:
    {{- include "spotfire-common.spotfire-service.labels" (mergeOverwrite (dict) . (dict "componentName" $componentName)) | nindent 4 }}
{{- end -}}

{{/*
Pod Deletion Cost role
*/}}
{{- define "spotfire-common.poddeletioncost.role" -}}
{{- $componentName := printf "%s-pdc" .componentName -}}
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: {{ include "spotfire-common.poddeletioncost.name" . }}
  labels:
    {{- include "spotfire-common.spotfire-service.labels" (mergeOverwrite (dict) . (dict "componentName" $componentName)) | nindent 4 }}
rules:
  - apiGroups: [""]
    resources: ["pods"]
    verbs: ["get", "list", "patch"]
{{- end -}}

{{/*
Pod Deletion Cost role binding
*/}}
{{- define "spotfire-common.poddeletioncost.roleBinding" -}}
{{- $componentName := printf "%s-pdc" .componentName -}}
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: {{ include "spotfire-common.poddeletioncost.name" . }}
  labels:
    {{- include "spotfire-common.spotfire-service.labels" (mergeOverwrite (dict) . (dict "componentName" $componentName)) | nindent 4 }}
subjects:
  - kind: ServiceAccount
    name: {{ include "spotfire-common.poddeletioncost.name" . }}
    namespace: {{ .Release.Namespace }}
roleRef:
  kind: Role
  name: {{ include "spotfire-common.poddeletioncost.name" . }}
  apiGroup: rbac.authorization.k8s.io
{{- end -}}

{{/*
Pod Deletion Cost deployment
*/}}
{{- define "spotfire-common.poddeletioncost.deployment" -}}
{{- $componentName := printf "%s-pdc" .componentName -}}
{{- $updaterContainerName := printf "spotfire-%s-pdc" .componentName -}}
{{- $targetContainerName := printf "spotfire-%s" .componentName -}}
{{- $podSelector := printf "app.kubernetes.io/part-of=spotfire,app.kubernetes.io/component=%s,app.kubernetes.io/instance=%s" .componentName .Release.Name -}}
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ include "spotfire-common.poddeletioncost.name" . }}
  labels:
    {{- include "spotfire-common.spotfire-service.labels" (mergeOverwrite (dict) . (dict "componentName" $componentName)) | nindent 4 }}
spec:
  replicas: {{ .Values.podDeletionCost.replicaCount }}
  strategy:
    type: Recreate
  selector:
    matchLabels:
      {{- include "spotfire-common.spotfire-service.selectorLabels" (mergeOverwrite (dict) . (dict "componentName" $componentName)) | nindent 6 }}
  template:
    metadata:
      annotations:
        checksum/poddeletioncost-scripts: {{ include "spotfire-common.poddeletioncost.configMap" . | sha256sum }}
      labels:
        {{- include "spotfire-common.spotfire-service.labels" (mergeOverwrite (dict) . (dict "componentName" $componentName)) | nindent 8 }}
    spec:
      {{- include "spotfire-common.images.imagePullSecrets" (dict "image" .Values.podDeletionCost.image "globalPath" .Values.global.spotfire) | nindent 6 }}
      serviceAccountName: {{ include "spotfire-common.poddeletioncost.name" . }}
      containers:
      - name: {{ $updaterContainerName }}
        image: "{{ include "spotfire-common.images.image" (dict "image" .Values.podDeletionCost.image "globalPath" .Values.global.spotfire) }}"
        imagePullPolicy: "{{ include "spotfire-common.images.imagePullPolicy" (dict "image" .Values.podDeletionCost.image "globalPath" .Values.global.spotfire) }}"
        command: ["/bin/bash", "-c"]
        args:
        - |
          echo "Starting script..."
          /scripts/update-poddeletioncost.sh \
            {{ $podSelector | quote }} \
            {{ tpl (printf "%v" .Values.podDeletionCost.costFormula) $ | quote }} \
            {{ tpl (printf "%v" .Values.podDeletionCost.sleepIntervalSeconds) $ | quote }} \
            {{ tpl (printf "%v" .Values.podDeletionCost.thresholdPercent) $ | quote }} \
            {{ tpl (printf "%v" .Values.podDeletionCost.minAbsDelta) $ | quote }} \
            {{ $targetContainerName | quote }}

        volumeMounts:
          - name: script-vol
            mountPath: /scripts
        resources:
          {{- toYaml .Values.podDeletionCost.resources | nindent 12 }}
      volumes:
        - name: script-vol
          configMap:
            name: {{ include "spotfire-common.poddeletioncost.name" . }}
            # 0755 provides read/execute permissions to everyone
            defaultMode: 0755
{{- end -}}
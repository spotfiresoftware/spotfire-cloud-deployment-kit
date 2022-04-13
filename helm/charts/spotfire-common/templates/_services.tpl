{{/*
Expand the name of the chart.
*/}}
{{- define "spotfire-common.spotfire-service.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "spotfire-common.spotfire-service.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "spotfire-common.spotfire-service.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "spotfire-common.spotfire-service.labels" -}}
helm.sh/chart: {{ include "spotfire-common.spotfire-service.chart" . }}
{{ include "spotfire-common.spotfire-service.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "spotfire-common.spotfire-service.selectorLabels" -}}
app.kubernetes.io/name: {{ include "spotfire-common.spotfire-service.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/part-of: spotfire
app.kubernetes.io/component: {{ include "spotfire-service.component.name" . }}
{{- end }}

{{/*
Create the name of the spotfire-service account to use
*/}}
{{- define "spotfire-common.spotfire-service.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "spotfire-common.spotfire-service.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Return the proper image name (for spotfire-service image)
*/}}
{{- define "spotfire-common.spotfire-service.image" -}}
{{- include "spotfire-common.images.image" (dict "image" .Values.image "globalPath" .Values.global.spotfire ) -}}
{{- end -}}

{{/*
Return the proper image pullPolicy (for spotfire-service image)
*/}}
{{- define "spotfire-common.spotfire-service.image.pullPolicy" -}}
{{- include "spotfire-common.images.imagePullPolicy" (dict "image" .Values.image "globalPath" .Values.global.spotfire) -}}
{{- end -}}

{{/*
Return the proper Docker Image Registry Secret Names (for spotfire-service image)
*/}}
{{- define "spotfire-common.spotfire-service.imagePullSecrets" -}}
{{- include "spotfire-common.images.imagePullSecrets" (dict "image" .Values.image "globalPath" .Values.global.spotfire) -}}
{{- end -}}

{{/*
Spotfire service packages pvc name
*/}}
{{- define "spotfire-common.spotfire-service.volumes.packages.pvc.name" -}}
{{- include "spotfire-common.persistentVolumeClaim.claimName" (dict "customClaimName" .Values.volumes.packages.customPersistentVolumeClaimName "releaseName" ( include "spotfire-common.spotfire-service.fullname" . ) "volumeName" .Values.volumes.packages.name ) -}}
{{- end -}}


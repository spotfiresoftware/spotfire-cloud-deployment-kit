{{/*
Expand the name of the chart.
*/}}
{{- define "spotfire-server.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "spotfire-server.fullname" -}}
{{- $name := .Chart.Name }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}

{{- define "spotfire-server.spotfiredatabase.secret.name" -}}
{{ $value := include "spotfire-server.fullname" . }}
{{- printf "%s-%s" $value "database" -}}
{{- end -}}

{{- define "spotfire-server.spotfireadmin.secret.name" -}}
{{ $value := include "spotfire-server.fullname" . }}
{{- printf "%s-%s" $value "spotfireadmin" -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "spotfire-server.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "spotfire-server.labels" -}}
helm.sh/chart: {{ include "spotfire-server.chart" . }}
{{ include "spotfire-server.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
labels for cli pod
*/}}
{{- define "spotfire-server.cli.labels" -}}
helm.sh/chart: {{ include "spotfire-server.chart" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/name: {{ include "spotfire-server.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/part-of: spotfire
app.kubernetes.io/component: cli
{{- end }}

{{/*
Selector labels
*/}}
{{- define "spotfire-server.selectorLabels" -}}
app.kubernetes.io/name: {{ include "spotfire-server.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/part-of: spotfire
app.kubernetes.io/component: server
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "spotfire-server.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "spotfire-server.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Database info needed to bootstrap server
*/}}
{{- define "spotfire-server.database.envVars" -}}
- name: SPOTFIREDB_URL
  value: {{ required "database.url must be set" .Values.database.url | quote }}
- name: SPOTFIREDB_DBNAME
  value: {{ required "database.name" .Values.database.name | quote }}
- name: SPOTFIREDB_USERNAME
  valueFrom:
    secretKeyRef:
      name: {{ include "spotfire-server.spotfiredatabase.secret.name" . | quote }}
      key: SPOTFIREDB_USERNAME
- name: SPOTFIREDB_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ include "spotfire-server.spotfiredatabase.secret.name" . | quote }}
      key: SPOTFIREDB_PASSWORD
- name: SPOTFIREDB_CLASS
  value: {{ .Values.database.driverClass | quote }}
- name: TOOL_PASSWORD
  value: {{ .Values.toolPassword | quote }}
{{- end -}}

{{/*
Configuration job environment variables
*/}}
{{- define "spotfire-server.configVars" -}}
- name: BOOTSTRAP_TIMEOUT_SECONDS
  value: "40"
- name: BOOTSTRAP_DELAY_INTERVAL_SECONDS
  value: "5"
- name: BOOTSTRAP_FILE
  value: "bootstrap.xml"
- name: CONFIGURATION_FILE
  value: "configuration.xml"
{{- end -}}

{{/*
Database admin credentials environment variables needed to create a Spotfire schema
*/}}
{{- define "spotfire-server.database.adminEnvVars" -}}
{{- if .Values.database.create -}}
- name: DBSERVER_ADMIN_USERNAME
  value: {{ required "database.admin.user must be set" .Values.database.admin.user | quote }}
- name: DBSERVER_ADMIN_PASSWORD
  value: {{ required "database.admin.password must be set" .Values.database.admin.password | quote }}
- name: DBSERVER_CLASS
  value: {{ required "database.driverClass must be set" .Values.database.driverClass | quote }}
- name: DBSERVER_URL
  value: {{ required "database.admin.url must be set" .Values.database.admin.url | quote }}
{{- end -}}
{{- end -}}

{{/*
Site information
*/}}
{{- define "spotfire-server.site.envVars" -}}
- name: SITE_NAME
  value: {{ .Values.site.name | quote }}
- name: SITE_DISPLAY_NAME
  value: {{ .Values.site.displayName | quote }}
- name: SITE_PUBLIC_ADDRESS
  value: {{ required "site.publicAddress must be set" .Values.site.publicAddress | quote }}
{{- end -}}

{{/*
spotfire-server jvm options
*/}}
{{- define "spotfire-server.jvm.parameter" -}}
{{- $heapdumpjavaOpts := "" -}}
{{- $extraJavaOpts := include "spotfire-server.extraJavaOpts" (dict "extraJavaOpts" .Values.spotfireServerJava.extraJavaOpts) -}}
{{- if .Values.troubleshooting.jvm.heapDumpOnOutOfMemoryError.enabled -}}
  {{-  $dumpPath := include "spotfire-server.dumpPath" . -}}
  {{-  $heapdumpjavaOpts = printf "%s -XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=%s" $heapdumpjavaOpts $dumpPath -}}
{{- end -}}
- name: JAVA_OPTS
  value: {{ printf "%s %s" $extraJavaOpts $heapdumpjavaOpts | quote }}
{{- end -}}

{{/*
Return the extraJavaOpts evaluating values
{{ include "spotfire-server.extraJavaOpts" ( dict "extraJavaOpts" .Values.spotfireServerJava.extraJavaOpts ) }}
*/}}
{{- define "spotfire-server.extraJavaOpts" -}}
{{- $extraJavaOpts := ""}}
{{- if .extraJavaOpts -}}
  {{- range .extraJavaOpts -}}
    {{- $extraJavaOpts = printf "%s %s" $extraJavaOpts . -}}
  {{- end -}}
{{- end }}
{{- printf "%s" $extraJavaOpts }}
{{- end -}}

{{/*
jvm heap dump path
*/}}
{{- define "spotfire-server.dumpPath" -}}
  {{- .Values.troubleshooting.jvm.heapDumpOnOutOfMemoryError.dumpPath -}}
{{- end -}}

{{/*
Return the proper image name (for spotfireServer image)
*/}}
{{- define "spotfire-server.image" -}}
{{- include "spotfire-common.images.image" (dict "image" .Values.image "globalPath" .Values.global.spotfire) -}}
{{- end -}}

{{/*
Return the proper image name (for spotfireConfig image)
*/}}
{{- define "spotfire-server.spotfireConfig.image" -}}
{{- include "spotfire-common.images.image" (dict "image" .Values.spotfireConfig.image "globalPath" .Values.global.spotfire) -}}
{{- end -}}

{{/*
Return the proper Docker Image Registry Secret Names (for spotfireServer image)
*/}}
{{- define "spotfire-server.imagePullSecrets" -}}
{{- include "spotfire-common.images.imagePullSecrets" (dict "image" .Values.image "globalPath" .Values.global.spotfire) -}}
{{- end -}}

{{/*
Return the proper Docker Image Registry Secret Names (for spotfireConfig image)
*/}}
{{- define "spotfire-server.spotfireConfig.imagePullSecrets" -}}
{{- include "spotfire-common.images.imagePullSecrets" (dict "image" .Values.spotfireConfig.image "globalPath" .Values.global.spotfire) -}}
{{- end -}}

{{/*
Return the proper image pullPolicy (for spotfireServer image)
*/}}
{{- define "spotfire-server.image.pullPolicy" -}}
{{- include "spotfire-common.images.imagePullPolicy" (dict "image" .Values.image "globalPath" .Values.global.spotfire) -}}
{{- end -}}

{{/*
Return the proper image pullPolicy (for spotfireConfig image)
*/}}
{{- define "spotfire-server.spotfireConfig.image.pullPolicy" -}}
{{- include "spotfire-common.images.imagePullPolicy" (dict "image" .Values.spotfireConfig.image "globalPath" .Values.global.spotfire) -}}
{{- end -}}

{{/*
Spotfire custom-ext pvc name
*/}}
{{- define "spotfire-server.volumes.custom-ext.pvc.name" -}}
{{- include "spotfire-common.persistentVolumeClaim.claimName" (dict "customClaimName" .Values.volumes.customExt.customPersistentVolumeClaimName) -}}
{{- end -}}

{{/*
Spotfire library import/export pvc name
*/}}
{{- define "spotfire-server.volumes.library-import-export.pvc.name" -}}
{{- include "spotfire-common.persistentVolumeClaim.claimName" (dict "customClaimName" .Values.volumes.libraryImportExport.customPersistentVolumeClaimName "releaseName" ( include "spotfire-server.fullname" . ) "volumeName" .Values.volumes.libraryImportExport.name ) -}}
{{- end -}}

{{/*
Spotfire deployment pvc name
*/}}
{{- define "spotfire-server.volumes.deployments.pvc.name" -}}
{{- include "spotfire-common.persistentVolumeClaim.claimName" (dict "customClaimName" .Values.volumes.spotfireDeployments.customPersistentVolumeClaimName) -}}
{{- end -}}


{{/*
Spotfire custom certificate storage folder pvc name
*/}}
{{- define "spotfire-server.volumes.custom-certificate-storage.pvc.name" -}}
{{- include "spotfire-common.persistentVolumeClaim.claimName" (dict "customClaimName" .Values.volumes.customCertsFolder.customPersistentVolumeClaimName ) -}}
{{- end -}}

{{/*
Spotfire troubleshooting storage folder pvc name
*/}}
{{- define "spotfire-server.troubleshooting.pvc.name" -}}
{{- include "spotfire-common.persistentVolumeClaim.claimName" (dict "customClaimName" .Values.volumes.troubleshooting.customPersistentVolumeClaimName "releaseName" ( include "spotfire-server.fullname" . ) "volumeName" .Values.volumes.troubleshooting.name ) -}}
{{- end -}}

{{/*
Emulates spotfire-server.fullname the spotfire-server parent chart
*/}}
{{- define "haproxy.spotfire-server.fullname" -}}
{{- $name := "spotfire-server" }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end -}}

{{- define "spotfire-server.spotfireConfig.fullname" -}}
{{- $name := .Chart.Name }}
{{- printf "%s-%s-%d" .Release.Name "config-job" .Release.Revision }}
{{- end }}
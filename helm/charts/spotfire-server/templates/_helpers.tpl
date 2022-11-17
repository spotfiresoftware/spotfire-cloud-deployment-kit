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


/*
Spotfire database secrets
*/
{{- define "spotfire-server.spotfiredatabase.secret.name" -}}
{{- if .Values.database.bootstrap.existingSecret -}}
{{- .Values.database.bootstrap.existingSecret }}
{{- else -}}
{{- printf "%s-%s" (include "spotfire-server.fullname" .) "database" -}}
{{- end -}}
{{- end -}}

/*
Spotfire administrator secrets
*/
{{- define "spotfire-server.spotfireadmin.secret.name" -}}
{{- or .Values.spotfireAdmin.existingSecret (printf "%s-%s" (include "spotfire-server.fullname" .) "spotfireadmin") -}}
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
{{ include "spotfire-server.cli.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels for cli pod
*/}}
{{- define "spotfire-server.cli.selectorLabels" -}}
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
Database info needed to bootstrap and upgrade server
*/}}
{{- define "spotfire-server.database.envVars" -}}
- name: SPOTFIREDB_URL
  value: {{ required "database.bootstrap.databaseUrl must be set" .Values.database.bootstrap.databaseUrl | quote }}
- name: SPOTFIREDB_USERNAME
  valueFrom:
    secretKeyRef:
      name: {{ include "spotfire-server.spotfiredatabase.secret.name" . | quote }}
      key: SPOTFIREDB_USERNAME
      optional: false
- name: SPOTFIREDB_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ include "spotfire-server.spotfiredatabase.secret.name" . | quote }}
      key: SPOTFIREDB_PASSWORD
      optional: false
- name: SPOTFIREDB_CLASS
  value: {{ required "driver class must be set" .Values.database.bootstrap.driverClass | quote }}
- name: TOOL_PASSWORD
  value: {{ .Values.toolPassword | quote }}
{{- if .Values.encryptionPassword }}
- name: ENCRYPTION_PASSWORD
  value: {{ .Values.encryptionPassword | quote }}
{{- end }}
{{- end -}}

{{/*
Spotfire administration username and password
*/}}
{{- define "spotfire-server.spotfireadmin.envVars" -}}
- name: SPOTFIREADMIN_USERNAME
  valueFrom:
    secretKeyRef:
      name: {{ include "spotfire-server.spotfireadmin.secret.name" . | quote }}
      key: SPOTFIREADMIN_USERNAME
      optional: false
- name: SPOTFIREADMIN_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ include "spotfire-server.spotfireadmin.secret.name" . | quote }}
      key: SPOTFIREADMIN_PASSWORD
      optional: false
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
{{- $createdb := (index .Values "database" "create-db") -}}
- name: SPOTFIREDB_DBNAME
  value: {{ $createdb.spotfiredbDbname | quote }}
{{- if index $createdb.enabled }}
{{- if (and $createdb.adminPasswordExistingSecret.name $createdb.adminPasswordExistingSecret.key) }}
- name: DBSERVER_ADMIN_USERNAME
  valueFrom:
    secretKeyRef:
      name: {{ $createdb.adminUsernameExistingSecret.name | quote }}
      key: {{ $createdb.adminUsernameExistingSecret.key | quote }}
{{- else }}
- name: DBSERVER_ADMIN_USERNAME
  value: {{ required "database.create-db.adminUsername must be set" $createdb.adminUsername | quote }}
{{- end }}
{{- if (and $createdb.adminPasswordExistingSecret.name $createdb.adminPasswordExistingSecret.key) }}
- name: DBSERVER_ADMIN_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ $createdb.adminPasswordExistingSecret.name | quote }}
      key: {{ $createdb.adminPasswordExistingSecret.key | quote }}
{{- else }}
- name: DBSERVER_ADMIN_PASSWORD
  value: {{ required "database.create-db.adminPassword must be set" $createdb.adminPassword | quote }}
{{- end }}
- name: DBSERVER_CLASS
  value: {{ required "database.bootstrap.driverClass must be set" .Values.database.bootstrap.driverClass | quote }}
- name: DBSERVER_URL
  value: {{ required "database.create-db.databaseUrl must be set" $createdb.databaseUrl | quote }}
- name: DO_NOT_CREATE_USER
  value: {{ $createdb.doNotCreateUser | quote }}
- name: VARIANT
  value: {{ $createdb.variant | quote }}
- name: ORACLE_TABLESPACE_PREFIX
  value: {{ $createdb.oracleTablespacePrefix | quote }}
- name: ORACLE_ROOT_FOLDER
  value: {{ $createdb.oracleRootfolder | quote }}
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
Get PVC name for persistent volume
*/}}
{{- define "spotfire-server.persistentVolumeClaim.claimName" -}}
{{- .existingClaim | default (printf "%s-%s" .releaseName .volumeName) -}}
{{- end -}}

{{/*
Spotfire troubleshooting storage folder pvc name
*/}}
{{- define "spotfire-server.troubleshooting.pvc.name" -}}
{{- include "spotfire-server.persistentVolumeClaim.claimName" (dict "existingClaim" .Values.volumes.troubleshooting.existingClaim "releaseName" ( include "spotfire-server.fullname" . ) "volumeName" "troubleshooting" ) -}}
{{- end -}}

{{/*
Spotfire library import/export pvc name
*/}}
{{- define "spotfire-server.volumes.library-import-export.pvc.name" -}}
{{- include "spotfire-server.persistentVolumeClaim.claimName" (dict "existingClaim" .Values.volumes.libraryImportExport.existingClaim "releaseName" ( include "spotfire-server.fullname" . ) "volumeName" "library-import-export" ) -}}
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

{{/*
Return the proper Container Image Registry Secret Names (for configJob Job)
*/}}
{{- define "spotfire-server.configJob.fullname" -}}
{{ printf "%s-%s-%d" .Release.Name "config-job" .Release.Revision }}
{{- end -}}
{{/*

======
IMAGES
======
*/}}

{{/*
Return the proper image name (for spotfireServer image)
*/}}
{{- define "spotfire-server.image" -}}
{{- include "spotfire-common.images.image" (dict "image" .Values.image "globalPath" .Values.global.spotfire) -}}
{{- end -}}

{{/*
Return the proper image pullPolicy (for spotfireServer image)
*/}}
{{- define "spotfire-server.image.pullPolicy" -}}
{{- include "spotfire-common.images.imagePullPolicy" (dict "image" .Values.image "globalPath" .Values.global.spotfire) -}}
{{- end -}}

{{/*
Return the proper Container Image Registry Secret Names (for spotfire server deployment)
*/}}
{{- define "spotfire-server.imagePullSecrets" -}}
{{- include "spotfire-common.images.imagePullSecrets" (dict "image" .Values.image "globalPath" .Values.global.spotfire) -}}
{{- end -}}

{{/*
Return the proper image name (for cliPod image)
*/}}
{{- define "spotfire-server.cliPod.image" -}}
{{- include "spotfire-common.images.image" (dict "image" .Values.cliPod.image "globalPath" .Values.global.spotfire) -}}
{{- end -}}

{{/*
Return the proper image pullPolicy (for cliPod image)
*/}}
{{- define "spotfire-server.cliPod.image.pullPolicy" -}}
{{- include "spotfire-common.images.imagePullPolicy" (dict "image" .Values.cliPod.image "globalPath" .Values.global.spotfire) -}}
{{- end -}}

{{/*
Return the proper Container Image Registry Secret Names (for cliPod deployment)
*/}}
{{- define "spotfire-server.cliPod.imagePullSecrets" -}}
{{- include "spotfire-common.images.imagePullSecrets" (dict "image" .Values.cliPod.image "globalPath" .Values.global.spotfire) -}}
{{- end -}}


{{/*
Return the proper image name (for configJob image)
*/}}
{{- define "spotfire-server.configJob.image" -}}
{{- include "spotfire-common.images.image" (dict "image" .Values.configJob.image "globalPath" .Values.global.spotfire) -}}
{{- end -}}

{{/*
Return the proper image pullPolicy (for configJob image)
*/}}
{{- define "spotfire-server.configJob.image.pullPolicy" -}}
{{- include "spotfire-common.images.imagePullPolicy" (dict "image" .Values.configJob.image "globalPath" .Values.global.spotfire) -}}
{{- end -}}

{{/*
Return the proper Container Image Registry Secret Names (for configJob Job)
*/}}
{{- define "spotfire-server.configJob.imagePullSecrets" -}}
{{- include "spotfire-common.images.imagePullSecrets" (dict "image" .Values.configJob.image "globalPath" .Values.global.spotfire) -}}
{{- end -}}

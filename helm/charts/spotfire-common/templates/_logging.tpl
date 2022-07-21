{{/*
Logging environment environment variables needed by spotfire
*/}}
{{- define "spotfire-common.spotfire-service.logging.serverEnvVars" -}}
{{- if .Values.logLevel -}}
- name: LOGGING_LOGLEVEL
  value: {{ .Values.logLevel | quote }}
{{- end -}}
{{/*
{{- if (index .Values "log-forwarder").enabled  }}
- name: LOGGING_JSON_HOST
  value: {{ include "spotfire.log-forwarder.fullname" . | quote }}
- name: LOGGING_JSON_PORT
  value: "5170"
{{- end }}
*/}}
{{- end -}}

{{/* Variables used by sidecar logging container to annotate log entries with POD information */}}
{{- define "spotfire-common.spotfire-service.logging.podAnnotationsEnvVars" -}}
- name: POD_NAME
  valueFrom:
    fieldRef:
      fieldPath: metadata.name
- name: POD_NAMESPACE
  valueFrom:
    fieldRef:
      fieldPath: metadata.namespace
- name: POD_ID
  valueFrom:
    fieldRef:
      fieldPath: metadata.uid
{{- end -}}

{{/*
Evaluates the name of the fluent-bit = log-forwarder name. Should evaluate
exactly as template "fluent-bit.fullname" but in the context of the
"spotfire" chart.
*/}}
{{- define "spotfire-common.spotfire-service.log-forwarder.fullname" -}}
{{- $values := (index .Values "log-forwarder") -}}
{{- $chartName := "log-forwarder" -}}
{{- if $values.fullnameOverride -}}
{{- $values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default $chartName $values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}
{{/*
Logging environment environment variables needed by spotfire
*/}}
{{- define "spotfire-common.spotfire-service.logging.serverEnvVars" -}}
{{- $logLevel := (.Values.logging.logLevel | required "logging.logLevel is required") -}}
- name: LOGGING_LOGLEVEL
  value: {{ $logLevel | quote }}
- name: NM_LOG_LEVEL
  value: {{ $logLevel | quote }}
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

{{/* Variables used by sidecar logging container to annotate log entries with POD information */}}
{{- define "spotfire-server.logging.podAnnotationsEnvVars" -}}
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
{{- define "spotfire-server.log-forwarder.fullname" -}}
{{ $logForwarderAddress:= (tpl .Values.logging.logForwarderAddress $) }}
{{- if $logForwarderAddress -}}
  {{- printf "%s" $logForwarderAddress -}}
{{- else if (index .Values "log-forwarder").enabled -}}
  {{- $name := "log-forwarder" -}}
    {{- if contains $name .Release.Name -}}
      {{- .Release.Name | trunc 63 | trimSuffix "-" -}}
    {{- else -}}
      {{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
    {{- end -}}
{{- end -}}
{{- end -}}

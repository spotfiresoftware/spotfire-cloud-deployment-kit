{{/*
Set ACCEPT_EUA variable to Y if .Values.acceptEUA or .Values.global.spotfire.acceptEUA is set to true
*/}}
{{- define "spotfire-common.acceptEUAEnvVar" -}}
{{- 
$accepteua := .Values.global.spotfire.acceptEUA | default .Values.acceptEUA
-}}
{{- if eq "true" (printf "%t" $accepteua) }}
- name: ACCEPT_EUA
  value: "Y"
{{- else -}}
{{ fail "You must accept the Cloud Software Group, Inc. End User Agreement (https://terms.tibco.com/#end-user-agreement) by setting .Values.acceptEUA or .Values.global.spotfire.acceptEUA to true" }}
{{- end -}}
{{- end -}}
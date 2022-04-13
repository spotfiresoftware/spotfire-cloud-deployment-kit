{{/*
Return the name of the component.
*/}}
{{- define "spotfire-service.component.name" -}}
{{ .Values.global.serviceName }}
{{- end }}

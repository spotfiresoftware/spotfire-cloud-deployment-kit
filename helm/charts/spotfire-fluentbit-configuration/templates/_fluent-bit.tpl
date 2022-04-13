{{/* 
Fluent-bit configmap name
*/}}
{{- define "spotfire-fluentbit-configuration.name" -}}
{{- printf "%s-%s-%s" .Release.Name (include "spotfire-service.component.name" .) "fluent-bit" | trunc 63 | trimSuffix "-" }}
{{- end -}}

{{/*
Volume mount configuration for fluent-bit.
*/}}
{{- define "spotfire-fluentbit-configuration.volume.mount"}}
{{- if .Values.logging.logForwarderAddress }}
- name: fluent-bit-config
  mountPath: /fluent-bit/etc/fluent-bit.conf
  subPath: tsnm.forward.fluentbit.conf
{{- else }}
- name: fluent-bit-config
  mountPath: /fluent-bit/etc/fluent-bit.conf
  subPath: tsnm.stdout.fluentbit.conf
{{- end }}
- name: fluent-bit-config
  mountPath: /fluent-bit/etc/tsnm.tail.fluentbit.conf
  subPath: tsnm.tail.fluentbit.conf
- name: fluent-bit-config
  mountPath: /fluent-bit/etc/tsnm.podannotations.fluentbit.conf
  subPath: tsnm.podannotations.fluentbit.conf
- name: fluent-bit-config
  mountPath: /fluent-bit/etc/tsnm.parsers.fluentbit.conf
  subPath: tsnm.parsers.fluentbit.conf
- name: logs-volume
  mountPath: /tsnm/logs
{{- end }}
{{/* 
Fluent-bit configmap name
*/}}
{{- define "spotfire-common.fluenbit-configuration.configmapName" -}}
{{- printf "%s-%s-%s" .Release.Name .Chart.Name "fluent-bit" | trunc 63 | trimSuffix "-" }}
{{- end -}}

{{/*
Volume mount configuration for fluent-bit.
*/}}
{{- define "spotfire-common.fluenbit-configuration.volume.mount" }}
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
  mountPath: /nodemanager/logs
{{- end }}

{{/*
preStop hook for spotfire-nodemanager based services
*/}}
{{- define "spotfire-common.fluenbit-configuration.tsnm.prestop.exec" }}
exec:
  command:
  - /fluent-bit/bin/fluent-bit
  - "-v"
  - "-i"
  - "tail"
  - "-p"
  - path=/nodemanager/logs/nodemanager-terminated
  - "-o"
  - "exit"
  - "-p"
  - "flush_count=1"
  {{- end }}
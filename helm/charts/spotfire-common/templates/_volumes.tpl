{{/*
Toubleshooting volume for spotfire-service deployment
*/}}
{{- define "spotfire-common.volumes.troubleshooting.volume" }}
- name: troubleshooting-volume
  {{- if or .Values.volumes.troubleshooting.persistentVolumeClaim.create .Values.volumes.troubleshooting.existingClaim }}
  persistentVolumeClaim:
    claimName: {{ include "spotfire-common.volumes.troubleshooting.pvc.name" . | quote }}
  {{- else }}
  emptyDir: {}
  {{- end }}
{{- end }}

{{/*
Toubleshooting volumeMount for spotfire-service deployment
*/}}
{{- define "spotfire-common.volumes.troubleshooting.volumeMount" }}
- name: troubleshooting-volume
  mountPath: /opt/tibco/troubleshooting/
  subPathExpr: $(POD_NAME)
{{- end }}

{{/*
Spotfire service troubleshooting pvc name
*/}}
{{- define "spotfire-common.volumes.troubleshooting.pvc.name" -}}
{{- .Values.volumes.troubleshooting.existingClaim | default (printf "%s-%s" (include "spotfire-common.spotfire-service.fullname" .) "troubleshooting" ) -}}
{{- end -}}

{{/*
Spotfire service packages pvc name
*/}}
{{- define "spotfire-common.volumes.packages.pvc.name" -}}
{{- .Values.volumes.packages.existingClaim | default (printf "%s-%s" (include "spotfire-common.spotfire-service.fullname" .) "packages" ) -}}
{{- end -}}

{{/*
Spotfire service troubleshooting persistentVolumeClaim  
*/}}
{{- define "spotfire-common.volumes.troubleshooting.persistentVolumeClaim" -}}
{{- if .Values.volumes.troubleshooting.persistentVolumeClaim.create }}
{{- $pvcName := (include "spotfire-common.volumes.troubleshooting.pvc.name" .) -}}
{{- $pvcCheck := (lookup "v1" "PersistentVolumeClaim" .Release.Namespace $pvcName) }}

{{- if not $pvcCheck }}
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: {{ $pvcName | quote }}
  labels:
  {{- include "spotfire-common.spotfire-service.labels" . | nindent 4 }}
  annotations:
    helm.sh/resource-policy: keep
spec:
  accessModes:
    - ReadWriteMany
  storageClassName: {{ .Values.volumes.troubleshooting.persistentVolumeClaim.storageClassName | quote }}
  {{- with .Values.volumes.troubleshooting.persistentVolumeClaim.resources }}
  resources:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  volumeName: {{ .Values.volumes.troubleshooting.persistentVolumeClaim.volumeName | quote }}
{{- end }}
{{- end }}
{{- end -}}
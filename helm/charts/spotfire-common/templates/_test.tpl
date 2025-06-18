{{/*
Test for services
Example usage:
include "spotfire-common.test.serviceCurl" (merge . (dict "componentName" "pythonservice"))
*/}}
{{- define "spotfire-common.test.serviceCurl" -}}
apiVersion: v1
kind: Pod
metadata:
  name: "{{ include "spotfire-common.spotfire-service.fullname" . }}-test-connection"
  labels:
    {{- include "spotfire-common.spotfire-service.labels" . | nindent 4 }}
  annotations:
    "helm.sh/hook": test
    "helm.sh/hook-delete-policy": hook-succeeded
spec:
  containers:
    - name: curl
      image: "{{ template "spotfire-common.spotfire-service.image" . }}"
      imagePullPolicy: "{{ template "spotfire-common.spotfire-service.image.pullPolicy" . }}"
      command: ['curl']
      args: ['-v', '--trace-time', '--retry-connrefused', '--fail', '--retry', '20', '--max-time', '300', '--retry-delay', '10', 'http://{{ include "spotfire-common.spotfire-service.fullname" . }}:9080/spotfire/liveness']
  restartPolicy: Never
{{- end -}}
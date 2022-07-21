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
      image: curlimages/curl:7.77.0
      command: ['curl']
      args: ['-v', '--retry-connrefused', '--fail', '--retry', '20', '--max-time', '300', '--retry-delay', '10', 'http://{{ include "spotfire-common.spotfire-service.fullname" . }}:9080/spotfire/liveness']
  restartPolicy: Never
{{- end -}}
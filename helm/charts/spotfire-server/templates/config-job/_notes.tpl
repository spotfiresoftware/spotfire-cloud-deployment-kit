{{- if not .Values.database.upgrade }}
Note: Database upgrade is not enabled. Set .Values.database.upgrade to true to enable automatic database upgrade on Helm install or upgrade.
{{- end }}

{{- define "spotfire-server.notes" -}}
- Login credentials for spotfire admin user

  # Spotfire Admin password for "{{ .Values.configuration.spotfireAdmin.username }}":
  export SPOTFIREADMIN_PASSWORD=$(kubectl get secrets --namespace {{ .Release.Namespace }} {{ include "spotfire-server.spotfireadmin.secret.name" . }} -o jsonpath="{.data.{{ include "spotfire-server.spotfireadmin.secret.passwordkey" . }}}" | base64 --decode)

- Spotfire database credentials

  # Database password for "{{ .Values.database.bootstrap.username }}":
  export SPOTFIREDB_PASSWORD=$(kubectl get secrets --namespace {{ .Release.Namespace }} {{ include "spotfire-server.spotfiredatabase.secret.name" . }} -o jsonpath="{.data.SPOTFIREDB_PASSWORD}" | base64 --decode)

- Application URL
{{ if .Values.ingress.enabled }}
{{- range $host := .Values.ingress.hosts }}
  {{- range .paths }}
  http{{ if $.Values.ingress.tls }}s{{ end }}://{{ $host.host }}
  {{- end }}
{{- end }}
{{- else if contains "NodePort" .Values.service.type }}
  export NODE_PORT=$(kubectl get --namespace {{ .Release.Namespace }} -o jsonpath="{.spec.ports[0].nodePort}" services {{ include "spotfire-server.fullname" . }})
  export NODE_IP=$(kubectl get nodes --namespace {{ .Release.Namespace }} -o jsonpath="{.items[0].status.addresses[0].address}")
  echo http://$NODE_IP:$NODE_PORT
{{- else if contains "LoadBalancer" .Values.service.type }}
     NOTE: It may take a few minutes for the LoadBalancer IP to be available.
           You can watch the status of by running 'kubectl get --namespace {{ .Release.Namespace }} svc -w {{ include "spotfire-server.fullname" . }}'
  export SERVICE_IP=$(kubectl get svc --namespace {{ .Release.Namespace }} {{ include "spotfire-server.fullname" . }} --template "{{"{{ range (index .status.loadBalancer.ingress 0) }}{{.}}{{ end }}"}}")
  echo http://$SERVICE_IP:{{ .Values.service.port }}
{{- else if contains "ClusterIP" .Values.service.type }}
  export POD_NAME=$(kubectl get pods --namespace {{ .Release.Namespace }} -l "app.kubernetes.io/name={{ include "spotfire-server.name" . }},app.kubernetes.io/instance={{ .Release.Name }}, app.kubernetes.io/component=server, app.kubernetes.io/part-of=spotfire" -o jsonpath="{.items[0].metadata.name}")
  export CONTAINER_PORT=$(kubectl get pod --namespace {{ .Release.Namespace }} $POD_NAME -o jsonpath="{.spec.containers[0].ports[0].containerPort}")
  echo "Visit http://127.0.0.1:8080 to use your application"
  kubectl --namespace {{ .Release.Namespace }} port-forward $POD_NAME 8080:$CONTAINER_PORT
{{- end }}

  # The server backend address is {{ include "spotfire-server.fullname" . }}

{{- if .Values.cliPod.enabled }}

- Configuration tool

  # To get a shell on the always on configuration pod use this command:
  kubectl --namespace {{ .Release.Namespace }} exec -it $(kubectl get pods --namespace {{ .Release.Namespace }} -l "app.kubernetes.io/component=cli, app.kubernetes.io/instance={{ .Release.Name }}, app.kubernetes.io/part-of=spotfire" -o jsonpath="{.items[0].metadata.name}" ) -- bash

  # Run './bootstrap.sh' to create a bootstrap.xml before starting to use config.sh.
{{- end }}

- Accessing and viewing logs

  # To view the logs of configuration job:
  kubectl --namespace {{ .Release.Namespace }} logs jobs.batch/{{ include "spotfire-server.configJob.fullname" . }} -c config-job

{{- if (index .Values "log-forwarder").enabled }}

  # Application logs are sent to default address {{ template "spotfire-server.log-forwarder.fullname" . }}. To view the logs on the log-forwarder run:
  export LOG_FORWARDER_NAME=$(kubectl get pods --namespace {{ .Release.Namespace }} -l "app.kubernetes.io/name=log-forwarder,app.kubernetes.io/instance={{ .Release.Name }}" -o jsonpath="{.items[0].metadata.name}")
  kubectl --namespace {{ .Release.Namespace }} logs "${LOG_FORWARDER_NAME}" -c log-forwarder
{{- else if (tpl .Values.logging.logForwarderAddress $) }}

  # Application logs are sent to non-default address {{ template "spotfire-server.log-forwarder.fullname" . }}
{{- else }}

  # Log forwarding is disabled. To view logs for spotfire server pods, run:
  export POD_NAME=$(kubectl get pods --namespace {{ .Release.Namespace }} -l "app.kubernetes.io/name={{ include "spotfire-server.name" . }}, app.kubernetes.io/instance={{ .Release.Name }}, app.kubernetes.io/component=server, app.kubernetes.io/part-of=spotfire" -o jsonpath="{.items[0].metadata.name}")
    kubectl --namespace {{ .Release.Namespace }} logs "${POD_NAME}" -c fluent-bit
{{- end }}
{{- end }}
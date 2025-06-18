# {{- define "spotfire-common.fluenbit-configuration.tsnm.podannotations.fluentbit.conf" -}}
[FILTER]
    Name    modify
    Alias   tsnm.podannotations
    Match   tsnm.*
    Add     pod.name ${POD_NAME}
    Add     pod.namespace ${POD_NAMESPACE}
    Add     container.name ${CONTAINER_NAME}
    Add     pod.id ${POD_ID}
{{- if and .Values.webplayerConfig .Values.webplayerConfig.resourcePool }}
    Add     resourcepool.name "{{ .Values.webplayerConfig.resourcePool }}"
{{- end  }}
# {{- end -}}

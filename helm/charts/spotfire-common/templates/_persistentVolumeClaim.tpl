{{- define "spotfire-common.persistentVolumeClaim.claimName" -}}
{{- if not .customClaimName }}
{{- printf "%s-%s"   .releaseName .volumeName -}}
{{- else }}
{{- .customClaimName -}}
{{- end -}}
{{- end -}}
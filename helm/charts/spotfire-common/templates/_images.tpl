{{/*
Return the proper image name
{{ include "spotfire-common.images.image" ( dict "image" .Values.path.to.the.spotfire.image "globalPath" .Values.global) }}
*/}}
{{- define "spotfire-common.images.image" -}}
{{- $tagPart := "" -}}
{{- if not (empty .image.tag) -}}
  {{- $tagPart = printf ":%s" (.image.tag | toString) -}}
{{- end -}}
{{- $digestPart := "" -}}
{{- if not (empty .image.digest) -}}
  {{- $digestPart = printf "@%s" (.image.digest | toString) -}}
{{- end -}}
{{- $registryPart := "" -}}
{{- if empty .image.registry }}
  {{- if .globalPath }}
    {{- if .globalPath.image.registry }}
      {{- $registryPart = printf "%s/" .globalPath.image.registry -}}
    {{- end -}}
  {{- end -}}
{{- else }}
  {{- $registryPart = printf "%s/" .image.registry -}}
{{- end -}}
{{- if $digestPart -}}
  {{- printf "%s%s%s" $registryPart .image.repository $digestPart -}}
{{- else -}}
  {{- printf "%s%s%s" $registryPart .image.repository $tagPart -}}
{{- end -}}
{{- end -}}


{{/*
Return the proper Container Image Registry Secret Names evaluating values as templates
{{ include "spotfire-common.images.imagePullSecrets" ( dict "image" .Values.path.to.the.image1 "globalPath" $) }}
*/}}
{{- define "spotfire-common.images.imagePullSecrets" -}}
  {{- $pullSecrets := list }}

  {{- if .image.pullSecrets -}}
    {{- range .image.pullSecrets -}}
      {{- $pullSecrets = append $pullSecrets . -}}
    {{- end -}}
  {{- end -}}

  {{- if .globalPath }}
    {{- if .globalPath }}
      {{- range .globalPath.image.pullSecrets -}}
        {{- $pullSecrets = append $pullSecrets . -}}
      {{- end -}}
    {{- end -}}
  {{- end -}}

  {{- if (not (empty $pullSecrets)) }}
imagePullSecrets:
    {{- range $pullSecrets }}
  - name: {{ . }}
    {{- end }}
  {{- end }}
{{- end -}}

{{/*
Return the proper image pullPolicy
{{ include "spotfire-common.images.imagePullPolicy" ( dict "image" .Values.path.to.the.spotfire.image "globalPath" $) }}
*/}}
{{- define "spotfire-common.images.imagePullPolicy" -}}
{{- $pullPolicy := .image.pullPolicy -}}
{{- if empty $pullPolicy }}
  {{- if .globalPath.image.pullPolicy }}
    {{- $pullPolicy = .globalPath.image.pullPolicy -}}
  {{- end -}}
{{- end -}}
{{- printf "%s" $pullPolicy -}}
{{- end -}}
{{/*
Return the proper image name
{{ include "spotfire-common.images.image" ( dict "image" .Values.path.to.the.spotfire.image "globalPath" .Values.global) }}
*/}}
{{- define "spotfire-common.images.image" -}}
{{- $repositoryName := .image.repository -}}
{{- $tagOrDigest := .image.tag | toString -}}
{{- $separator := ":" -}}
{{- if .image.digest -}}
  {{- $tagOrDigest = .image.digest | toString -}}
  {{- $separator = "@" -}}
{{- end -}}
{{- $registryName := .image.registry -}}
{{- if empty $registryName }}
  {{- if .globalPath }}
    {{- if .globalPath.image.registry }}
      {{- $registryName = .globalPath.image.registry -}}
    {{- end -}}
  {{- end -}}
{{- end -}}
{{- if $registryName }}
{{- printf "%s/%s%s%s" $registryName $repositoryName $separator $tagOrDigest -}}
{{- else -}}
{{- printf "%s%s%s" $repositoryName $separator $tagOrDigest -}}
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

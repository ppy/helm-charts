{{/*
Expand the name of the chart.
*/}}
{{- define "osu-web-chart.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "osu-web-chart.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Values.global.chartName .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "osu-web-chart.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "osu-web-chart.labels" -}}
helm.sh/chart: {{ include "osu-web-chart.chart" . }}
{{ include "osu-web-chart.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "osu-web-chart.selectorLabels" -}}
app.kubernetes.io/name: {{ include "osu-web-chart.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "osu-web-chart.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "osu-web-chart.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{- define "osu-web-chart.dotenv-var" -}}
{{- if not .value }}#{{ end }}{{- .name | upper -}}={{- .value -}}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "osu-web.mysql.fullname" -}}
{{- printf "%s-%s" .Release.Name "mysql" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Return the MySQL Hostname
*/}}
{{- define "osu-web.databaseHost" -}}
{{- if .Values.mysql.enabled }}
  {{- if eq .Values.mysql.architecture "replication" }}
    {{- printf "%s-%s" (include "osu-web.mysql.fullname" .) "primary" | trunc 63 | trimSuffix "-" -}}
  {{- else -}}
    {{- printf "%s" (include "osu-web.mysql.fullname" .) -}}
  {{- end -}}
{{- else -}}
  {{- printf "%s" (required "Missing db host" .Values.config.db.host) -}}
{{- end -}}
{{- end -}}

{{/*
Return the MySQL Database Name
*/}}
{{- define "osu-web.databaseName" -}}
{{- if .Values.mysql.enabled }}
  {{- printf "%s" .Values.mysql.auth.database -}}
{{- else -}}
  {{- printf "%s" .Values.config.db.database -}}
{{- end -}}
{{- end -}}

{{/*
Return the MySQL default user username
*/}}
{{- define "osu-web.databaseUsername" -}}
{{- if .Values.mysql.enabled }}
  {{- printf "%s" .Values.mysql.auth.username -}}
{{- else -}}
  {{- printf "%s" .Values.config.db.username -}}
{{- end -}}
{{- end -}}

{{/*
Return the MySQL default user password
*/}}
{{- define "osu-web.databasePassword" -}}
{{- if .Values.mysql.enabled }}
  {{- printf "%s" .Values.mysql.auth.password -}}
{{- else -}}
  {{- printf "%s" .Values.config.db.password -}}
{{- end -}}
{{- end -}}

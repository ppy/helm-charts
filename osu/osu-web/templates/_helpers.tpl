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

{{- define "osu-web-chart.env-var" -}}
{{- if not (kindIs "invalid" .value) -}}
{{- .name | upper | quote -}}: {{ .value | quote }}
{{- end -}}
{{- end -}}

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
{{- if .Values.config.db.host -}}
  {{- .Values.config.db.host -}}
{{- else if .Values.mysql.enabled -}}
  {{- if eq .Values.mysql.architecture "replication" -}}
    {{- printf "%s-%s" (include "osu-web.mysql.fullname" .) "primary" | trunc 63 | trimSuffix "-" -}}
  {{- else -}}
    {{- printf "%s" (include "osu-web.mysql.fullname" .) -}}
  {{- end -}}
{{- else -}}
  {{- fail "Missing db host" -}}
{{- end -}}
{{- end -}}

{{/*
Return the MySQL Database Name
*/}}
{{- define "osu-web.databaseName" -}}
{{- if .Values.config.db.database -}}
  {{- .Values.config.db.database -}}
{{- else if and (.Values.mysql.enabled) -}}
  osu
{{- else -}}
  {{- fail "Missing db database" -}}
{{- end -}}
{{- end -}}

{{/*
Return the MySQL default user username
*/}}
{{- define "osu-web.databaseUsername" -}}
{{- if .Values.config.db.username -}}
  {{- .Values.config.db.username -}}
{{- else if and (.Values.mysql.enabled) -}}
  osuweb
{{- else -}}
  {{- fail "Missing db username" -}}
{{- end -}}
{{- end -}}

{{/*
Return the MySQL default user password
*/}}
{{- define "osu-web.databasePassword" -}}
{{- if not (kindIs "invalid" .Values.config.db.password) -}}
  {{- .Values.config.db.password -}}
{{- end -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "osu-web.redis.fullname" -}}
{{- printf "%s-%s" .Release.Name "redis-master" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Return the Redis App Hostname
*/}}
{{- define "osu-web.redisAppHost" -}}
{{- if .Values.config.redis.app.host -}}
  {{- .Values.config.redis.app.host -}}
{{- else if .Values.redis.enabled -}}
  {{- printf "%s" (include "osu-web.redis.fullname" .) -}}
{{- else -}}
  {{- fail "Missing redis app host" -}}
{{- end -}}
{{- end -}}

{{/*
Return the Redis App Port
*/}}
{{- define "osu-web.redisAppPort" -}}
{{- if .Values.config.redis.app.port -}}
  {{- .Values.config.redis.app.port -}}
{{- else if .Values.redis.enabled -}}
  6379
{{- else -}}
  {{- fail "Missing redis app port" -}}
{{- end -}}
{{- end -}}

{{/*
Return the Redis App DB
*/}}
{{- define "osu-web.redisAppDb" -}}
{{- if .Values.config.redis.app.db -}}
  {{- .Values.config.redis.app.db -}}
{{- else if .Values.redis.enabled -}}
  0
{{- else -}}
  {{- fail "Missing redis app DB" -}}
{{- end -}}
{{- end -}}

{{/*
Return the Redis Cache Hostname
*/}}
{{- define "osu-web.redisCacheHost" -}}
{{- if .Values.config.redis.cache.host -}}
  {{- .Values.config.redis.cache.host -}}
{{- else if .Values.redis.enabled -}}
  {{- printf "%s" (include "osu-web.redis.fullname" .) -}}
{{- else -}}
  {{- fail "Missing redis cache host" -}}
{{- end -}}
{{- end -}}

{{/*
Return the Redis Cache Port
*/}}
{{- define "osu-web.redisCachePort" -}}
{{- if .Values.config.redis.cache.port -}}
  {{- .Values.config.redis.cache.port -}}
{{- else if .Values.redis.enabled -}}
  6379
{{- else -}}
  {{- fail "Missing redis cache port" -}}
{{- end -}}
{{- end -}}

{{/*
Return the Redis Cache DB
*/}}
{{- define "osu-web.redisCacheDb" -}}
{{- if .Values.config.redis.cache.db -}}
  {{- .Values.config.redis.cache.db -}}
{{- else if .Values.redis.enabled -}}
  0
{{- else -}}
  {{- fail "Missing redis cache DB" -}}
{{- end -}}
{{- end -}}

{{/*
Return the Redis Notification Hostname
*/}}
{{- define "osu-web.redisNotificationHost" -}}
{{- if .Values.config.redis.notification.host -}}
  {{- .Values.config.redis.notification.host -}}
{{- else if .Values.redis.enabled -}}
  {{- printf "%s" (include "osu-web.redis.fullname" .) -}}
{{- else -}}
  {{- fail "Missing redis notification host" -}}
{{- end -}}
{{- end -}}

{{/*
Return the Redis Notification Port
*/}}
{{- define "osu-web.redisNotificationPort" -}}
{{- if .Values.config.redis.notification.port -}}
  {{- .Values.config.redis.notification.port -}}
{{- else if .Values.redis.enabled -}}
  6379
{{- else -}}
  {{- fail "Missing redis notification port" -}}
{{- end -}}
{{- end -}}

{{/*
Return the Redis Notification DB
*/}}
{{- define "osu-web.redisNotificationDb" -}}
{{- if .Values.config.redis.notification.db -}}
  {{- .Values.config.redis.notification.db -}}
{{- else if .Values.redis.enabled -}}
  0
{{- else -}}
  {{- fail "Missing redis notification DB" -}}
{{- end -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "osu-web.elasticsearch.fullname" -}}
{{- printf "%s-%s" .Release.Name "elasticsearch-master" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Return the Elasticsearch Hostname
*/}}
{{- define "osu-web.elasticsearchHost" -}}
{{- if .Values.config.elasticsearch.host -}}
  {{- .Values.config.elasticsearch.host -}}
{{- else if .Values.elasticsearch.enabled -}}
  {{- printf "%s" (include "osu-web.elasticsearch.fullname" .) -}}
{{- else -}}
  {{- fail "Missing elasticsearch host" -}}
{{- end -}}
{{- end -}}

{{/*
Return the Elasticsearch Scores Hostname
*/}}
{{- define "osu-web.elasticsearchScoresHost" -}}
{{- if .Values.config.elasticsearch.scores.host -}}
  {{- .Values.config.elasticsearch.scores.host -}}
{{- else if .Values.elasticsearch.enabled -}}
  {{- printf "%s" (include "osu-web.elasticsearch.fullname" .) -}}
{{- else -}}
  {{- fail "Missing elasticsearch scores host" -}}
{{- end -}}
{{- end -}}

{{/*
Return the notification server public url
*/}}
{{- define "osu-web.notificationServerPublicUrl" -}}
{{- $osuNotificationServer := (index .Values "osu-notification-server") -}}
{{- if .Values.config.notificationServer.publicUrl -}}
  {{- .Values.config.notificationServer.publicUrl -}}
{{- else if and
  $osuNotificationServer.enabled
  $osuNotificationServer.ingress.enabled
  $osuNotificationServer.ingress.hosts
-}}
  {{- $mainHost := index $osuNotificationServer.ingress.hosts 0 -}}
  ws{{- if $osuNotificationServer.ingress.tls -}}s{{- end -}}://{{- $mainHost.host -}}{{- (index $mainHost.paths 0).path -}}
{{- else -}}
  {{- fail "Missing notification server public url" -}}
{{- end -}}
{{- end -}}

{{/*
Return the Laravel app URL
*/}}
{{- define "osu-web.laravelAppUrl" -}}
{{- if .Values.config.laravel.url -}}
  {{- .Values.config.laravel.url -}}
{{- else if and
  .Values.ingress.enabled
  .Values.ingress.hosts
-}}
  {{- $mainHost := index .Values.ingress.hosts 0 -}}
  http{{- if .Values.ingress.tls -}}s{{- end -}}://{{- $mainHost.host -}}{{- (index $mainHost.paths 0).path -}}
{{- else -}}
  {{- fail "Missing laravel app url" -}}
{{- end -}}
{{- end -}}

{{/*
Return the Laravel session domain
*/}}
{{- define "osu-web.laravelSessionDomain" -}}
{{- if .Values.config.laravel.session.domain -}}
  {{- .Values.config.laravel.session.domain -}}
{{- else -}}
  {{- (urlParse (include "osu-web.laravelAppUrl" .)).host -}}
{{- end -}}
{{- end -}}

{{/*
Return the Laravel session secure cookies boolean
*/}}
{{- define "osu-web.laravelSessionSecureCookie" -}}
{{- if .Values.config.laravel.session.secureCookie -}}
  {{- .Values.config.laravel.session.secureCookie -}}
{{- else -}}
  {{- eq "https" (urlParse (include "osu-web.laravelAppUrl" .)).scheme -}}
{{- end -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "osu-web.osu-beatmap-difficulty-lookup-cache.fullname" -}}
{{- printf "%s-%s" .Release.Name "osu-beatmap-difficulty-lookup-cache" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Return the beatmaps difficulty lookup cache server url
*/}}
{{- define "osu-web.beatmapsDifficultyLookupCacheServerUrl" -}}
{{- $osuBeatmapsDifficultyLookupCache := (index .Values "osu-beatmap-difficulty-lookup-cache") -}}
{{- if .Values.config.beatmapsDifficultyLookupCache.serverUrl -}}
  {{- .Values.config.beatmapsDifficultyLookupCache.serverUrl -}}
{{- else if $osuBeatmapsDifficultyLookupCache.enabled -}}
  http://{{- include "osu-web.osu-beatmap-difficulty-lookup-cache.fullname" . -}}
{{- end -}}
{{- end -}}

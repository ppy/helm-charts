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
Common labels
*/}}
{{- define "osu-web-chart.labelsAssets" -}}
helm.sh/chart: {{ include "osu-web-chart.chart" . }}
{{ include "osu-web-chart.selectorLabelsAssets" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "osu-web-chart.selectorLabelsAssets" -}}
app.kubernetes.io/name: {{ include "osu-web-chart.name" . }}-assets
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

{{- define "osu-web-chart.env-vars" -}}
{{ template "osu-web-chart.env-var" (dict "name" "APP_URL" "value" (include "osu-web.laravelAppUrl" .)) }}
{{ template "osu-web-chart.env-var" (dict "name" "APP_ENV" "value" .Values.config.laravel.env) }}
{{ template "osu-web-chart.env-var" (dict "name" "APP_DEBUG" "value" .Values.config.laravel.debug) }}
{{ template "osu-web-chart.env-var" (dict "name" "APP_KEY" "value" .Values.config.laravel.appKey) }}
{{ template "osu-web-chart.env-var" (dict "name" "APP_SENTRY" "value" .Values.config.laravel.sentry.url) }}
{{ template "osu-web-chart.env-var" (dict "name" "APP_SENTRY_PUBLIC" "value" .Values.config.laravel.sentry.publicUrl) }}
{{ template "osu-web-chart.env-var" (dict "name" "APP_SENTRY_ENVIRONMENT" "value" .Values.config.laravel.sentry.environment) }}
{{ template "osu-web-chart.env-var" (dict "name" "SENTRY_TRACES_SAMPLE_RATE" "value" .Values.config.laravel.sentry.tracesSampleRate) }}

{{ template "osu-web-chart.env-var" (dict "name" "DB_HOST" "value" (include "osu-web.databaseHost" .)) }}
{{ template "osu-web-chart.env-var" (dict "name" "DB_DATABASE" "value" .Values.config.db.database) }}
{{ template "osu-web-chart.env-var" (dict "name" "DB_USERNAME" "value" .Values.config.db.username) }}
{{ template "osu-web-chart.env-var" (dict "name" "DB_PASSWORD" "value" .Values.config.db.password) }}

{{ template "osu-web-chart.env-var" (dict "name" "REDIS_HOST" "value" (include "osu-web.redisAppHost" .)) }}
{{ template "osu-web-chart.env-var" (dict "name" "REDIS_PORT" "value" .Values.config.redis.app.port) }}
{{ template "osu-web-chart.env-var" (dict "name" "REDIS_DB" "value" .Values.config.redis.app.db) }}

{{ template "osu-web-chart.env-var" (dict "name" "CACHE_REDIS_HOST" "value" (include "osu-web.redisCacheHost" .)) }}
{{ template "osu-web-chart.env-var" (dict "name" "CACHE_REDIS_PORT" "value" .Values.config.redis.cache.port) }}
{{ template "osu-web-chart.env-var" (dict "name" "CACHE_REDIS_DB" "value" .Values.config.redis.cache.db) }}

{{ template "osu-web-chart.env-var" (dict "name" "MEMCACHED_PERSISTENT_ID" "value" .Values.config.memcache.persistentId) }}
{{ template "osu-web-chart.env-var" (dict "name" "MEMCACHED_USERNAME" "value" .Values.config.memcache.username) }}
{{ template "osu-web-chart.env-var" (dict "name" "MEMCACHED_PASSWORD" "value" .Values.config.memcache.password) }}
{{ template "osu-web-chart.env-var" (dict "name" "MEMCACHED_HOST" "value" .Values.config.memcache.host) }}
{{ template "osu-web-chart.env-var" (dict "name" "MEMCACHED_PORT" "value" .Values.config.memcache.port) }}

{{ template "osu-web-chart.env-var" (dict "name" "BROADCAST_DRIVER" "value" .Values.config.laravel.log.driver) }}
{{ template "osu-web-chart.env-var" (dict "name" "CACHE_DRIVER" "value" .Values.config.laravel.cache.driver) }}
{{ template "osu-web-chart.env-var" (dict "name" "CACHE_DRIVER_LOCAL" "value" .Values.config.laravel.cache.localDriver) }}
{{ template "osu-web-chart.env-var" (dict "name" "SESSION_DRIVER" "value" .Values.config.laravel.session.driver) }}
{{ template "osu-web-chart.env-var" (dict "name" "SESSION_DOMAIN" "value" (include "osu-web.laravelSessionDomain" .)) }}
{{ template "osu-web-chart.env-var" (dict "name" "SESSION_SECURE_COOKIE" "value" (include "osu-web.laravelSessionSecureCookie" .)) }}

{{ template "osu-web-chart.env-var" (dict "name" "MAIL_DRIVER" "value" .Values.config.mail.driver) }}
{{ template "osu-web-chart.env-var" (dict "name" "MAIL_HOST" "value" .Values.config.mail.host) }}
{{ template "osu-web-chart.env-var" (dict "name" "MAIL_PORT" "value" .Values.config.mail.port) }}
{{ template "osu-web-chart.env-var" (dict "name" "MAIL_ENCRYPTION" "value" .Values.config.mail.encryption) }}
{{ template "osu-web-chart.env-var" (dict "name" "MAIL_USERNAME" "value" .Values.config.mail.username) }}
{{ template "osu-web-chart.env-var" (dict "name" "MAIL_PASSWORD" "value" .Values.config.mail.password) }}

{{ template "osu-web-chart.env-var" (dict "name" "SHARED_INTEROP_SECRET" "value" .Values.config.laravel.legacy.sharedInteropSecret) }}

{{ template "osu-web-chart.env-var" (dict "name" "FILESYSTEM_DISK" "value" .Values.config.storage.general.driver) }}

{{ template "osu-web-chart.env-var" (dict "name" "BM_PROCESSOR_MIRRORS" "value" .Values.config.beatmapsProcessor.mirrors) }}
{{ template "osu-web-chart.env-var" (dict "name" "BM_PROCESSOR_THUMBNAILER" "value" .Values.config.beatmapsProcessor.thumbnailer) }}
{{ template "osu-web-chart.env-var" (dict "name" "BM_PROCESSOR_SENTRY" "value" .Values.config.beatmapsProcessor.sentry) }}

{{ template "osu-web-chart.env-var" (dict "name" "S3_KEY" "value" .Values.config.storage.general.s3.key) }}
{{ template "osu-web-chart.env-var" (dict "name" "S3_SECRET" "value" .Values.config.storage.general.s3.secret) }}
{{ template "osu-web-chart.env-var" (dict "name" "S3_REGION" "value" .Values.config.storage.general.s3.region) }}
{{ template "osu-web-chart.env-var" (dict "name" "S3_BUCKET" "value" .Values.config.storage.general.s3.bucket) }}
{{ template "osu-web-chart.env-var" (dict "name" "S3_BASE_URL" "value" .Values.config.storage.general.s3.baseUrl) }}
{{ template "osu-web-chart.env-var" (dict "name" "S3_MINI_URL" "value" .Values.config.storage.general.s3.miniUrl) }}

{{ template "osu-web-chart.env-var" (dict "name" "S3_AVATAR_KEY" "value" .Values.config.storage.avatar.s3.key) }}
{{ template "osu-web-chart.env-var" (dict "name" "S3_AVATAR_SECRET" "value" .Values.config.storage.avatar.s3.secret) }}
{{ template "osu-web-chart.env-var" (dict "name" "S3_AVATAR_REGION" "value" .Values.config.storage.avatar.s3.region) }}
{{ template "osu-web-chart.env-var" (dict "name" "S3_AVATAR_BUCKET" "value" .Values.config.storage.avatar.s3.bucket) }}
{{ template "osu-web-chart.env-var" (dict "name" "S3_AVATAR_BASE_URL" "value" .Values.config.storage.avatar.s3.baseUrl) }}
{{ template "osu-web-chart.env-var" (dict "name" "AVATAR_STORAGE" "value" .Values.config.storage.avatar.driver) }}
{{ template "osu-web-chart.env-var" (dict "name" "AVATAR_CACHE_PURGE_PREFIX" "value" .Values.config.storage.avatar.s3.cachePurgePrefix) }}
{{ template "osu-web-chart.env-var" (dict "name" "AVATAR_CACHE_PURGE_METHOD" "value" .Values.config.storage.avatar.s3.cachePurgeMethod) }}
{{ template "osu-web-chart.env-var" (dict "name" "AVATAR_CACHE_PURGE_AUTHORIZATION_KEY" "value" .Values.config.storage.avatar.s3.cachePurgeAuthorizationKey) }}

# Either "s3" or "local".
{{ template "osu-web-chart.env-var" (dict "name" "SCORE_REPLAYS_STORAGE" "value" .Values.config.storage.replay.driver) }}

{{ template "osu-web-chart.env-var" (dict "name" "QUEUE_DRIVER" "value" .Values.config.laravel.queue.driver) }}
{{ template "osu-web-chart.env-var" (dict "name" "CAMO_KEY" "value" .Values.config.laravel.camo.key) }}
{{ template "osu-web-chart.env-var" (dict "name" "CAMO_PREFIX" "value" .Values.config.laravel.camo.prefix) }}

{{ template "osu-web-chart.env-var" (dict "name" "GITHUB_TOKEN" "value" .Values.config.laravel.githubToken) }}

{{ template "osu-web-chart.env-var" (dict "name" "DATADOG_ENABLED" "value" .Values.config.laravel.datadog.enabled) }}
{{ template "osu-web-chart.env-var" (dict "name" "DATADOG_PREFIX" "value" .Values.config.laravel.datadog.prefix) }}
{{ template "osu-web-chart.env-var" (dict "name" "DATADOG_API_KEY" "value" .Values.config.laravel.datadog.apiKey) }}
{{ template "osu-web-chart.env-var" (dict "name" "DATADOG_APP_KEY" "value" .Values.config.laravel.datadog.appKey) }}
{{ template "osu-web-chart.env-var" (dict "name" "DATADOG_HOST" "value" .Values.config.laravel.datadog.host) }}
{{ template "osu-web-chart.env-var" (dict "name" "DATADOG_STATSD_HOST" "value" .Values.config.laravel.datadog.statsd.host) }}
{{ template "osu-web-chart.env-var" (dict "name" "DATADOG_STATSD_PORT" "value" .Values.config.laravel.datadog.statsd.port) }}
{{ template "osu-web-chart.env-var" (dict "name" "DATADOG_STATSD_SOCKET" "value" .Values.config.laravel.datadog.statsd.socket) }}

{{ template "osu-web-chart.env-var" (dict "name" "CHANGELOG_GITHUB_TOKEN" "value" .Values.config.laravel.changelogGithubToken) }}

{{ template "osu-web-chart.env-var" (dict "name" "PAYMENT_SANDBOX" "value" .Values.config.laravel.payments.sandbox) }}

{{ template "osu-web-chart.env-var" (dict "name" "SHOPIFY_DOMAIN" "value" .Values.config.laravel.payments.shopify.domain) }}
{{ template "osu-web-chart.env-var" (dict "name" "SHOPIFY_STOREFRONT_TOKEN" "value" .Values.config.laravel.payments.shopify.storeFrontToken) }}
{{ template "osu-web-chart.env-var" (dict "name" "SHOPIFY_WEBHOOK_KEY" "value" .Values.config.laravel.payments.shopify.webhookKey) }}

{{ template "osu-web-chart.env-var" (dict "name" "STORE_NOTIFICATION_CHANNEL" "value" .Values.config.laravel.notifications.store.channel) }}
{{ template "osu-web-chart.env-var" (dict "name" "STORE_NOTIFICATIONS_QUEUE" "value" .Values.config.laravel.notifications.store.queue) }}
{{ template "osu-web-chart.env-var" (dict "name" "STORE_STALE_DAYS" "value" .Values.config.laravel.payments.storeStaleDays) }}

{{ template "osu-web-chart.env-var" (dict "name" "PAYPAL_URL" "value" .Values.config.laravel.payments.paypal.url) }}
{{ template "osu-web-chart.env-var" (dict "name" "PAYPAL_MERCHANT_ID" "value" .Values.config.laravel.payments.paypal.merchantId) }}
{{ template "osu-web-chart.env-var" (dict "name" "PAYPAL_CLIENT_ID" "value" .Values.config.laravel.payments.paypal.clientId) }}
{{ template "osu-web-chart.env-var" (dict "name" "PAYPAL_CLIENT_SECRET" "value" .Values.config.laravel.payments.paypal.clientSecret) }}
{{ template "osu-web-chart.env-var" (dict "name" "PAYPAL_NO_SHIPPING_EXPERIENCE_PROFILE_ID" "value" .Values.config.laravel.payments.paypal.noShippingExperienceProfileId) }}

{{ template "osu-web-chart.env-var" (dict "name" "XSOLLA_API_KEY" "value" .Values.config.laravel.payments.xsolla.apiKey) }}
{{ template "osu-web-chart.env-var" (dict "name" "XSOLLA_MERCHANT_ID" "value" .Values.config.laravel.payments.xsolla.merchantId) }}
{{ template "osu-web-chart.env-var" (dict "name" "XSOLLA_PROJECT_ID" "value" .Values.config.laravel.payments.xsolla.projectId) }}
{{ template "osu-web-chart.env-var" (dict "name" "XSOLLA_SECRET_KEY" "value" .Values.config.laravel.payments.xsolla.secretKey) }}

{{ template "osu-web-chart.env-var" (dict "name" "CENTILI_API_KEY" "value" .Values.config.laravel.payments.centili.apiKey) }}
{{ template "osu-web-chart.env-var" (dict "name" "CENTILI_SECRET_KEY" "value" .Values.config.laravel.payments.centili.secretKey) }}
{{ template "osu-web-chart.env-var" (dict "name" "CENTILI_CONVERSION_RATE" "value" .Values.config.laravel.payments.centili.conversionRate) }}
{{ template "osu-web-chart.env-var" (dict "name" "CENTILI_WIDGET_URL" "value" .Values.config.laravel.payments.centili.widgetUrl) }}

{{ template "osu-web-chart.env-var" (dict "name" "ES_HOST" "value" (include "osu-web.elasticsearchHost" .)) }}
{{ template "osu-web-chart.env-var" (dict "name" "ES_SCORES_HOST" "value" (include "osu-web.elasticsearchScoresHost" .)) }}
{{ template "osu-web-chart.env-var" (dict "name" "ES_SOLO_SCORES_HOST" "value" (include "osu-web.elasticsearchSoloScoresHost" .)) }}
{{ template "osu-web-chart.env-var" (dict "name" "ES_INDEX_PREFIX" "value" .Values.config.elasticsearch.indexPrefix) }}
{{ template "osu-web-chart.env-var" (dict "name" "ES_CLIENT_TIMEOUT" "value" .Values.config.elasticsearch.clientTimeout) }}
{{ template "osu-web-chart.env-var" (dict "name" "ES_CLIENT_CONNECT_TIMEOUT" "value" .Values.config.elasticsearch.clientConnectTimeout) }}
{{ template "osu-web-chart.env-var" (dict "name" "ES_SEARCH_TIMEOUT" "value" .Values.config.elasticsearch.searchTimeout) }}

{{ template "osu-web-chart.env-var" (dict "name" "NOTIFICATION_QUEUE" "value" .Values.config.laravel.notifications.queue) }}
{{ template "osu-web-chart.env-var" (dict "name" "NOTIFICATION_REDIS_HOST" "value" (include "osu-web.redisNotificationHost" .)) }}
{{ template "osu-web-chart.env-var" (dict "name" "NOTIFICATION_REDIS_PORT" "value" .Values.config.redis.notification.port) }}
{{ template "osu-web-chart.env-var" (dict "name" "NOTIFICATION_REDIS_DB" "value" .Values.config.redis.notification.db) }}
{{ template "osu-web-chart.env-var" (dict "name" "NOTIFICATION_ENDPOINT" "value" (include "osu-web.notificationServerPublicUrl" .)) }}

{{ template "osu-web-chart.env-var" (dict "name" "LOG_CHANNEL" "value" .Values.config.laravel.logChannel) }}

{{ template "osu-web-chart.env-var" (dict "name" "RECAPTCHA_SECRET" "value" .Values.config.laravel.recaptcha.secret) }}
{{ template "osu-web-chart.env-var" (dict "name" "RECAPTCHA_SITEKEY" "value" .Values.config.laravel.recaptcha.siteKey) }}
{{ template "osu-web-chart.env-var" (dict "name" "RECAPTCHA_THRESHOLD" "value" .Values.config.laravel.recaptcha.threshold) }}

{{ template "osu-web-chart.env-var" (dict "name" "TWITCH_CLIENT_ID" "value" .Values.config.laravel.twitch.clientId) }}
{{ template "osu-web-chart.env-var" (dict "name" "TWITCH_CLIENT_SECRET" "value" .Values.config.laravel.twitch.clientSecret) }}

{{ template "osu-web-chart.env-var" (dict "name" "SCORES_ES_CACHE_DURATION" "value" .Values.config.laravel.scores.cacheDuration) }}
{{ template "osu-web-chart.env-var" (dict "name" "SCORES_RANK_CACHE_LOCAL_SERVER" "value" .Values.config.laravel.scoresRankCache.localServer) }}
{{ template "osu-web-chart.env-var" (dict "name" "SCORES_RANK_CACHE_MIN_USERS" "value" .Values.config.laravel.scoresRankCache.minUsers) }}
{{ template "osu-web-chart.env-var" (dict "name" "SCORES_RANK_CACHE_SERVER_URL" "value" .Values.config.laravel.scoresRankCache.serverUrl) }}
{{ template "osu-web-chart.env-var" (dict "name" "SCORES_RANK_CACHE_TIMEOUT" "value" .Values.config.laravel.scoresRankCache.timeout) }}

{{ template "osu-web-chart.env-var" (dict "name" "BANCHO_BOT_USER_ID" "value" .Values.config.laravel.legacy.banchoBotUserId) }}

{{ template "osu-web-chart.env-var" (dict "name" "BEATMAPS_DIFFICULTY_CACHE_SERVER_URL" "value" (include "osu-web.beatmapsDifficultyLookupCacheServerUrl" .)) }}

{{ template "osu-web-chart.env-var" (dict "name" "TRUSTED_PROXIES" "value" .Values.config.laravel.trustedProxies) }}

{{ template "osu-web-chart.env-var" (dict "name" "IS_DEVELOPMENT_DEPLOY" "value" .Values.config.laravel.devDeploy) }}

{{ template "osu-web-chart.env-var" (dict "name" "CLIENT_CHECK_VERSION" "value" .Values.config.clientCheckVersion) }}

# Extra env
{{- range $name, $value := .Values.config.laravel.extraEnv }}
{{ template "osu-web-chart.env-var" (dict "name" $name "value" $value) }}
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
{{- if not (eq nil .Values.config.db.host) -}}
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
Return the Elasticsearch Solo Scores Hostname
*/}}
{{- define "osu-web.elasticsearchSoloScoresHost" -}}
{{- if .Values.config.elasticsearch.soloScores.host -}}
  {{- .Values.config.elasticsearch.soloScores.host -}}
{{- else if .Values.elasticsearch.enabled -}}
  {{- printf "%s" (include "osu-web.elasticsearch.fullname" .) -}}
{{- else -}}
  {{- fail "Missing elasticsearch solo scores host" -}}
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

{{/*
Ingress host helper.
If the input host is REPLACE_BY_APP_URL, will urlparse defaultHost and return its host. Otherwise, return the input host (unparsed).
*/}}
{{- define "osu-web.ingress-host" -}}
{{- if eq .host "REPLACE_BY_APP_URL" -}}
{{- (urlParse .defaultHost).host -}}
{{- else -}}
{{- .host -}}
{{- end -}}
{{- end -}}

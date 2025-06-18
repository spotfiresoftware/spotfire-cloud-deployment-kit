{{- define "spotfire-server.haproxy.config" -}}
global
    log stdout format raw local0
    daemon
    maxconn 1024
    {{- if .Values.spotfireConfig.maintenancePage.useFile }}
    tune.bufsize {{ .Values.spotfireConfig.maintenancePage.bufSize }}
    {{- end }}

    {{- if .Values.spotfireConfig.haproxy.global }}
    {{ .Values.spotfireConfig.haproxy.global }}
    {{- end }}

defaults
    log global
    mode http
    option http-server-close
    http-reuse safe
    option forwardfor except 127.0.0.0/8
    option dontlognull
    option http-keep-alive
    option httplog
    option prefer-last-server
    option redispatch
    retries 1
    timeout client {{ .Values.spotfireConfig.timeouts.client }}
    timeout queue {{ .Values.spotfireConfig.timeouts.queue }}
    timeout connect {{ .Values.spotfireConfig.timeouts.connect }}
    timeout server {{ .Values.spotfireConfig.timeouts.server }}
    timeout tunnel {{ .Values.spotfireConfig.timeouts.tunnel }}
    timeout http-request {{ .Values.spotfireConfig.timeouts.httpRequest }}

    {{- if .Values.spotfireConfig.haproxy.defaults }}
    {{ .Values.spotfireConfig.haproxy.defaults }}
    {{- end }}

frontend stats
    bind :1024
    {{- if not .Values.spotfireConfig.debug }}
    option dontlog-normal
    {{- end }}

    # external health check (/health) and readiness (/up)
    acl acl_backend_down nbsrv(spotfire) lt 1
    http-request return status 503 content-type "text/plain" string "Service unavailable" if { path /health && acl_backend_down }
    http-request return status 200 content-type "text/plain" string "OK" if { path /health }

    http-request return status 200 content-type "text/plain" string "OK" if { path /up }

    # Prometheus metrics
    http-request use-service prometheus-exporter if { path {{ index .Values "podAnnotations" "prometheus.io/path" }} }

    # Stats
    stats enable
    stats uri /stats
    stats refresh 10s

    {{- if .Values.spotfireConfig.haproxy.stats }}
    {{ .Values.spotfireConfig.haproxy.stats }}
    {{- end }}


frontend spotfire
    bind :80

    {{- if .Values.spotfireConfig.haproxy.frontend }}
    {{ .Values.spotfireConfig.haproxy.frontend }}
    {{- end }}

    option httplog

    acl acl_backend_down nbsrv(spotfire) lt 1

    {{- if .Values.spotfireConfig.compression.enabled }}

    # Compression
    compression algo {{ .Values.spotfireConfig.compression.algo }}
    compression type {{ .Values.spotfireConfig.compression.type }}
    {{- end }}

    # Deny all non-spotfire requests
    http-request deny status 403 content-type text/html string "403 Forbidden" unless { path -m beg /spotfire/ } || { path / } || { path /spotfire }

    # Deny external access to Spotfire Server health check url
    http-request deny deny_status 404 if { path /spotfire/rest/status/getStatus }

    {{- if .Values.spotfireConfig.debug }}


    # For debug purposes (shows the number of running spotfire servers)
    http-response set-header X-Server-Status "%[nbsrv(spotfire)]"

    # For logging purposes (these are by default displayed in the haproxy logs)
    capture request header X-Forwarded-Proto len 5
    capture request header X-Forwarded-Port len 4
    capture request header X-Forwarded-For len {{ .Values.spotfireConfig.captures.forwardedForLength }}
    {{- end }}

    {{- if .Values.spotfireConfig.maintenance.enabled }}

    # Maintenance in progress

    ## Should certain requests be allowed during maintenance
    {{- if .Values.spotfireConfig.maintenance.allowCookie.enabled }}
    acl maintenance_allow req.cook({{ required "The name of the allow cookie is required" .Values.spotfireConfig.maintenance.allowCookie.name }}) -m str {{ required "The value of the allow cookie is required" .Values.spotfireConfig.maintenance.allowCookie.value }}
    {{ else }}
    acl maintenance_allow always_false
    {{- end }}

    ## What should be return during maintenance
    {{- if and .Values.spotfireConfig.maintenancePage.useFile .Values.includes (index .Values "includes" "maintenance.html") }}
    http-request return status 503 content-type text/html  file /etc/haproxy/includes/maintenance.html unless maintenance_allow
    {{ else }}
    http-request return status 503 content-type text/html string {{ .Values.spotfireConfig.maintenancePage.responseString | quote }} unless maintenance_allow
    {{ end }}

    {{- end }}

    {{- if and .Values.spotfireConfig.maintenancePage.useFile .Values.includes (index .Values "includes" "maintenance.html") }}

    # Maintenance page (when there are no spotfire servers running)
    http-request return status 503 content-type text/html  file /etc/haproxy/includes/maintenance.html if acl_backend_down
    {{ else }}
    http-request return status 503 content-type text/html string {{ .Values.spotfireConfig.maintenancePage.responseString | quote }} if acl_backend_down
    {{- end }}


    {{- if or .Values.spotfireConfig.cleanup.secureCookieAttributeForHttp .Values.spotfireConfig.cleanup.sameSiteCookieAttributeForHttp }}

    # Clean up cookies attributes that work less well in different combinations, relies on correct
    # value of the ingress to set X-Forwarded-Proto correctly.
    http-request set-var(txn.x_forwarded_proto) req.hdr(X-Forwarded-Proto),lower

    {{- if .Values.spotfireConfig.cleanup.secureCookieAttributeForHttp }}
    http-after-response replace-header Set-Cookie "(.*)(; Secure)(.*)" "\1\3" if !{ var(txn.x_forwarded_proto) -m str "https" }
    {{- end }}

    {{- if .Values.spotfireConfig.cleanup.sameSiteCookieAttributeForHttp }}
    http-after-response replace-header Set-Cookie "(.*)(; SameSite=\S+)(.*)" "\1\3" if !{ var(txn.x_forwarded_proto) -m str "https" }
    {{- end }}

    {{- end }}

    default_backend spotfire

    {{- if .Values.spotfireConfig.cache.enabled }}

    # Cache
    http-request cache-use tss
    http-response cache-store tss
    http-after-response del-header Set-Cookie if { res.cache_hit }


    {{- if .Values.spotfireConfig.debug }}

    ## For debug purposes
    http-response set-header X-Cache-Status HIT if { res.cache_hit }
    http-response set-header X-Cache-Status MISS if !{ res.cache_hit }
    {{- end }}

    {{- end }}

{{- if .Values.spotfireConfig.cache.enabled }}

cache tss
    # In megabytes
    total-max-size {{ .Values.spotfireConfig.cache.totalMaxSizeMegabytes }}

    # In seconds
    max-age {{ .Values.spotfireConfig.cache.maxAgeSeconds }}

    # In bytes
    max-object-size {{ .Values.spotfireConfig.cache.maxObjectSizeBytes }}

    process-vary on
{{- end }}

backend spotfire
    dynamic-cookie-key {{ .Values.spotfireConfig.loadBalancingCookie.dynamicCookieKey }}
    cookie {{ .Values.spotfireConfig.loadBalancingCookie.name }} {{ .Values.spotfireConfig.loadBalancingCookie.attributes }}
    option httpchk GET /spotfire/rest/status/getStatus HTTP/1.0

    {{- if .Values.spotfireConfig.debug }}

    # For debug purposes
    http-response set-header X-Server "%s"
    {{- end }}

    server-template spotfire-server 10 _http._tcp.{{ include "haproxy.spotfire-server.fullname" . }}.{{ .Release.Namespace }}.svc.cluster.local resolvers pcdns resolve-opts ignore-weight check weight 100 agent-check agent-port {{ .Values.spotfireConfig.agent.port }} {{ .Values.spotfireConfig.serverTemplate.additionalParams }}
resolvers pcdns
    parse-resolv-conf
    resolve_retries       3
    timeout resolve       1s
    timeout retry         1s
    hold other           30s
    hold refused         30s
    hold nx              30s
    hold timeout         30s
    hold valid           10s
    hold obsolete        30s
{{- end -}}
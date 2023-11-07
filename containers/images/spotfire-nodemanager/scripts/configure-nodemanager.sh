#!/bin/bash

# Container configuration of nodemanager
cat >> /opt/spotfire/nodemanager/nm/config/nodemanager.properties << EOF

http.non-streaming.read-timeout=${NODEMANAGER_HTTP_NONSTREAMING_READTIMEOUT:-2000}
monitoring.http-probes.enabled=true
nodemanager.certificate-monitor.retry-delay-seconds=1
nodemanager.externally-managed=true
nodemanager.service.disable-restart-on-stop=true
performance-monitoring.metrics-exporter.enabled=true

EOF
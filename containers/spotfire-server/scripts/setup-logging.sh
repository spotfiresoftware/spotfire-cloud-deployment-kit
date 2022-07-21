#!/bin/bash

if [ "${LOGGING_HTTPREQUESTS_ENABLED}" != "N" ]; then
    config.sh apply-xdt-transformation --input-file=/opt/tibco/tss/tomcat/conf/Spotfire/localhost/spotfire.xml --transformation-file=config/extended.accesslog.xml
fi

# Set logging level
for loglevel in minimal debug trace;
do
    if [ "${LOGGING_LOGLEVEL,,}" != "${loglevel}" ]; then
        continue
    fi
    activeconfig="logging-${loglevel}.properties"
    echo "Using log configuration file ${activeconfig}"
    echo "ActiveConfig=${activeconfig}" > /opt/tibco/tss/tomcat/spotfire-config/logging-levels.properties
done

cat > /opt/tibco/tss/tomcat/spotfire-config/log4j2-custom.xml << EOF
<?xml version="1.0" encoding="UTF-8"?>
<Configuration>
  <Properties>
    <Property name="log.dir">logs</Property>
    <Property name="serverLogSizePolicy">${LOGGING_SERVERLOG_SIZEPOLICY:-10MB}</Property>
    <Property name="serverLogDefaultRollover">${LOGGING_SERVERLOG_DEFAULTROLLOVER:-2}</Property>
    <Property name="nonServerLogsSizePolicy">${LOGGING_NONSERVERLOG_SIZEPOLICY:-10MB}</Property>
    <Property name="nonServerLogsDefaultRollover">${LOGGING_NONSERVERLOG_DEFAULTROLLOVER:-2}</Property>
    <Property name="tomcatLogsSizePolicy">${LOGGING_TOMCATLOGS_SIZEPOLICY:-10MB}</Property>
    <Property name="tomcatLogsDefaultRollover">${LOGGING_TOMCATLOGS_DEFAULTROLLOVER:-1d}</Property>
    <Property name="logReconfigurationInterval">30</Property>
  </Properties>

</Configuration>

EOF

# Script to enable special logging config if LOGGING_JSON_HOST is set, before
# starting tomcat
if [ -z "${LOGGING_JSON_HOST}" ]; then
    exit 0
fi

# Add the socket appender to log4j2.xml
echo "Enabling logging to ${LOGGING_JSON_HOST}:${LOGGING_JSON_PORT:-5170}"
config.sh apply-xdt-transformation --input-file=/opt/tibco/tss/tomcat/spotfire-config/log4j2.xml --transformation-file=config/log4j2.xml.socket-appender.transformation.xml
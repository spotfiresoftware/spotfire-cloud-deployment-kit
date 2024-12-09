#!/bin/bash

if [ "${LOGGING_HTTPREQUESTS_ENABLED}" != "N" ]; then
    config.sh apply-xdt-transformation --input-file=/opt/spotfire/spotfireserver/tomcat/conf/Spotfire/localhost/spotfire.xml --transformation-file=config/extended.accesslog.xml
fi

# Set logging level
for loglevel in minimal debug trace;
do
    if [ "${LOGGING_LOGLEVEL,,}" != "${loglevel}" ]; then
        continue
    fi
    activeconfig="logging-${loglevel}.properties"
    echo "Using log configuration file ${activeconfig}"
    echo "ActiveConfig=${activeconfig}" > /opt/spotfire/spotfireserver/tomcat/spotfire-config/logging-levels.properties
done

cat > /opt/spotfire/spotfireserver/tomcat/spotfire-config/log4j2-custom.xml << EOF
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

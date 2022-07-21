#!/bin/bash

# Set logging level
for loglevel in minimal debug trace;
do
    if [ "${LOGGING_LOGLEVEL,,}" != "${loglevel}" ]; then
        continue
    fi
    activeconfig="logging-${loglevel}.properties"
    echo "Using log configuration file ${activeconfig}"
    echo "ActiveConfig=${activeconfig}" > /opt/tibco/tsnm/nm/config/log-config/logging-levels.properties
done


cat > /opt/tibco/tsnm/nm/config/log-config/log4j2-properties.xml << EOF
<?xml version="1.0" encoding="UTF-8"?>
<Configuration>
   <Properties>
     <Property name="log.dir">logs</Property>
     <Property name="nm.log.size">${LOGGING_NMLOG_SIZE:-10MB}</Property>
     <Property name="nm.log.max">${LOGGING_NMLOG_MAX:-2}</Property>
     <Property name="nm.performance.log.size">${LOGGING_NMPERFORMANCELOG_SIZE:-10MB}</Property>
     <Property name="nm.performance.log.max">${LOGGING_NMPERFORMANCELOG_MAX:-2}</Property>
     <Property name="logReconfigurationIntervalSeconds">30</Property>
   </Properties>

</Configuration>

EOF
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

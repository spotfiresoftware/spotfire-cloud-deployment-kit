#!/usr/bin/env bash

# set -o nounset

# Initiate the shutdown
touch /opt/tibco/tss/tomcat/logs/tss-terminated
/opt/tibco/tss/tomcat/spotfire-bin/graceful-shutdown.sh $1 $2

# Make sure to fill the fluent-bit buffers for prestop hook
for i in {1..20}
do
    echo "DONE" >> /opt/tibco/tss/tomcat/logs/tss-terminated
done
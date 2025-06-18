#!/usr/bin/env bash

# set -o nounset

# Initiate the shutdown
touch /opt/spotfire/spotfireserver/tomcat/logs/spotfireserver-terminated
/opt/spotfire/spotfireserver/tomcat/spotfire-bin/graceful-shutdown.sh $1 $2

# Run any custom specific post stop script
if [ -f "/opt/spotfire/scripts/post-stop.custom.sh" ]; then
    echo "Executing custom post stop script..."
    /opt/spotfire/scripts/post-stop.custom.sh
fi

# Make sure to fill the fluent-bit buffers for prestop hook
for i in {1..20}
do
    echo "DONE" >> /opt/spotfire/spotfireserver/tomcat/logs/spotfireserver-terminated
done
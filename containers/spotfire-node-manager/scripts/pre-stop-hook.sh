#!/usr/bin/env bash

# set -o nounset

# Initiate the shutdown
touch /opt/tibco/tsnm/nm/logs/tsnm-terminated
/opt/tibco/tsnm/nm/graceful-shutdown.sh $1 $2

# Run any service specific post stop script
if [ -f "/opt/tibco/tsnm/scripts/post-stop-service.sh" ]; then
    echo "Executing post stop service script..."
    /opt/tibco/tsnm/scripts/post-stop-service.sh
fi

# Make sure to fill the fluent-bit buffers for prestop hook
for i in {1..20}
do 
    echo "DONE" >> /opt/tibco/tsnm/nm/logs/tsnm-terminated
done
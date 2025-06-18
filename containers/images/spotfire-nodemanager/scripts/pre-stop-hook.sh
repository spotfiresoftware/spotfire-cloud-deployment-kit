#!/usr/bin/env bash

set -o verbose

# Initiate the shutdown
touch /opt/spotfire/nodemanager/nm/logs/nodemanager-terminated
/opt/spotfire/nodemanager/nm/graceful-shutdown.sh $1 $2

# Run any service specific post stop script
if [ -f "/opt/spotfire/nodemanager/scripts/post-stop-service.sh" ]; then
    echo "Executing post stop service script..."
    /opt/spotfire/nodemanager/scripts/post-stop-service.sh
fi

# Run any custom service specific post stop script
if [ -f "/opt/spotfire/nodemanager/scripts/post-stop-service.custom.sh" ]; then
    echo "Executing custom post stop service script..."
    /opt/spotfire/nodemanager/scripts/post-stop-service.custom.sh
fi

# Make sure to fill the fluent-bit buffers for prestop hook
for i in {1..20}
do
    echo "DONE" >> /opt/spotfire/nodemanager/nm/logs/nodemanager-terminated
done

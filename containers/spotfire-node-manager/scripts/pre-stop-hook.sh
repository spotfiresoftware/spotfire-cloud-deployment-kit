#!/usr/bin/env bash

# set -o nounset

# Initiate the shutdown
/opt/tibco/tsnm/nm/graceful-shutdown.sh $1 $2

# Run any service specific post stop script
if [ -f "/opt/tibco/tsnm/scripts/post-stop-service.sh" ]; then
    /opt/tibco/tsnm/scripts/post-stop-service.sh
fi

# Shutdown the nodemanager process
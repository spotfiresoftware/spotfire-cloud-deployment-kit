#!/usr/bin/env bash

# set -o nounset

# Initiate the shutdown
/opt/tibco/tsnm/nm/graceful-shutdown.sh $1 $2

# Shutdown the nodemanager process
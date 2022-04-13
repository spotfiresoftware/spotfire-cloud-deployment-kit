#!/usr/bin/env bash

# set -o nounset

# Initiate the shutdown
/opt/tibco/tss/tomcat/spotfire-bin/graceful-shutdown.sh $1 $2

# Shutdown the spotfire server process
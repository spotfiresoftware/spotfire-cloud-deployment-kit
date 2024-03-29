#!/bin/bash

# Exit if the environment variable ACCEPT_EUA is not set to Y or y
if [ "${ACCEPT_EUA^^}" != "Y" ]; then
  echo "You must accept the End User Agreement by setting the ACCEPT_EUA environment variable to Y"
  echo "Cloud Software Group, Inc. End User Agreement: https://www.cloud.com/legal/terms"
  exit 1
fi

# Execute config.sh with the same arguments as this script
/opt/spotfire/spotfireconfigtool/config.sh "$@"
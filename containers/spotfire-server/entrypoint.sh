#!/usr/bin/env bash

# Exit if the environment variable ACCEPT_EUA is not set to Y or y
if [ "${ACCEPT_EUA^^}" != "Y" ]; then
  echo "You must accept the End User Agreement by setting the ACCEPT_EUA environment variable to Y"
  echo "Cloud Software Group, Inc. End User Agreement: https://terms.tibco.com/#end-user-agreement"
  exit 1
fi

set -o nounset
set -o errexit

# Clean out any previous marker files
rm -f /opt/tibco/tss/tomcat/logs/tss-terminated

/opt/tibco/tss/tomcat/spotfire-bin/config.sh version || exit $?

scripts/setup-logging.sh || exit $?
scripts/bootstrap.sh || exit $?
scripts/startupcheck.sh || exit $?

echo $@
exec $@

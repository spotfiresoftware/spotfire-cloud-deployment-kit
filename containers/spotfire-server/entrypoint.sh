#!/usr/bin/env bash

set -o nounset
set -o errexit

/opt/tibco/tss/tomcat/spotfire-bin/config.sh version || exit $?

scripts/setup-logging.sh || exit $?
scripts/bootstrap.sh || exit $?
scripts/startupcheck.sh || exit $?

echo $@
exec $@

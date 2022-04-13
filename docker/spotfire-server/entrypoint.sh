#!/usr/bin/env bash

set -o nounset
set -o errexit

scripts/setup-logging.sh || exit $?
scripts/bootstrap.sh || exit $?
scripts/startupcheck.sh || exit $?

echo $@
exec $@

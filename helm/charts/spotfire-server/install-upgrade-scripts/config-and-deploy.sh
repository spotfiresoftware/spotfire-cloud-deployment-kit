#!/bin/bash

set -o nounset
set -o errexit

config.sh run --include-environment --fail-on-undefined-variable /tmp/script.txt
/opt/tibco/spotfireconfigtool/deploy.sh
#!/bin/bash

unzip /opt/tibco/tsnm/nm/webapps/spotfire.war -d /tmp/tsnm

mkdir -p /tmp/tsnm-install/nm

java \
  -cp "/opt/tibco/tsnm/nm/node-manager-remote-jetty.jar:/tmp/tsnm/WEB-INF/classes:/tmp/tsnm/WEB-INF/lib/*" \
  com.spotfire.server.nodemanager.control.InstallService \
  --nm-home=/tmp/tsnm-install/nm \
  "$@"
#!/bin/bash

unzip /opt/spotfire/nodemanager/nm/webapps/spotfire.war -d /tmp/nodemanager

mkdir -p /tmp/nodemanager-install/nm

java \
  -cp "/opt/spotfire/nodemanager/nm/node-manager-remote-jetty.jar:/opt/spotfire/nodemanager/nm/lib/*:/tmp/nodemanager/WEB-INF/classes:/tmp/nodemanager/WEB-INF/lib/*" \
  com.spotfire.server.nodemanager.control.InstallService \
  --nm-home=/tmp/nodemanager-install/nm \
  "$@"

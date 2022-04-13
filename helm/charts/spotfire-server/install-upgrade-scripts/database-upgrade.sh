#!/bin/bash

set -o nounset


config.sh export-config --tool-password="${TOOL_PASSWORD}" \
          --bootstrap-config="bootstrap.xml"

if [ ! -e "configuration.xml" ] ; then
    echo "There is no configuration assuming database doesn't need upgrade"
    exit 0;
fi

# We have a configuration

cat > upgrade.properties << EOF
db.driver=${DBSERVER_CLASS}
db.url=${DBSERVER_URL}
db.username=${SPOTFIREDB_USERNAME}
db.password=${SPOTFIREDB_PASSWORD}
issues.file=issues.html
db.only=true

EOF

java -Xms256m -Xmx4096m -classpath "spotfireconfigtool/lib/*:spotfireconfigtool/custom-ext/*" \
    -Dlog.dir=/opt/tibco/spotfireconfigtool/logs/ \
    -Dlog4j.configurationFile=/opt/tibco/spotfireconfigtool/log4j2-tools.xml \
    -Dtool.remote=true \
    com.spotfire.server.tools.upgrade.UpgradeLauncher -silent=upgrade.properties

upgrade_status=$?

echo "Possible issues are"
echo -n
cat issues.html
echo -n
cat /opt/tibco/spotfireconfigtool/logs/tools.log

if [ "${upgrade_status}" -ne 0 ] ; then
    echo "Upgraded reported error"
    exit "${upgrade_status}"
fi

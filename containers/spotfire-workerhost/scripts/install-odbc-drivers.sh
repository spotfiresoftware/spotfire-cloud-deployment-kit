#!/bin/bash

#
# Example script to install various odbc drivers
#

set -o errexit

# PostgreSQL ODBC driver
install_postgress() {
    if [ "$INSTALL_POSTGRES_DRIVER" != "Y" ]; then
        return 0
    fi
 
    apt-get install -y odbc-postgresql
}
# MariaDB ODBC driver  
install_mariadb() {
    if [ "$INSTALL_MARIADB_DRIVER" != "Y" ]; then
        return 0
    fi

    apt-get install -y gnupg2 odbc-mariadb
}

if [ "$INSTALL_ODBC_DRIVERS" != "Y" ]; then
    exit 0
fi

export DEBIAN_FRONTEND=noninteractive

apt-get install -y --no-install-recommends gnupg2 
touch /etc/odbcinst.ini

install_postgress
install_mariadb

echo "Installed ODBC Drivers"
odbcinst -q -d

# Cleanup
apt-get clean all
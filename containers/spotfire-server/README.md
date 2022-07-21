# spotfire-server container

## About this Image

This directory contains the official container recipe for **TIBCO Spotfire® Server**.

## What is the Spotfire Server?

**TIBCO Spotfire® Server** is the administrative center of the Spotfire environment.

The Spotfire Server:
- Facilitates configuration and administration of the Spotfire environment.
- Provides user authentication and role-based authorization.
- Provides centralized storage of Spotfire analysis files and metadata. The library items reside in the Spotfire database.
- Provides a centralized point of data access and metadata management for relational data sources.
- Provides access point for all client connections.
- Routes clients to the appropriate service instance, based on smart default routing or configured routing rules.
- Distributes software updates to services and clients.

For a quick overview, see the [Introduction to the TIBCO Spotfire environment](https://docs.tibco.com/pub/spotfire_server/latest/doc/html/TIB_sfire_server_tsas_admin_help/server/topics/introduction_to_the_tibco_spotfire_environment.html).

For more information on the Spotfire product family, see the [TIBCO Spotfire® Documentation](https://docs.tibco.com/products/tibco-spotfire/).

## How to build this image

**Note**: The easiest and recommended way to build all the Spotfire container images is using the provided containers `Makefile` as described in [Build the images](../README.md#build-the-images).

You can also build this image individually.
Follow the instructions below or adjust them according to your needs.

Prerequisites:
- You have built the [spotfire-base](../spotfire-base/README.md) container image.

Steps:
1. Copy the `tss-<version>.x86_64.tar.gz` package into the `build/` directory within this directory.
2. From the `<this-repo>/containers` folder, run `make spotfire-server` to build this image, or `make spotfire-server --dry-run` to just view the commands.

## How to use this image

Requirements:
- In order to bootstrap (initial setup) the **spotfire-server** container you need connectivity access to a working database server configured with the Spotfire database schemas and valid credentials.

**Note**: The Spotfire database needs to have configured valid schemas corresponding to the same Spotfire release. 

**Note**: The Spotfire database schemas can be created with the [spotfire-config](../spotfire-config/README.md) container.

### Start a Spotfire Server container

You can start an instance of the **TIBCO Spotfire Server** container with:
```bash
docker run -d --rm -p8080:8080 \
  -e SPOTFIREDB_CLASS="${SPOTFIREDB_CLASS}" \
  -e SPOTFIREDB_URL="jdbc:${SPOTFIREDB_DRIVER}://${SPOTFIREDB_HOST}:${SPOTFIREDB_PORT}/${SPOTFIREDB_DBNAME}" \
  -e SPOTFIREDB_USERNAME="${SPOTFIREDB_USERNAME}" \
  -e SPOTFIREDB_PASSWORD="${SPOTFIREDB_PASSWORD}" \
  -e TOOL_PASSWORD="${SPOTFIRE_CONFIG_TOOL_PASSWORD}" \
  tibco/spotfire-server
```

For example, starting a Spotfire Server container instance connecting to a Spotfire database using Postgresql as underlying database server: 

```bash
docker run -d --rm -p8080:8080 \
  -e SPOTFIREDB_CLASS=org.postgresql.Driver \
  -e SPOTFIREDB_URL=jdbc:postgresql://$SPOTFIREDB_HOST/spotfiredb \
  -e SPOTFIREDB_USERNAME=spotfire \
  -e SPOTFIREDB_PASSWORD=spotfirepassword \
  -e TOOL_PASSWORD=toolpassword \
  tibco/spotfire-server
```

**Note**: For details on variables for connecting to other supported databases, 
see [Database drivers and database connection
](https://docs.tibco.com/pub/spotfire_server/latest/doc/html/TIB_sfire_server_tsas_admin_help/server/topics/database_drivers_and_database_connection_urls.html) 

### Environment variables

#### Database connection

It is required to provide the Spotfire database connection details.
 
- `SPOTFIREDB_CLASS` - See **--driver-class** for [bootstrap command](https://docs.tibco.com/pub/spotfire_server/latest/doc/html/TIB_sfire_server_tsas_admin_help/server/topics/bootstrap.html) help.
   Example: *org.postgresql.Driver*
- `SPOTFIREDB_URL` - See **--database-url** in the [bootstrap command](https://docs.tibco.com/pub/spotfire_server/latest/doc/html/TIB_sfire_server_tsas_admin_help/server/topics/bootstrap.html) help. 
   Example: *jdbc:postgresql://server:5432/spotfire_server*
- `SPOTFIREDB_USERNAME` - See **--username** in the [bootstrap command](https://docs.tibco.com/pub/spotfire_server/latest/doc/html/TIB_sfire_server_tsas_admin_help/server/topics/bootstrap.html) help.
   Example: *spotfire*.
- `SPOTFIREDB_PASSWORD` - See **--password** in the [bootstrap command](https://docs.tibco.com/pub/spotfire_server/latest/doc/html/TIB_sfire_server_tsas_admin_help/server/topics/bootstrap.html) help.
   Example: *p4s5w0rd!*.
- `TOOL_PASSWORD` - See **--tool-password** in the [bootstrap command](https://docs.tibco.com/pub/spotfire_server/latest/doc/html/TIB_sfire_server_tsas_admin_help/server/topics/bootstrap.html) help.
   Example: **empty value**, meaning a random password will be generated.
- `SERVER_BACKEND_ADDRESS` - See **-Avalue** in the [bootstrap command](https://docs.tibco.com/pub/spotfire_server/latest/doc/html/TIB_sfire_server_tsas_admin_help/server/topics/bootstrap.html) help.
   Example: spotfire-server.

**Note**: All `SPOTFIREDB_*` environment variables are __required__ unless an existing `bootstrap.xml` exists in `/opt/tibco/tss/tomcat/webapps/spotfire/WEB-INF` during startup.

**Note**: Make sure to keep a backup before upgrading the database.

For more information, see the [database drivers and database connection URLs](https://docs.tibco.com/pub/spotfire_server/latest/doc/html/TIB_sfire_server_tsas_admin_help/server/topics/database_drivers_and_database_connection_urls.html)
and [bootstrap command](https://docs.tibco.com/pub/spotfire_server/latest/doc/html/TIB_sfire_server_tsas_admin_help/server/topics/bootstrap.html)
documentation pages.

#### Tomcat and JVM settings

- `CATALINA_INITIAL_HEAPSIZE` - The initial JVM heap size for the Spotfire Server. Default: `512M`.
- `CATALINA_MAXIMUM_HEAPSIZE` - The maximum JVM heap size for the Spotfire Server. Default: `1G`.
- `CATALINA_OPTS` - Tomcat runtime options used for the Spotfire Server. Default: `-Djava.net.preferIPv4Stack=true`.

#### Logging

The following variables define the default logging:

- `LOGGING_JSON_HOST` - Forward logs as json messages to this hostname. Default: *Unset* (disabled).
- `LOGGING_JSON_PORT` - Forward logs as json messages to this port. Default: `5170`.
- `LOGGING_HTTPREQUESTS_ENABLED`- Logs information about each http request. Default: *Unset* (enabled)
- `LOGGING_LOGLEVEL` - Set to `debug`, `minimal` or `trace` to adjust the logging level. 
Defaults to empty value meaning "info" level logging.
For more information, see [Server and node logging levels](https://docs.tibco.com/pub/spotfire_server/latest/doc/html/TIB_sfire_server_tsas_admin_help/server/topics/server_and_node_logging_levels.html).
- `LOGGING_SERVERLOG_SIZEPOLICY` - See **serverLogSizePolicy** in the [Log4j2
configuration properties](https://docs.tibco.com/pub/spotfire_server/latest/doc/html/TIB_sfire_server_tsas_admin_help/server/topics/node_log4j2_configuration_properties.html). Default `10MB`
- `LOGGING_SERVERLOG_DEFAULTROLLOVER` - See **serverLogDefaultRollover** in the [Log4j2
configuration properties](https://docs.tibco.com/pub/spotfire_server/latest/doc/html/TIB_sfire_server_tsas_admin_help/server/topics/node_log4j2_configuration_properties.html). Default `2`
- `LOGGING_NONSERVERLOG_SIZEPOLICY` - See **nonServerLogsSizePolicy** in the [Log4j2
configuration properties](https://docs.tibco.com/pub/spotfire_server/latest/doc/html/TIB_sfire_server_tsas_admin_help/server/topics/node_log4j2_configuration_properties.html). Default `10MB`
- `LOGGING_NONSERVERLOG_DEFAULTROLLOVER` - See **nonServerLogsDefaultRollover** in the [Log4j2
configuration properties](https://docs.tibco.com/pub/spotfire_server/latest/doc/html/TIB_sfire_server_tsas_admin_help/server/topics/node_log4j2_configuration_properties.html). Default `2`
- `LOGGING_TOMCATLOGS_SIZEPOLICY` - See **tomcatLogsSizePolicy** in the [Log4j2
configuration properties](https://docs.tibco.com/pub/spotfire_server/latest/doc/html/TIB_sfire_server_tsas_admin_help/server/topics/node_log4j2_configuration_properties.html). Default `10MB`
- `LOGGING_TOMCATLOGS_DEFAULTROLLOVER` - See **tomcatLogsDefaultRollover** in the [Log4j2
configuration properties](https://docs.tibco.com/pub/spotfire_server/latest/doc/html/TIB_sfire_server_tsas_admin_help/server/topics/node_log4j2_configuration_properties.html). Default `1d`


If `LOGGING_JSON_HOST` is set, Spotfire will forward logs to a remote logging collector/forwarder (e.g. fluentbit, fluentd, etc.).

#### Other variables

The following predefined startup checks are available:

- `STARTUPCHECK_TIMEOUT_SECONDS` - Timeout in seconds for the startup check. Default: `60` seconds.
- `STARTUPCHECK_ADMIN_USER` - Verify if administration user is set. Values: Y/N. Default: `N`.
- `STARTUPCHECK_VALID_DEPLOYMENT` - Verify if a valid package deployment is in place. Values: Y/N. Default: `N`.

The following variables define spotfire server site behavior:
- `SITE_NAME` - Define which site the server should belong to. Default: `Default`.
- `ENCRYPTION_PASSWORD` - The password for encrypting passwords that are stored in the database.  See \-\-encryption-password for the [bootstrap](https://docs.tibco.com/pub/spotfire_server/latest/doc/html/TIB_sfire_server_tsas_admin_help/server/topics/bootstrap.html) command. Default: If you do not set this option, a static password is used.

See [documentation related to sites](https://docs.tibco.com/pub/spotfire_server/latest/doc/html/TIB_sfire_server_tsas_admin_help/server/topics/sites.html) for more information.

## Advanced configuration

### Using custom logging

The **spotfire-server** container uses [log4j2](https://logging.apache.org/log4j/2.x/index.html) for logging configuration.
The logging configuration is stored in the `log4j2.xml` file.
The default configuration uses the [log4j Socket Appender](https://logging.apache.org/log4j/2.x/manual/appenders.html#SocketAppender).

You can modify the default configuration using any of the existing [log4j2 Appenders](https://logging.apache.org/log4j/2.x/manual/appenders.html) to forward the logs to your preferred logging collector. 

For doing that, you can for example mount your custom `log4j2.xml`:
```bash
docker run ... -v /local/path/to/custom-log4j2.xml:/opt/tibco/tss/tomcat/spotfire-config/log4j2.xml
```

**Note**: When overriding the default `log4j2.xml`, it's recommended to keep the overall file structure to minimize the number of changes.

### Using a shared folder for library export

By default, the Spotfire library content can be imported from and exported to the path: `/opt/tibco/tss/tomcat/application-data/library`.
You can mount this directory to an external volume that is shared between all Spotfire servers in the cluster.

Example:
```bash
docker run ... -v /local/path/to/library:/opt/tibco/tss/tomcat/application-data/library
```

Once an export and import location is set to an external volume, exported and imported library content can be transferred from and to this volume.

For more information on importing and exporting, see:
- [Importing to library](https://docs.tibco.com/pub/sfire-analyst/latest/doc/html/en-US/TIB_sfire-analyst_UsersGuide/index.htm#t=lib%2Flib_importing_to_library.htm)
- [Exporting from library](https://docs.tibco.com/pub/sfire-analyst/latest/doc/html/en-US/TIB_sfire-analyst_UsersGuide/index.htm#t=lib%2Flib_exporting_from_library.htm)
- [Command-based library administration tasks](https://docs.tibco.com/pub/spotfire_server/latest/doc/html/TIB_sfire_server_tsas_admin_help/server/topics/command-based_library_administration_tasks.html).

### Using custom jar files

You can add additional jar files to the Spotfire server.
For example, additional JDBC drivers to be used by Spotfire Server Information Services.
For that, you can add them into the following directory: `/opt/tibco/tss/tomcat/custom-ext`.

You can do this by mounting a volume into that path.
For example: 
```bash
docker run ... -v /local/path/to/custom-ext:/opt/tibco/tss/tomcat/custom-ext/
```

For more information about using extra jar files and `custom-ext` see:

- [Installing database drivers for Information Designer](https://docs.tibco.com/pub/spotfire_server/latest/doc/html/TIB_sfire_server_tsas_admin_help/server/topics/installing_database_drivers_for_information_designer.html)
- [Authentication towards a custom JAAS module](https://docs.tibco.com/pub/spotfire_server/latest/doc/html/TIB_sfire_server_tsas_admin_help/server/topics/authentication_towards_a_custom_jaas_module.html)
- [Post-authentication filter](https://docs.tibco.com/pub/spotfire_server/latest/doc/html/TIB_sfire_server_tsas_admin_help/server/topics/post-authentication_filter.html)

Alternatively you can [extend this image](#how-to-extend-this-image).

## How to extend this image

This example shows how to create a new container image, based from the **spotfire-server** image, to include custom drivers:

1. First follow the instructions for [how to build this image](#how-to-build-this-image).
2. Create a new `Dockerfile` in a new directory (e.g. **spotfire-server-extended**):
    ```Containerfile
    FROM tibco/spotfire-server
    COPY custom-ext/ /opt/tibco/tss/tomcat/custom-ext
    ```
3. Include your custom drivers in the `custom-ext` directory within that build directory.
4. Build the new custom image:
    ```Containerfile
    docker build -t spotfire-server-extended .
    ```

You can now use the container image **spotfire-server-extended**.

## Using the Spotfire Server configuration tool

**Note**: You can run the Spotfire config-tool from the `spotfire-server` container for troubleshooting purposes.
Anyhow, we recommend using the dedicated [spotfire-config](../spotfire-config/README.md) container for using the Spotfire config-tool.

The spotfire server configuration tool is available in a running Spotfire server container as the command `config.sh`.
The `--tool-password` needed to run many commands is stored in the `TOOL_PASSWORD` environment variable.

Example:

```bash
# Start a shell in the container
host $ docker exec -it spotfire-server-container bash

# Export the configuration
spotfire-server-container $ config.sh export-config --tool-password="${TOOL_PASSWORD}"
```

For more information, see the [Command-line reference](https://docs.tibco.com/pub/spotfire_server/latest/doc/html/TIB_sfire_server_tsas_admin_help/server/topics/command-line_reference.html).



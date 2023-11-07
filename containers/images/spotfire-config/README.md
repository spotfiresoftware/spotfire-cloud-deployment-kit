# spotfire-config container

## About this Image

This directory contains the official container recipe for **Spotfire® configuration tool**.

## What is the Spotfire configuration tool?

The Spotfire Server configuration tool provides a command-line for Spotfire installation and administration.

**Note**: The configuration tool requires a connection to the Spotfire database in order to configure a Spotfire environment. 
The [bootstrap.xml](https://docs.tibco.com/pub/spotfire_server/latest/doc/html/TIB_sfire_server_tsas_admin_help/server/topics/creating_the_bootstrap.xml_file.html) 
file contains basic information that the server needs to connect to the Spotfire database and retrieve its configuration.

**Note**: Some configuration tool commands also require access to the Spotfire Server instances.

## How to build this container image

**Note**: The easiest and recommended way to build all the Spotfire container images is using the provided containers `Makefile` as described in [Build the images](../../README.md#build-the-images).

You can also build this image individually.
Follow the instructions below or adjust them according to your needs.

Prerequisites:
- You have built the [spotfire-base](../spotfire-base/README.md) container image.

Steps:
1. Copy the `spotfireserver-<version>.x86_64.tar.gz` package into the `build/` directory within this directory.
2. From the `<this-repo>/containers` folder, run `make spotfire-config` to build this image, or `make spotfire-config --dry-run` to just view the commands.
 
## How to use this image

You can run the containerized Spotfire configuration tool with:
```bash
docker run -e ACCEPT_EUA=Y --rm spotfire/spotfire-config help
```

**Note**:  This Spotfire container image requires setting the environment variable `ACCEPT_EUA`.
By passing the value `Y` to the environment variable `ACCEPT_EUA`, you agree that your use of the Spotfire software running in this container will be governed by the terms of the [Cloud Software Group, Inc. End User Agreement](https://www.cloud.com/legal/terms).

For configuration tool documentation, check the [Command-line reference](https://docs.tibco.com/pub/spotfire_server/latest/doc/html/TIB_sfire_server_tsas_admin_help/server/topics/command-line_reference.html) 
within the [Spotfire® Server and Environment - Installation and Administration](https://docs.tibco.com/pub/spotfire_server/latest/doc/html/TIB_sfire_server_tsas_admin_help/server-homepage.html) help.

### Environment variables

- `LOG_LEVEL` - Set to `DEBUG` or `TRACE` to increase the log level. Default unset (INFO).
- `LOG_APPENDER` - Set to `console` to log to STDERR instead of a file or `toolLog` for logging to file '/opt/spotfire/spotfireconfigtool/logs/tools.log'. Default `toolLog` (INFO).

### Examples

For more information, see the [database drivers and database connection URLs](https://docs.tibco.com/pub/spotfire_server/latest/doc/html/TIB_sfire_server_tsas_admin_help/server/topics/database_drivers_and_database_connection_urls.html)
and [bootstrap command](https://docs.tibco.com/pub/spotfire_server/latest/doc/html/TIB_sfire_server_tsas_admin_help/server/topics/bootstrap.html)
documentation pages.

#### Create the Spotfire database schemas in the given database server

```bash
docker run --rm -it -e ACCEPT_EUA=Y spotfire/spotfire-config create-db \
  --driver-class=org.postgresql.Driver \
  --database-url=jdbc:postgresql://172.17.0.1/ \
  --admin-username=postgres \
  --admin-password=adminpassword \
  --spotfiredb-dbname=spotfire \
  --spotfiredb-username=spotfire \
  --spotfiredb-password=spotfirepassword \
  --no-prompt
```

#### Create a bootstrap file

You can use the Spotfire configuration tool to create bootstrap.xml:

```bash
touch bootstrap.xml
docker run --rm -it -e ACCEPT_EUA=Y \
  -v "$(pwd)/bootstrap.xml:/opt/spotfire/bootstrap.xml" \
  spotfire/spotfire-config bootstrap \
  --driver-class=org.postgresql.Driver \
  --database-url=jdbc:postgresql://172.17.0.1/ \
  --username=spotfire \
  --password=spotfire \
  --no-prompt \
  --tool-password=password \
  --force bootstrap.xml
```

#### Scripting a configuration with configuration tool

You can use a script to execute a series of Spotfire configuration tool commands:

```bash
docker run --rm -it -e ACCEPT_EUA=Y \
  -v "$(pwd)/bootstrap.xml:/opt/spotfire/bootstrap.xml" \
  -v "$(pwd)/script.txt:/opt/spotfire/script.txt" \
  spotfire/spotfire-config run \
  --include-environment --fail-on-undefined-variable script.txt
```

For more information, see [Scripting a configuration](https://docs.tibco.com/pub/spotfire_server/latest/doc/html/TIB_sfire_server_tsas_admin_help/server/topics/scripting_a_configuration.html).

#### Running the configuration tool interactively or with a custom script

To start a container to use the configuration tool interactively override the predefined entrypoint by specifying `--entrypoint` or `--command`.
From the container prompt, the configuration tool can be started with the command `./config.sh`.

```bash
# Run configuration tool interactively with docker run
docker run --rm -it -e ACCEPT_EUA=Y --entrypoint=bash spotfire/spotfire-config

# Run configuration tool interactively using kubectl
kubectl run mypod -it --image=spotfire/spotfire-config --command -- bash
```

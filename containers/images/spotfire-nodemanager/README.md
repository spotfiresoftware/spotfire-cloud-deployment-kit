# spotfire-nodemanager

## About this image

This directory contains the official container recipe for **Spotfire® node manager**.

## What is Spotfire node manager?

**Spotfire® node manager** is the service used for controlling the Spotfire services.

The Spotfire node manager can manage the following Spotfire services:

- **Spotfire® Web Player** service: enables users to perform analyses from a web browser.
- **Spotfire® Automation Services**: allows scheduling custom jobs.
- **Spotfire® Enterprise Runtime for R - Server Edition (a/k/a the TERR™ service)**: allows additional calculations and advanced analytics using Spotfire Enterprise Runtime for R (a/k/a TERR™).
- **Spotfire® Service for Python**: allows additional calculations and advanced analytics using Python.

For more information, see the [Introduction to the Spotfire environment](https://spotfi.re/docs/server).

## How to build this image

The easiest and recommended way to build all the Spotfire container images is using the provided `containers/Makefile`. See [Spotfire Cloud Deployment Kit on GitHub](https://github.com/spotfiresoftware/spotfire-cloud-deployment-kit).

You can also build this image individually.
Follow the instructions below or adjust them according to your needs.

Prerequisites:

- You have built the [spotfire-base](../spotfire-base/README.md) container image.

Steps:

1. Copy the `spotfirenodemanager-<version>.x86_64.tar.gz` package into the `build/` directory within this folder.
2. From the `<this-repo>/containers` folder, run `make spotfire-nodemanager` to build this image, or `make spotfire-nodemanager --dry-run` to preview the required commands.

## How to use this image

Prerequisites:

- To start the **spotfire-nodemanager** container, first you need a configured **spotfire-server** to connect to.

### Start a node manager container

You can start an instance of the **Spotfire node manager** container with:
```bash
docker run -d --rm -e ACCEPT_EUA=Y \
  -e SERVER_BACKEND_ADDRESS=spotfire-server \
  spotfire/spotfire-nodemanager
```

**Note**:  This Spotfire container image requires setting the environment variable `ACCEPT_EUA`.
By passing the value `Y` to the environment variable `ACCEPT_EUA`, you agree that your use of the Spotfire software running in this container will be governed by the terms of the [Cloud Software Group, Inc. End User Agreement](https://www.cloud.com/legal/terms).

### Adding services to the node manager

Prerequisites:

- You have deployed the corresponding Spotfire distribution package (.sdn) to the Spotfire Server.
For instructions, see [Deploying client packages to Spotfire Server](https://docs.tibco.com/pub/spotfire_server/latest/doc/html/TIB_sfire_server_tsas_admin_help/server/topics/deploying_client_packages_to_spotfire_server.html).

As with on-premises deployment, you can manually add Spotfire services to be managed by the Spotfire node manager as described below.

**IMPORTANT**: This image recipe is provided only for reference and testing purposes.
Installation of Spotfire services in this image requires installation of additional software and changes to the Spotfire services configuration.
Instead of installing services in this image, use the specialized container images to run the Spotfire services.
For example, the [spotfire-pythonservice](../spotfire-pythonservice/README.md) or the [spotfire-webplayer](../spotfire-webplayer/README.md).

**Note**: A Spotfire service running on a node manager runs in a separate process.

**Note**: In bare-metal or VM configurations, a node manager can control several Spotfire services in the same host and each Spotfire service can manage multiple instances.
When running in containers, create only one Spotfire service and one Spotfire service instance in that service for each running container instance.

You can automatically add the Spotfire service in the container on startup by providing a default Spotfire services configuration file.
For example:
```bash
docker run -d --rm -e ACCEPT_EUA=Y \
  -e SERVER_BACKEND_ADDRESS=spotfire-server \
  -v "$(pwd)/default.conf:/opt/spotfire/nodemanager/nm/config/default-container.conf" \
  spotfire/spotfire-nodemanager
```

For more information, see [Automatically installing services](https://docs.tibco.com/pub/spotfire_server/latest/doc/html/TIB_sfire_server_tsas_admin_help/server/topics/automatically_installing_services_and_instances.html).

**Note**: Do not mount over `/opt/spotfire/nodemanager/nm/config/default.conf` (as described in the product documentation), because this file is deleted during startup. Instead, follow the example provided above.

**Note**: The Spotfire service installation files are copied in the image under `/opt/spotfire/nodemanager/services/`.

### Environment variables

- `ACCEPT_EUA` - Accept the [Cloud Software Group, Inc. End User Agreement](https://www.cloud.com/legal/terms) by setting the value to `Y`. Required.
- `SERVER_BACKEND_ADDRESS` - See **SERVER_NAME** in the [Installation parameters](https://docs.tibco.com/pub/spotfire_server/latest/doc/html/TIB_sfire_server_tsas_admin_help/server/topics/node_manager_installation.html). Example: `spotfire-server`.
- `NODEMANAGER_REGISTRATION_PORT` - See **NODEMANAGER_REGISTRATION_PORT** in the [Installation parameters](https://docs.tibco.com/pub/spotfire_server/latest/doc/html/TIB_sfire_server_tsas_admin_help/server/topics/node_manager_installation.html). Default value `9080`.
- `NODEMANAGER_COMMUNICATION_PORT` -  See **NODEMANAGER_COMMUNICATION_PORT** in the [Installation parameters](https://docs.tibco.com/pub/spotfire_server/latest/doc/html/TIB_sfire_server_tsas_admin_help/server/topics/node_manager_installation.html). Default value `9443`.
- `SERVER_BACKEND_REGISTRATION_PORT` - See **SERVER_BACKEND_REGISTRATION_PORT** in the [Installation parameters](https://docs.tibco.com/pub/spotfire_server/latest/doc/html/TIB_sfire_server_tsas_admin_help/server/topics/node_manager_installation.html). Default value `9080`.
- `SERVER_BACKEND_COMMUNICATION_PORT` - See **SERVER_BACKEND_COMMUNICATION_PORT** in the [Installation parameters](https://docs.tibco.com/pub/spotfire_server/latest/doc/html/TIB_sfire_server_tsas_admin_help/server/topics/node_manager_installation.html). Default value `9443`.
- `NODEMANAGER_HOST_NAMES` - See **NODEMANAGER_HOST_NAMES** in the [Installation parameters](https://docs.tibco.com/pub/spotfire_server/latest/doc/html/TIB_sfire_server_tsas_admin_help/server/topics/node_manager_installation.html). Default value: *Unset*.
- `NM_LOG_LEVEL` - Set to `debug`, `minimal` or `trace` to adjust the logging level. Defaults to empty value meaning "info" level logging.
- `LOGGING_NMLOG_SIZE` - See **nm.log.size** in the [Node Log4j2 configuration properties](https://docs.tibco.com/pub/spotfire_server/latest/doc/html/TIB_sfire_server_tsas_admin_help/server/topics/node_log4j2_configuration_properties.html). Default `10MB`
- `LOGGING_NMLOG_MAX` - See **nm.log.max** in the [Node Log4j2 configuration properties](https://docs.tibco.com/pub/spotfire_server/latest/doc/html/TIB_sfire_server_tsas_admin_help/server/topics/node_log4j2_configuration_properties.html). Default `2`
- `LOGGING_NMPERFORMANCELOG_SIZE` - See **nm.performance.log.size** in the [Node Log4j2 configuration properties](https://docs.tibco.com/pub/spotfire_server/latest/doc/html/TIB_sfire_server_tsas_admin_help/server/topics/node_log4j2_configuration_properties.html). Default `10MB`
- `LOGGING_NMPERFORMANCELOG_MAX` - See **nm.performance.log.max** in the [Node Log4j2 configuration properties](https://docs.tibco.com/pub/spotfire_server/latest/doc/html/TIB_sfire_server_tsas_admin_help/server/topics/node_log4j2_configuration_properties.html). Default `2`

### Adding custom CA certificates

The node manager container supports adding custom Certificate Authority (CA) certificates for secure connections to external services that use self-signed or enterprise CA certificates.

Mount your custom CA certificates into the `/usr/local/share/ca-certificates` directory:

```bash
docker run -d --rm -e ACCEPT_EUA=Y \
  -e SERVER_BACKEND_ADDRESS=spotfire-server \
  -v "/path/to/your/certificates:/usr/local/share/ca-certificates:ro" \
  spotfire/spotfire-nodemanager
```

You can also mount individual certificate files:

```bash
docker run -d --rm -e ACCEPT_EUA=Y \
  -e SERVER_BACKEND_ADDRESS=spotfire-server \
  -v "/path/to/your-ca.crt:/usr/local/share/ca-certificates/your-ca.crt:ro" \
  spotfire/spotfire-nodemanager
```

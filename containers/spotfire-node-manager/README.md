# spotfire-node-manager

## About This Image

This directory contains the official container recipe for **TIBCO Spotfire® node manager**. 

## What is Spotfire node manager?

**TIBCO Spotfire® node manager** is the service used for controlling the Spotfire services.

The Spotfire node manager can manage the following Spotfire services:
- **TIBCO Spotfire® Web Player** service: enables users to perform analyses from a web browser. 
- **TIBCO Spotfire® Automation Services**: allows scheduling custom jobs.
- **TIBCO Spotfire® Service for TERR (TIBCO Enterprise Runtime for R)**: allows additional calculations and advanced analytics using TERR.
- **TIBCO Spotfire® Service for Python**: allows additional calculations and advanced analytics using Python. 

For more information, see the [Introduction to the TIBCO Spotfire environment](https://docs.tibco.com/pub/spotfire_server/latest/doc/html/TIB_sfire_server_tsas_admin_help/server/topics/introduction_to_the_tibco_spotfire_environment.html).

## How to build this image

**Note**: The easiest and recommended way to build all the Spotfire container images is using the provided containers `Makefile` as described in [Build the images](../README.md#build-the-images).

You can also build this image individually.
Follow the instructions below or adjust them according to your needs.

Prerequisites:
- You have built the [spotfire-base](../spotfire-base/README.md) container image.

Steps:
1. Copy the `tsnm-<version>.x86_64.tar.gz` package into the `build/` directory within this folder.
2. From the `<this-repo>/containers` folder, run `make spotfire-node-manager` to build this image, or `make spotfire-node-manager --dry-run` to preview the required commands.

## How to use this image

Prerequisites:
- To start the **spotfire-node-manager** container, first you need a configured **spotfire-server** to connect to.

### Start a node manager container

You can start an instance of the **TIBCO Spotfire node manager** container with:
```bash
docker run -d --rm -e ACCEPT_EUA=Y \
  -e SERVER_BACKEND_ADDRESS=spotfire-server \
  tibco/spotfire-node-manager
```

**Note**:  This TIBCO Spotfire container image requires setting the environment variable `ACCEPT_EUA`.
By passing the value `Y` to the environment variable `ACCEPT_EUA`, you agree that your use of the TIBCO Spotfire software running in this container will be governed by the terms of the [Cloud Software Group, Inc. End User Agreement](https://terms.tibco.com/#end-user-agreement).

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
  -v "$(pwd)/default.conf:/opt/tibco/tsnm/nm/config/default-container.conf" \
  tibco/spotfire-node-manager
```

For more information, see [Automatically installing services](https://docs.tibco.com/pub/spotfire_server/latest/doc/html/TIB_sfire_server_tsas_admin_help/server/topics/automatically_installing_services_and_instances.html). 

**Note**: Do not mount over `/opt/tibco/tsnm/nm/config/default.conf` (as described in the product documentation), because this file is deleted during startup. Instead, follow the example provided above.

**Note**: The Spotfire service installation files are copied in the image under `/opt/tibco/tsnm/services/`.

### Environment variables

- `ACCEPT_EUA` - Accept the [Cloud Software Group, Inc. End User Agreement](https://terms.tibco.com/#end-user-agreement) by setting the value to `Y`. Required.
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

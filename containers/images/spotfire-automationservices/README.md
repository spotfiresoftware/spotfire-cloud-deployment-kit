# spotfire-automationservices

## About This Image

This directory contains the official container recipe for **Spotfire® Automation Services**. 

## What is Spotfire Automation Services?

**Spotfire® Automation Services** is a service for automatically executing multi-step jobs within your Spotfire® environment.

For a quick overview, see the [Introduction to the Spotfire environment](https://docs.tibco.com/pub/spotfire_server/latest/doc/html/TIB_sfire_server_tsas_admin_help/server/topics/introduction_to_the_spotfire_environment.html).

For more information on the Spotfire product family, see the [Spotfire® Documentation](https://docs.tibco.com/products/spotfire/).

## How to build this image

**Note**: The easiest and recommended way to build all the Spotfire container images is using the provided containers `Makefile` as described in [Build the images](../../README.md#build-the-images).

You can also build this image individually. 
Follow the instructions below or adjust them according to your needs.

Prerequisites:
- You have built the [spotfire-workerhost](../spotfire-workerhost/README.md) container image.

Steps:
1. Copy the `Spotfire.Dxp.netcore-linux.sdn` package into the `build/` directory within this folder.
2. From the `<this-repo>/containers` folder, run `make spotfire-automationservices` to build this image, or `make spotfire-automationservices --dry-run` to just view the commands.

### Adding custom Spotfire packages
At build time, put custom spk files in the `build/` folder.

## How to use this image

Prerequisites:
- A running [spotfire server](../spotfire-server/README.md) container instance to connect to.
- Spotfire client packages deployed to a deployment area so that the required licenses exist for `spotfire-automationservices` to start.

### Start an Automation Services container

You can start an instance of the **Spotfire Automation Services** container with:
```bash
docker run -d --rm -e ACCEPT_EUA=Y \
  -e SERVER_BACKEND_ADDRESS=spotfire-server \
  spotfire/spotfire-automationservices
```

**Note**:  This Spotfire container image requires setting the environment variable `ACCEPT_EUA`.
By passing the value `Y` to the environment variable `ACCEPT_EUA`, you agree that your use of the Spotfire software running in this container will be governed by the terms of the [Cloud Software Group, Inc. End User Agreement](https://www.cloud.com/legal/terms).

### Starting with a custom configuration

You can also start the `spotfire-automationservices` with a custom configuration by providing a Spotfire services configuration file:
```bash
docker run -d --rm -e ACCEPT_EUA=Y \
  -e SERVER_BACKEND_ADDRESS=spotfire-server \
  -v "$(pwd)/Spotfire.Dxp.Worker.Web.config:/opt/spotfire/nodemanager/nm/services/AUTOMATION_SERVICES/Spotfire.Dxp.Worker.Web.config" \
  spotfire/spotfire-automationservices
```

For more information, see [Service configuration files](https://docs.tibco.com/pub/spotfire_server/latest/doc/html/TIB_sfire_server_tsas_admin_help/server/topics/service_configuration_files.html) 
and [Service logs configuration](https://docs.tibco.com/pub/spotfire_server/latest/doc/html/TIB_sfire_server_tsas_admin_help/server/topics/service_logs.html). 

### Environment variables

- `LOGGING_SERVICELOG_MAX` - Maximum number of automation services log files to save. Default `2`
- `LOGGING_SERVICELOG_SIZE` - Maximum size for automation services service log files. Default `10MB`

See the common Spotfire Node manager [environment variables](../spotfire-nodemanager/README.md#environment-variables).

# spotfire-webplayer

## About This Image

This directory contains the official container recipe for **TIBCO Spotfire® Web Player**. 

## What is TIBCO Spotfire Web Player?

**TIBCO Spotfire® Web Player** is a remote application server to enable analysis consumption from web browser and mobile devices.

The Spotfire Web Player generates visualizations that are displayed in the Spotfire web clients and mobile apps.

The Spotfire Server handles client session routing towards Spotfire Web Players instances to optimize resource allocation.
It is possible to define Resource Pools and Routing Rules for fine-grained QoS control for different users, groups or analysis.

For a quick overview, see the [Introduction to the TIBCO Spotfire environment](https://docs.tibco.com/pub/spotfire_server/latest/doc/html/TIB_sfire_server_tsas_admin_help/server/topics/introduction_to_the_tibco_spotfire_environment.html).

For more information on the Spotfire product family, see the [TIBCO Spotfire® Documentation](https://docs.tibco.com/products/tibco-spotfire/).

## How to build this image

**Note**: The easiest and recommended way to build all the Spotfire container images is using the provided containers `Makefile` as described in [Build the images](../README.md#build-the-images).

You can also build this image individually.
Follow the instructions below or adjust them according to your needs.

Prerequisites:
- You have built the [spotfire-workerhost](../spotfire-workerhost/README.md) container image.

Steps:
1. Copy the `Spotfire.Dxp.netcore-linux.sdn` package into the `build/` directory within this folder.
2. Copy language pack files (for example de-DE-netcore.sdn) into the `build/` with the desired language packs to build into the image. 
   These files can be extracted from `TIB_sfire_server_<version>_languagepack-multi.zip`.
3. From the `<this-repo>/containers` folder, run `make spotfire-webplayer` to build this image, or `make spotfire-webplayer --dry-run` to just view the commands.

### Adding custom Spotfire packages
At build time, put custom spk files in the `build/` folder.

## How to use this image

Prerequisites:
- A running [spotfire server](../spotfire-server/README.md) container instance to connect to.
- Spotfire client packages deployed to a deployment area so that the required licenses exists for the `spotfire-webplayer` to start.

### Start a Web Player container

You can start an instance of the **TIBCO Spotfire Web Player** container with:
```bash
docker run -d --rm -e ACCEPT_EUA=Y -e SERVER_BACKEND_ADDRESS=spotfire-server tibco/spotfire-webplayer
```

**Note**:  This TIBCO Spotfire container image requires setting the environment variable `ACCEPT_EUA`.
By passing the value `Y` to the environment variable `ACCEPT_EUA`, you agree that your use of the TIBCO Spotfire software running in this container will be governed by the terms of the [Cloud Software Group, Inc. End User Agreement](https://terms.tibco.com/#end-user-agreement).

### Starting with a custom configuration

You can also start the `spotfire-webplayer` with a custom configuration by providing a Spotfire services configuration file:
```bash
docker run -d --rm -e ACCEPT_EUA=Y -e SERVER_BACKEND_ADDRESS=spotfire-server tibco/spotfire-webplayer \
  -v "$(pwd)/Spotfire.Dxp.Worker.Web.config:/opt/tibco/tsnm/nm/services/WEB_PLAYER/Spotfire.Dxp.Worker.Web.config"
```

For more information, see [Service configuration files](https://docs.tibco.com/pub/spotfire_server/latest/doc/html/TIB_sfire_server_tsas_admin_help/server/topics/service_configuration_files.html) 
and [Service logs configuration](https://docs.tibco.com/pub/spotfire_server/latest/doc/html/TIB_sfire_server_tsas_admin_help/server/topics/service_logs.html). 

### Environment variables

- `TSWP_RESOURCEPOOL` - Set to the name of the resource pool the `spotfire-webplayer` instance should belong to. 
  Default value: *Unset*
- `LOGGING_SERVICELOG_MAX` - Maximum number of web player service log files to save. Default `2`
- `LOGGING_SERVICELOG_SIZE` - Maximum size for web player service service log files. Default `10MB`

**Note**: See also the Spotfire Node manager [environment variables](../spotfire-node-manager/README.md#environment-variables).

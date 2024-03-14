# spotfire-webplayer

## About This Image

This directory contains the official container recipe for **Spotfire® Web Player**.

## What is Spotfire Web Player?

**Spotfire® Web Player** is a remote application server to enable analysis consumption from web browser and mobile devices.

The Spotfire Web Player generates visualizations that are displayed in the Spotfire web clients and mobile apps.

The Spotfire Server handles client session routing towards Spotfire Web Players instances to optimize resource allocation.
It is possible to define Resource Pools and Routing Rules for fine-grained QoS control for different users, groups or analysis.

For a quick overview, see the [Introduction to the Spotfire environment](https://docs.tibco.com/pub/spotfire_server/latest/doc/html/TIB_sfire_server_tsas_admin_help/server/topics/introduction_to_the_spotfire_environment.html).

For more information on the Spotfire product family, see the [Spotfire® Documentation](https://spotfi.re/docs).

## How to build this image

**Note**: The easiest and recommended way to build all the Spotfire container images is using the provided containers `Makefile` as described in [Build the images](../../README.md#build-the-images).

You can also build this image individually.
Follow the instructions below or adjust them according to your needs.

Prerequisites:
- You have built the [spotfire-workerhost](../spotfire-workerhost/README.md) container image.

Steps:
1. Copy the `Spotfire.Dxp.netcore-linux.sdn` package into the `build/` directory within this folder.
2. Copy language pack files (for example de-DE-netcore.sdn) into the `build/` with the desired language packs to build into the image.
   These files can be extracted from `SPOT_sfire_server_<version>_languagepack-multi.zip`.
3. From the `<this-repo>/containers` folder, run `make spotfire-webplayer` to build this image, or `make spotfire-webplayer --dry-run` to just view the commands.

### Adding custom Spotfire packages
Custom packages (SPKs) can include a cobranding package, for example.  You must use the Spotfire® Package Builder console to create the cobranding package for your containerized Web Player. See [Creating and deploying a cobranding package](https://docs.tibco.com/pub/sfire-analyst/latest/doc/html/en-US/TIB_sfire_cobranding_help/cobranding/topics/creating_and_deploying_a_cobranding_package.html) for more information.

At build time, put custom spk files in the `build/` folder.

## How to use this image

Prerequisites:
- A running [spotfire server](../spotfire-server/README.md) container instance to connect to.
- Spotfire client packages deployed to a deployment area so that the required licenses exists for the `spotfire-webplayer` to start.

### Start a Web Player container

You can start an instance of the **Spotfire Web Player** container with:
```bash
docker run -d --rm -e ACCEPT_EUA=Y \
  -e SERVER_BACKEND_ADDRESS=spotfire-server \
  spotfire/spotfire-webplayer
```

**Note**:  This Spotfire container image requires setting the environment variable `ACCEPT_EUA`.
By passing the value `Y` to the environment variable `ACCEPT_EUA`, you agree that your use of the Spotfire software running in this container will be governed by the terms of the [Cloud Software Group, Inc. End User Agreement](https://www.cloud.com/legal/terms).

### Starting with a custom configuration

You can also start the `spotfire-webplayer` with a custom configuration by providing a Spotfire services configuration file:
```bash
docker run -d --rm -e ACCEPT_EUA=Y \
  -e SERVER_BACKEND_ADDRESS=spotfire-server \
  -v "$(pwd)/Spotfire.Dxp.Worker.Web.config:/opt/spotfire/nodemanager/nm/services/WEB_PLAYER/Spotfire.Dxp.Worker.Web.config" \
  spotfire/spotfire-webplayer
```

For more information, see [Service configuration files](https://docs.tibco.com/pub/spotfire_server/latest/doc/html/TIB_sfire_server_tsas_admin_help/server/topics/service_configuration_files.html)
and [Service logs configuration](https://docs.tibco.com/pub/spotfire_server/latest/doc/html/TIB_sfire_server_tsas_admin_help/server/topics/service_logs.html).

### Environment variables

- `TSWP_RESOURCEPOOL` - Set to the name of the resource pool the `spotfire-webplayer` instance should belong to.
  Default value: *Unset*
- `LOGGING_SERVICELOG_MAX` - Maximum number of web player service log files to save. Default `2`
- `LOGGING_SERVICELOG_SIZE` - Maximum size for web player service service log files. Default `10MB`

**Note**: See also the Spotfire Node manager [environment variables](../spotfire-nodemanager/README.md#environment-variables).

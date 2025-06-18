# spotfire-webplayer

## About this image

This directory contains the official container recipe for **Spotfire® Web Player**.

## What is Spotfire Web Player?

**Spotfire® Web Player** is a remote application server to enable analysis consumption from web browser and mobile devices.

The Spotfire Web Player generates visualizations that are displayed in the Spotfire web clients and mobile apps.

The Spotfire Server handles client session routing towards Spotfire Web Players instances to optimize resource allocation.
It is possible to define Resource Pools and Routing Rules for fine-grained QoS control for different users, groups or analysis.

For a quick overview, see the [Introduction to the Spotfire environment](https://spotfi.re/docs/server/).

For more information on the Spotfire product family, see the [Spotfire® Documentation](https://spotfi.re/docs).

## How to build this image

The easiest and recommended way to build all the Spotfire container images is using the provided `containers/Makefile`. See [Spotfire Cloud Deployment Kit on GitHub](https://github.com/spotfiresoftware/spotfire-cloud-deployment-kit).

You can also build this image individually.
Follow the instructions below or adjust them according to your needs.

Prerequisites:
- You have built the [spotfire-workerhost](../spotfire-workerhost/README.md) container image.

Steps:

1. Copy the `Spotfire.Dxp.netcore-linux.sdn` package into the `build/` directory within this folder.
2. Copy language pack files (for example de-DE-netcore.sdn) into the `build/` with the desired language packs to build into the image.
   These files can be extracted from `SPOT_sfire-app_<version>_enterprise-languagepacks.zip`.
3. From the `<this-repo>/containers` folder, run `make spotfire-webplayer` to build this image, or `make spotfire-webplayer --dry-run` to just view the commands.

### Adding custom Spotfire packages

Custom packages (SPKs) can include a cobranding package, for example.  You must use the Spotfire® Package Builder console to create the cobranding package for your containerized Web Player. See [Creating and deploying a cobranding package](https://docs.tibco.com/pub/sfire-analyst/latest/doc/html/en-US/TIB_sfire_cobranding_help/cobranding/topics/creating_and_deploying_a_cobranding_package.html) for more information.

At build time, put custom spk files in the `build/` folder.

### Adding additional ODBC drivers

Some Spotfire connectors will not be available in the default image unless you install required ODBC driver for the connector.
To install additional ODBC drivers container image, you can create a custom Dockerfile. Here's a basic example of how you can do this:

```Dockerfile
# Start from the default image
FROM spotfire-webplayer:tag

# Switch to root user to install additional packages
USER root

# Install the ODBC driver
RUN echo "Add installation steps here"

# Switch back to the spotfire user
USER spotfire
```

Replace `spotfire-webplayer:tag` with the name and tag of the default spotfire-webplayer image. This image needs to be available before you can use it as a base image for your custom image. After creating this Dockerfile, you can build your custom image with the following command:

```bash
docker build -t custom_image:tag -f Dockerfile .
```

Replace `custom_image:tag` with the name and tag you want to give to your custom image. You can then use this image to start a container with the additional ODBC driver installed.

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

**Note:**  This Spotfire container image requires setting the environment variable `ACCEPT_EUA`.
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
- `LOGGING_WORKERHOST_LOGLEVEL` - Log configuration for the Web Player service. Currently available configs are: `standard`, `minimum`, `info`, `debug`, `monitoring`, `fullmonitoring`, `trace`

**Note:** See also the Spotfire node manager [environment variables](../spotfire-nodemanager/README.md#environment-variables).

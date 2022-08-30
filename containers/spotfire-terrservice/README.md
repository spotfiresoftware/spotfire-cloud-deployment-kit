# spotfire-terrservice

## About This Image

This directory contains the official container recipe for **[TIBCO® Enterprise Runtime for R - Server Edition](https://docs.tibco.com/pub/terrsrv/latest/doc/html/TIB_terrsrv_install/terrinstall-homepage.html)**. 

## What is TIBCO Enterprise Runtime for R (TERR) - Server Edition?

**TIBCO® Enterprise Runtime for R (TERR)** is a high-performance, enterprise-quality statistical engine to provide predictive analytic capabilities. 
TERR enables users to integrate and deploy advanced analytics written in the R language into their applications using an enterprise-quality R-compatible runtime environment.

**TIBCO® Enterprise Runtime for R - Server Edition** (aka TERR service) provides remote execution of TERR data functions, TERR predictive analytics, or TERR custom expressions for users from web client and mobile devices (TIBCO Spotfire® Business Author and Consumer).

**Note**: _TERR service_ is provided as a _TIBCO Spotfire Statistics Services_ component in [TIBCO eDelivery](https://edelivery.tibco.com/storefront/index.ep).

References:
- For a quick overview, see the [Introduction to the TIBCO Spotfire environment](https://docs.tibco.com/pub/spotfire_server/latest/doc/html/TIB_sfire_server_tsas_admin_help/server/topics/introduction_to_the_tibco_spotfire_environment.html). 
- For more information on the Spotfire product family, see the [TIBCO Spotfire® Documentation](https://docs.tibco.com/products/tibco-spotfire/). 
- For latest specific component documentation, see [TIBCO® Enterprise Runtime for R - Server Edition Installation and Administration](https://docs.tibco.com/pub/terrsrv/latest/doc/html/TIB_terrsrv_install/terrinstall-homepage.html).
  You can access to documentation for other component versions and other formats in [TIBCO® Enterprise Runtime for R - Server Edition product documentation](https://docs.tibco.com/products/tibco-enterprise-runtime-for-r-server-edition)

## How to build this image

**Note**: The easiest and recommended way to build all the Spotfire container images is using the provided containers `Makefile` as described in [Build the images](../README.md#build-the-images).

You can also build this image individually.
Follow the instructions below or adjust them according to your needs.

Prerequisites:
- You have built the [spotfire-node-manager](../spotfire-node-manager/README.md) container image.

Steps:
1. Copy the `TerrServiceLinux.sdn` package into the `build/` directory within this folder.
2. From the `<this-repo>/containers` folder, run `make spotfire-terrservice` to build this image, or `make spotfire-terrservice --dry-run` to preview the required commands.

### Adding custom Spotfire package
At build time, put custom spk files in the `build/` folder.

## How to use this image

Prerequisites:
- A running [spotfire server](../spotfire-server/README.md) container instance to connect to.

### Start a TERR service container

You can start an instance of the **TIBCO Enterprise Runtime for R - Server Edition** container with:
```bash
docker run -d --rm -e SERVER_BACKEND_ADDRESS=spotfire-server tibco/spotfire-terrservice
```

The `spotfire-terrservice` will start with the default configuration from `/opt/tibco/tsnm/nm/services/TERRR/conf/custom.properties` in the container image.

### Starting with a custom configuration

You can also start the `spotfire-terrservice` with a custom configuration by providing a Spotfire services configuration file:
```bash
docker run -d --rm -e SERVER_BACKEND_ADDRESS=spotfire-server tibco/spotfire-terrservice \
  -v "$(pwd)/custom.properties:/opt/tibco/tsnm/nm/services/TERR/conf/custom.properties"
```

For more information, see [Configuring the TERR service](https://docs.tibco.com/pub/terrsrv/latest/doc/html/TIB_terrsrv_install/terrinstall/topics/configuring_the_terr_service.html). 

### Environment variables

- `TERR_RESTRICTED_EXECUTION_MODE` - See [Safeguarding your environment](https://docs.tibco.com/pub/terrsrv/latest/doc/html/TIB_terrsrv_install/terrinstall/topics/safeguarding_your_environment.html). Defaults to `TRUE`
- `ENGINE_DISABLE_TRUST_CHECKS` - See [Safeguarding your environment](https://docs.tibco.com/pub/terrsrv/latest/doc/html/TIB_terrsrv_install/terrinstall/topics/safeguarding_your_environment.html). Defaults to `FALSE`
- `MULTIPART_MAX_FILE_SIZE` - [File size upload limit](https://docs.tibco.com/pub/terrsrv/latest/doc/html/TIB_terrsrv_install/terrinstall/topics/file_size_limit_for_spring_multipart_file.html). Defaults to `100MB`
- `MULTIPART_MAX_REQUEST_SIZE` - [File size upload limit](https://docs.tibco.com/pub/terrsrv/latest/doc/html/TIB_terrsrv_install/terrinstall/topics/file_size_limit_for_spring_multipart_file.html). Defaults to `100MB`
- `MULTIPART_FILE_SIZE_THRESHOLD` - The amount of the upload held in memory . Defaults to `5MB`
- `ENGINE_EXECUTION_TIMEOUT_SECONDS` - See [Engine timeout](https://docs.tibco.com/pub/terrsrv/latest/doc/html/TIB_terrsrv_install/terrinstall/topics/engine_timeout.html). Defaults to `600`
- `ENGINE_SESSION_MAXTIME_SECONDS` - See [Engine timeout](https://docs.tibco.com/pub/terrsrv/latest/doc/html/TIB_terrsrv_install/terrinstall/topics/engine_timeout.html). Defaults to `1800`
- `ENGINE_PACKAGE_PATH` - See [Package library location](https://docs.tibco.com/pub/terrsrv/latest/doc/html/TIB_terrsrv_install/terrinstall/topics/package_library_location.html). Defaults to `/opt/packages`
- `ENGINE_DISABLE_JAVA_CORE_DUMPS` - See [disable.java.core.dump](https://docs.tibco.com/pub/terrsrv/latest/doc/html/TIB_terrsrv_install/terrinstall/topics/manage_java_options.html). Defaults to `TRUE`
- `ENGINE_JAVA_OPTIONS` - See [javaOptions](https://docs.tibco.com/pub/terrsrv/latest/doc/html/TIB_terrsrv_install/terrinstall/topics/manage_java_options.html).
- `LOGGING_SERVICELOG_MAX` - Maximum number of terr service log files to save. Defaults to `2`
- `LOGGING_SERVICELOG_SIZE` - Maximum size for terr service service log files. Defaults to `10MB`

**Note**: These environment variables can only be used if the default configuration is used.

**Note**: See also the Spotfire Node manager [environment variables](../spotfire-node-manager/README.md#environment-variables).

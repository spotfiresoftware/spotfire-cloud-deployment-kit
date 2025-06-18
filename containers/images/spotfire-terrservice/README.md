# spotfire-terrservice

## About this image

This directory contains the official container recipe for **[Spotfire® Enterprise Runtime for R - Server Edition](https://spotfi.re/docs/terrsrv/)**.

## What is Spotfire Enterprise Runtime for R (TERR) - Server Edition?

**Spotfire® Enterprise Runtime for R (a/k/a TERR)** is a high-performance, enterprise-quality statistical engine to provide predictive analytic capabilities.
TERR enables users to integrate and deploy advanced analytics written in the R language into their applications using an enterprise-quality R-compatible runtime environment.

**Spotfire® Enterprise Runtime for R - Server Edition (a/k/a the TERR service)**  provides remote execution of TERR data functions, TERR predictive analytics, or TERR custom expressions for users from web client and mobile devices.

**Note:** The _TERR service_ is a _Spotfire Server_ component, provided and licensed under _Spotfire Statistics Services_ in [Spotfire Product downloads](https://spotfi.re/download).

References:

- For a quick overview, see the [Introduction to the Spotfire environment](https://spotfi.re/docs/server/).
- For more information on the Spotfire product family, see the [Spotfire® Documentation](https://spotfi.re/docs/).
- For latest specific component documentation, see [Spotfire® Enterprise Runtime for R - Server Edition Installation and Administration](https://spotfi.re/docs/terrsrv/).
  You can access to documentation for other component versions and other formats in [Spotfire® Enterprise Runtime for R - Server Edition product documentation](https://docs.tibco.com/products/spotfire-enterprise-runtime-for-r-server-edition)

## How to build this image

The easiest and recommended way to build all the Spotfire container images is using the provided `containers/Makefile`. See [Spotfire Cloud Deployment Kit on GitHub](https://github.com/spotfiresoftware/spotfire-cloud-deployment-kit).

You can also build this image individually.
Follow the instructions below or adjust them according to your needs.

Prerequisites:

- You have built the [spotfire-nodemanager](../spotfire-nodemanager/README.md) container image.

Steps:

1. Copy the `Spotfire.Dxp.TerrServiceLinux.sdn` package into the `build/` directory within this folder.
2. From the `<this-repo>/containers` folder, run `make spotfire-terrservice` to build this image, or `make spotfire-terrservice --dry-run` to preview the required commands.

### Adding custom Spotfire packages

Before building the image, put any custom SPK files in the `build/` folder.

## How to use this image

Prerequisites:

- A running [spotfire server](../spotfire-server/README.md) container instance to connect to.

### Start a TERR service container

You can start an instance of the **Spotfire Enterprise Runtime for R - Server Edition** container with:
```bash
docker run -d --rm -e ACCEPT_EUA=Y \
  -e SERVER_BACKEND_ADDRESS=spotfire-server \
  spotfire/spotfire-terrservice
```

**Note:**  This Spotfire container image requires setting the environment variable `ACCEPT_EUA`.
By passing the value `Y` to the environment variable `ACCEPT_EUA`, you agree that your use of the Spotfire software running in this container will be governed by the terms of the [Cloud Software Group, Inc. End User Agreement](https://www.cloud.com/legal/terms).

The `spotfire-terrservice` will start with the default configuration from `/opt/spotfire/nodemanager/nm/services/TERRR/conf/custom.properties` in the container image.

### Starting with a custom configuration

To add [Custom configuration properties](https://docs.tibco.com/pub/terrsrv/latest/doc/html/TIB_terrsrv_install/_shared/install/topics/custom_configuration_properties.html) to the TERR service configuration, you can mount your custom configuration file at `/opt/spotfire/nodemanager/nm/services/TERR/conf/additional-custom.properties`.
This is needed only if a setting cannot be directly set by using any of the existing environment variable settings listed in the [Environment variables](#environment-variables) section.
Any setting here will override properties found in the `/opt/spotfire/nodemanager/nm/services/TERR/conf/custom.properties` file.

```bash
docker run -d --rm -e ACCEPT_EUA=Y \
  -e SERVER_BACKEND_ADDRESS=spotfire-server \
  -v "$(pwd)/additional-custom.properties:/opt/spotfire/nodemanager/nm/services/TERR/conf/additional-custom.properties" \
  spotfire/spotfire-terrservice
```

Example of an `additional-custom.properties` file:
```ini
# The maximum number of TERR engine sessions that are allowed to run concurrently in the TERR service.
engine.session.max: 5

# The number of TERR engines preallocated and available for new sessions in the TERR service queue.
engine.queue.size: 10
```

For more information, see [Configuring the service](https://docs.tibco.com/pub/terrsrv/latest/doc/html/TIB_terrsrv_install/_shared/install/topics/configuring_the_service.html).

### How to add additional R packages

You can prepare a shared folder with all the additional required R packages preinstalled.
For that, follow the instructions in [Installing R Packages Manually](https://docs.tibco.com/pub/terrsrv/latest/doc/html/TIB_terrsrv_install/_shared/install/topics/installing_r_packages_manually_.html).

You can then mount that shared folder in your containers and use it as your shared package library location.

Example:
```bash
docker run -d --rm -e ACCEPT_EUA=Y \
  -e SERVER_BACKEND_ADDRESS=spotfire-server \
  -v "$(pwd)/packages:/opt/packages" \
  spotfire/spotfire-terrservice
```

**Note:** The [shared package library location](https://docs.tibco.com/pub/terrsrv/latest/doc/html/TIB_terrsrv_install/_shared/install/topics/package_library_location.html) configuration property `packagePath` is set to `/opt/packages` in this container image.

### Environment variables

- `TERR_RESTRICTED_EXECUTION_MODE` - See [Safeguarding your environment](https://docs.tibco.com/pub/terrsrv/latest/doc/html/TIB_terrsrv_install/_shared/install/topics/safeguarding_your_environment.html). Defaults to `TRUE`
- `ENGINE_DISABLE_TRUST_CHECKS` - See [Safeguarding your environment](https://docs.tibco.com/pub/terrsrv/latest/doc/html/TIB_terrsrv_install/_shared/install/topics/safeguarding_your_environment.html). Defaults to `FALSE`
- `MULTIPART_MAX_FILE_SIZE` - [File size upload limit](https://docs.tibco.com/pub/terrsrv/latest/doc/html/TIB_terrsrv_install/_shared/install/topics/file_size_limit_for_spring_multipart_file.html). Defaults to `100MB`
- `MULTIPART_MAX_REQUEST_SIZE` - [File size upload limit](https://docs.tibco.com/pub/terrsrv/latest/doc/html/TIB_terrsrv_install/_shared/install/topics/file_size_limit_for_spring_multipart_file.html). Defaults to `100MB`
- `MULTIPART_FILE_SIZE_THRESHOLD` - The amount of the upload held in memory . Defaults to `5MB`
- `ENGINE_EXECUTION_TIMEOUT_SECONDS` - See [Engine timeout](https://docs.tibco.com/pub/terrsrv/latest/doc/html/TIB_terrsrv_install/_shared/install/topics/engine_timeout.html). Defaults to `600`
- `ENGINE_SESSION_MAXTIME_SECONDS` - See [Engine timeout](https://docs.tibco.com/pub/terrsrv/latest/doc/html/TIB_terrsrv_install/_shared/install/topics/engine_timeout.html). Defaults to `1800`
- `ENGINE_DISABLE_JAVA_CORE_DUMPS` - See [disable.java.core.dump](https://docs.tibco.com/pub/terrsrv/latest/doc/html/TIB_terrsrv_install/_shared/install/topics/manage_java_options.html). Defaults to `TRUE`
- `ENGINE_JAVA_OPTIONS` - See [javaOptions](https://docs.tibco.com/pub/terrsrv/latest/doc/html/TIB_terrsrv_install/_shared/install/topics/manage_java_options.html).
- `LOGGING_SERVICELOG_MAX` - Maximum number of TERR service log files to save. Defaults to `2`
- `LOGGING_SERVICELOG_SIZE` - Maximum size for TERR service log files. Defaults to `10MB`

**Note:** These environment variables can only be used if the default configuration is used.

**Note:** See also the Spotfire node manager [environment variables](../spotfire-nodemanager/README.md#environment-variables).

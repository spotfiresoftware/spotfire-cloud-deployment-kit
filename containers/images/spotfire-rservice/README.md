# spotfire-rservice

## About this image

This directory contains the official container recipe for **[Spotfire® Service for R](https://spotfi.re/docs/rsrv)**.

## What is Spotfire® Service for R?

**R** is a statistical engine to provide predictive analytic capabilities.
R enables users to integrate and deploy advanced analytics written in the R language into their applications.

**Spotfire® Service for R** (the R service) provides remote execution of R data functions, R predictive analytics, or R custom expressions for users from web client and mobile devices.

**Note:** The _Spotfire Service for R_ is a _Spotfire Server_ component, provided and licensed under _Spotfire Statistics Services_ in [Spotfire Product downloads](https://spotfi.re/download).

References:

- For a quick overview, see the [Introduction to the Spotfire environment](https://spotfi.re/docs/server). 
- For more information on the Spotfire product family, see the [Spotfire® Documentation](https://spotfi.re/docs). 
- For latest specific component documentation, see [Spotfire® Service for R Installation and Administration](https://spotfi.re/docs/rsrv).
  You can access to documentation for other component versions and other formats in [Spotfire® Service for R product documentation](https://docs.tibco.com/products/spotfire-service-for-r)

## How to build this image

The easiest and recommended way to build all the Spotfire container images is using the provided `containers/Makefile`. See [Spotfire Cloud Deployment Kit on GitHub](https://github.com/spotfiresoftware/spotfire-cloud-deployment-kit).

You can also build this image individually.
Follow the instructions below or adjust them according to your needs.

Prerequisites:

- You have built the [spotfire-nodemanager](../spotfire-nodemanager/README.md) container image.

Steps:

1. Copy the `Spotfire.Dxp.RServiceLinux.sdn` package into the `build/` directory within this folder.
2. From the `<this-repo>/containers` folder, run `make spotfire-rservice` to build this image, or `make spotfire-rservice --dry-run` to preview the required commands.

Before building the image, put any custom SPK files in the `build/` folder.

## How to use this image

Prerequisites:

- A running [spotfire server](../spotfire-server/README.md) container instance to connect to.

### Start an R service container

You can start an instance of the **Spotfire Service for R** container with:
```bash
docker run -d --rm -e ACCEPT_EUA=Y -e SERVER_BACKEND_ADDRESS=spotfire-server spotfire/spotfire-rservice
```

**Note:**  This Spotfire container image requires setting the environment variable `ACCEPT_EUA`.
By passing the value `Y` to the environment variable `ACCEPT_EUA`, you agree that your use of the Spotfire software running in this container will be governed by the terms of the [Cloud Software Group, Inc. End User Agreement](https://www.cloud.com/legal/terms).

The `spotfire-rservice` will start with the default configuration from `/opt/spotfire/nodemanager/nm/services/R/conf/custom.properties` in the container image.

### Starting with a custom configuration

To add [Custom configuration properties](https://docs.tibco.com/pub/sf-rsrv/latest/doc/html/TIB_sf-rsrv_install/_shared/install/topics/custom_configuration_properties.html) to the R service configuration, you can mount your custom configuration file at `/opt/spotfire/nodemanager/nm/services/R/conf/additional-custom.properties`.
This is only be needed if a setting cannot be directly set by using any of the existing environment variable settings listed in the [Environment variables](#environment-variables) section.
Any setting here will override properties found in the `/opt/spotfire/nodemanager/nm/services/R/conf/custom.properties` file.

```bash
docker run -d --rm -e ACCEPT_EUA=Y \
  -e SERVER_BACKEND_ADDRESS=spotfire-server \
  -v "$(pwd)/additional-custom.properties:/opt/spotfire/nodemanager/nm/services/R/conf/additional-custom.properties" \
  spotfire/spotfire-rservice
```

Example of an `additional-custom.properties` file:
```ini
# The maximum number of R engine sessions that are allowed to run concurrently in the R service.
engine.session.max: 5

# The number of R engines preallocated and available for new sessions in the R service queue.
engine.queue.size: 10
```

For more information, see [Configuring Spotfire Service for R](https://docs.tibco.com/pub/sf-rsrv/latest/doc/html/TIB_sf-rsrv_install/_shared/install/topics/configuring_the_service.html).

### Environment variables

- `ENGINE_DISABLE_TRUST_CHECKS` - See [Safeguarding your environment](https://docs.tibco.com/pub/sf-rsrv/latest/doc/html/TIB_sf-rsrv_install/_shared/install/topics/safeguarding_your_environment.html). Defaults to `FALSE`
- `MULTIPART_MAX_FILE_SIZE` - [File size upload limit](https://docs.tibco.com/pub/sf-rsrv/latest/doc/html/TIB_sf-rsrv_install/_shared/install/topics/file_size_limit_for_spring_multipart_file.html). Defaults to `100MB`
- `MULTIPART_MAX_REQUEST_SIZE` - [File size upload limit](https://docs.tibco.com/pub/sf-rsrv/latest/doc/html/TIB_sf-rsrv_install/_shared/install/topics/file_size_limit_for_spring_multipart_file.html). Defaults to `100MB`
- `MULTIPART_FILE_SIZE_THRESHOLD` - The amount of the upload held in memory . Defaults to `5MB`
- `ENGINE_EXECUTION_TIMEOUT_SECONDS` - See [Engine timeout](https://docs.tibco.com/pub/sf-rsrv/latest/doc/html/TIB_sf-rsrv_install/_shared/install/topics/engine_timeout.html). Defaults to `600`
- `ENGINE_SESSION_MAXTIME_SECONDS` - See [Engine timeout](https://docs.tibco.com/pub/sf-rsrv/latest/doc/html/TIB_sf-rsrv_install/_shared/install/topics/engine_timeout.html). Defaults to `1800`
- `ENGINE_DISABLE_JAVA_CORE_DUMPS` - See [disable.java.core.dump](https://docs.tibco.com/pub/sf-rsrv/latest/doc/html/TIB_sf-rsrv_install/_shared/install/topics/manage_java_options.html). Defaults to `TRUE`
- `ENGINE_JAVA_OPTIONS` - See [javaOptions](https://docs.tibco.com/pub/sf-rsrv/latest/doc/html/TIB_sf-rsrv_install/_shared/install/topics/manage_java_options.html).
- `LOGGING_SERVICELOG_MAX` - Maximum number of R service log files to save. Defaults to `2`
- `LOGGING_SERVICELOG_SIZE` - Maximum size for R service service log files. Defaults to `10MB`

**Note:** These environment variables can only be used if the default configuration is used.

**Note:** See also the Spotfire node manager [environment variables](../spotfire-nodemanager/README.md#environment-variables).

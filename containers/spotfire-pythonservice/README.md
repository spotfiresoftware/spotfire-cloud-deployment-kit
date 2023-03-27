# spotfire-pythonservice

## About This Image

This directory contains the official container recipe for **[TIBCO Spotfire® Service for Python](https://docs.tibco.com/pub/sf-pysrv/latest/doc/html/TIB_sf-pysrv_install/pyinstall/topics/the_tibco_spotfire_service_for_python.html)**.

## What is TIBCO Spotfire® Service for Python?

**TIBCO Spotfire® Service for Python** (aka Python service) provides remote execution of Python data functions for users from web client and mobile devices (TIBCO Spotfire® Business Author and Consumer).

**Note**: _TIBCO Spotfire Service for Python_ is provided as a _TIBCO Spotfire Statistics Services_ component in [TIBCO eDelivery](https://edelivery.tibco.com/storefront/index.ep).

References:
- For a quick overview, see the [Introduction to the TIBCO Spotfire environment](https://docs.tibco.com/pub/spotfire_server/latest/doc/html/TIB_sfire_server_tsas_admin_help/server/topics/introduction_to_the_tibco_spotfire_environment.html).
- For more information on the Spotfire product family, see the [TIBCO Spotfire® Documentation](https://docs.tibco.com/products/tibco-spotfire/).
- For latest specific component documentation, see [TIBCO Spotfire® Service for Python Installation and Administration](https://docs.tibco.com/pub/sf-pysrv/latest/doc/html/TIB_sf-pysrv_install/pyinstall-homepage.html).
You can access to documentation for other component versions and other formats in [TIBCO Spotfire® Service for Python product documentation](https://docs.tibco.com/products/tibco-spotfire-service-for-python)

## How to build this image

**Note**: The easiest and recommended way to build all the Spotfire container images is using the provided containers `Makefile` as described in [Build the images](../README.md#build-the-images).

You can also build this image individually.
Follow the instructions below or adjust them according to your needs.

Prerequisites:
- You have built the [spotfire-node-manager](../spotfire-node-manager/README.md) container image.

Steps:
1. Copy the `PythonServiceLinux.sdn` package into the `build/` directory within this folder.
2. From the `<this-repo>/containers` folder, run `make spotfire-pythonservice` to build this image, or `make spotfire-pythonservice --dry-run` to preview the required commands.

### Adding custom Spotfire packages
At build time, put custom spk files in the `build/` folder.

## How to use this image

Prerequisites:
- A running [spotfire server](../spotfire-server/README.md) container instance to connect to.

### Start a Python service container

You can start an instance of the **TIBCO Spotfire Service for Python** container with:
```bash
docker run -d --rm -e ACCEPT_EUA=Y -e SERVER_BACKEND_ADDRESS=spotfire-server tibco/spotfire-pythonservice
```

**Note**:  This TIBCO Spotfire container image requires setting the environment variable `ACCEPT_EUA`.
By passing the value `Y` to the environment variable `ACCEPT_EUA`, you agree that your use of the TIBCO Spotfire software running in this container will be governed by the terms of the [Cloud Software Group, Inc. End User Agreement](https://terms.tibco.com/#end-user-agreement).

The `spotfire-pythonservice` will start with the default configuration from `/opt/tibco/tsnm/nm/services/PYTHON/conf/custom.properties` in the container image.

### Starting with a custom configuration

To add [Custom configuration properties](https://docs.tibco.com/pub/sf-pysrv/latest/doc/html/TIB_sf-pysrv_install/_shared/install/topics/custom_configuration_properties.html) to the PYTHON service configuration an additional-custom.properties file can be mounted at /opt/tibco/tsnm/nm/services/PYTHON/conf/additional-custom.properties.  This would only be necessary if a setting could not be directly set using any of the environment variable settings as listed in the [Environment variables](#environment-variables) section. Any setting here will override properties found in the /opt/tibco/tsnm/nm/services/PYTHON/conf/custom.properties file.

```bash
docker run -d --rm -e ACCEPT_EUA=Y -e SERVER_BACKEND_ADDRESS=spotfire-server tibco/spotfire-pythonservice \
  -v "$(pwd)/additional-custom.properties:/opt/tibco/tsnm/nm/services/PYTHON/conf/additional-custom.properties"
```
Example additional-custom.properties file:
```
# The maximum number of Python engine sessions that are allowed to run concurrently in the Python service.
engine.session.max: 5

# The number of Python engines preallocated and available for new sessions in the Python service queue.
engine.queue.size: 10
```
-For more information, see [Configuring Spotfire Service for Python](https://docs.tibco.com/pub/sf-pysrv/latest/doc/html/TIB_sf-pysrv_install/_shared/install/topics/configuring_the_service.html).

### How to add additional Python packages

The [package library location](https://docs.tibco.com/pub/sf-pysrv/latest/doc/html/TIB_sf-pysrv_install/_shared/install/topics/package_library_location.html), or `packagePath`, is set to `/opt/packages` in this container image.

You can mount a folder from your container host to this location to add additional Python packages. The folder can be prepared by using the instructions described in [Installing Python Packages Manually](https://docs.tibco.com/pub/sf-pysrv/latest/doc/html/TIB_sf-pysrv_install/pyinstall/topics/installing_python_packages_manually.html).

```bash
# You can populate the packages folder with pip.
# - python -m pip install --target=$(pwd)/packages -r requirements.txt
# - python -m pip install --target=$(pwd)/packages pandas numpy ...
docker run -e ACCEPT_EUA=Y -d --rm -v "$(pwd)/packages:/opt/packages" -e SERVER_BACKEND_ADDRESS=spotfire-server tibco/spotfire-pythonservice
```

### Environment variables

- `ENGINE_DISABLE_TRUST_CHECKS` - See [Safeguarding your environment](https://docs.tibco.com/pub/sf-pysrv/latest/doc/html/TIB_sf-pysrv_install/_shared/install/topics/safeguarding_your_environment.html). Defaults to `FALSE`
- `MULTIPART_MAX_FILE_SIZE` - [File size upload limit](https://docs.tibco.com/pub/sf-pysrv/latest/doc/html/TIB_sf-pysrv_install/_shared/install/topics/file_size_limit_for_spring_multipart_file.html). Defaults to `100MB`
- `MULTIPART_MAX_REQUEST_SIZE` - [File size upload limit](https://docs.tibco.com/pub/sf-pysrv/latest/doc/html/TIB_sf-pysrv_install/_shared/install/topics/file_size_limit_for_spring_multipart_file.html). Defaults to `100MB`
- `MULTIPART_FILE_SIZE_THRESHOLD` - The amount of the upload held in memory . Defaults to `5MB`
- `ENGINE_EXECUTION_TIMEOUT_SECONDS` - See [Engine timeout](https://docs.tibco.com/pub/sf-pysrv/latest/doc/html/TIB_sf-pysrv_install/_shared/install/topics/engine_timeout.html). Defaults to `600`
- `ENGINE_SESSION_MAXTIME_SECONDS` - See [Engine timeout](https://docs.tibco.com/pub/sf-pysrv/latest/doc/html/TIB_sf-pysrv_install/_shared/install/topics/engine_timeout.html). Defaults to `1800`
- `ENGINE_DISABLE_JAVA_CORE_DUMPS` - See [disable.java.core.dump](https://docs.tibco.com/pub/sf-pysrv/latest/doc/html/TIB_sf-pysrv_install/_shared/install/topics/manage_java_options.html). Defaults to `TRUE`
- `ENGINE_JAVA_OPTIONS` - See [javaOptions](https://docs.tibco.com/pub/sf-pysrv/latest/doc/html/TIB_sf-pysrv_install/_shared/install/topics/manage_java_options.html)
- `LOGGING_SERVICELOG_MAX` - Maximum number of python service log files to save. Defaults to `2`
- `LOGGING_SERVICELOG_SIZE` - Maximum size for python service log files. Defaults to `10MB`

**Note**: These environment variables can only be used if the default configuration is used.

**Note**: See also the Spotfire Node manager [environment variables](../spotfire-node-manager/README.md#environment-variables).

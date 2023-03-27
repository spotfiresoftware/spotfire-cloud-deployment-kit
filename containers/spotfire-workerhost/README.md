# spotfire-workerhost

## About this Image

This directory contains the container recipe for the common software dependencies required by the **TIBCO Spotfire®** services using .NET.

Any additional libraries or software, e.g. odbc drivers, that is needed for certain components to work needs to be installed when building the container, see example file [install-odbc-driver.sh](scripts/install-odbc-drivers.sh)

**Note**:  This TIBCO Spotfire container image requires setting the environment variable `ACCEPT_EUA`.
By passing the value `Y` to the environment variable `ACCEPT_EUA`, you agree that your use of the TIBCO Spotfire software running in this container will be governed by the terms of the [Cloud Software Group, Inc. End User Agreement](https://terms.tibco.com/#end-user-agreement).

## How to build this image

**Note**: The easiest and recommended way to build all the Spotfire container images is using the provided containers `Makefile` as described in [Build the images](../README.md#build-the-images).

You can also build this image individually.
Follow the instructions below or adjust them according to your needs.

Prerequisites:
- You have built the [spotfire-node-manager](../spotfire-node-manager/README.md) container image.

Steps:
- From the `<this-repo>/containers` folder, run `make spotfire-workerhost` to build this image, or `make spotfire-workerhost --dry-run` to preview the required commands.

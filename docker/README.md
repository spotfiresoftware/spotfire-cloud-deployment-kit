# Spotfire container images

## Overview

This directory contains the recipes to build and examples to use the [**TIBCO Spotfire® Platform**](https://www.tibco.com/products/tibco-spotfire) container images:

- [spotfire-server](spotfire-server/README.md): TIBCO Spotfire Server container.
- [spotfire-config](spotfire-config/README.md): TIBCO Spotfire configuration tool (CLI) container.
- [spotfire-node-manager](spotfire-node-manager/README.md): TIBCO Spotfire node manager container.
- [spotfire-pythonservice](spotfire-pythonservice/README.md): TIBCO Spotfire Service for Python container.
- [spotfire-terrservice](spotfire-terrservice/README.md): TIBCO Enterprise Runtime for R - Server Edition container.

See the respective README files for details and usage examples.

**Note**: There are other recipes in this directory not listed here.
They are used internally for better layer reusability, and they include common software requirements and functions.

**Note**: You can build each image on its own as described in their respective READMEs or use the provided `Makefile` within this directory to build all the images with just one single command (this `Makefile` also takes care of their internal dependencies).

## Prerequisites

- Required **TIBCO Spotfire** installation packages. You can download them from [TIBCO eDelivery](https://edelivery.tibco.com/storefront/index.ep):
    - TIBCO Spotfire Server: Linux tar.gz package:
      - `tss-<version>.x86_64.tar.gz`
    - TIBCO Spotfire node manager: Linux tar.gz package:
      - `tsnm-<version>.x86_64.tar.gz`
    - TIBCO Spotfire distribution files (the distribution files may contain packages for clients, services or customizations):
      - `Spotfire.Dxp.sdn`
      - `Spotfire.Dxp.TerrServiceLinux.sdn`
      - `Spotfire.Dxp.PythonServiceLinux.sdn`
- A **Linux host** with admin permissions to build and execute the containers.
   You can use a bare metal installed server, a virtual machine or WSL on Windows.
- An [OCI-compliant](https://opencontainers.org/) container image building tool (for example, `docker`, `podman`, `buildah` or alternative), for building the container images.

**Note**: TIBCO Spotfire® is a commercial product. You must have a valid license for each of the TIBCO Spotfire components you choose to build and run as containers.

**Note**: You may not require all listed `.sdn` files, depending on the services you want to deploy.

**Note**: This guide provides some examples using commands that are Debian/Ubuntu specific. 
You can use equivalent commands for your favorite GNU/Linux distribution.

## Build the images

1. Copy the files listed in [Prerequisites](#prerequisites) into the `<this-repo>/docker/downloads` directory.

2. From the `<this-repo>/docker` directory, build the container images:
    ```bash
    make build
    ```

**Note**: The provided `Makefile` takes care of building the images taking care of the dependencies.
You can build each of the containers images separately if you want. 
You can find details on how to build each container image in their respective READMEs.

**Note**: You may not require all listed sdn files, or you may want to add your custom sdn file(s).
In that case, edit the `Makefile` commenting out or adding the required entries.

### Push the images to a container registry

After building the container images, you can push them to a container registry to make them available to the deployment tools (e.g. Helm).

For example, to push the images to your container registry in 127.0.0.1:32000:
```bash
make REGISTRY=127.0.0.1:32000 push
```

**Note**: See the provided `Makefile` for more details.

**Note**: You are responsible for ensuring that your use of the container image complies with your license for the TIBCO product(s) contained in the image, including any limitations that prevent you from publishing the image for use by others, whether internally or externally.

### Customizing and extending the images

These recipes provide a standard, canonical, typical or vanilla deployment for the TIBCO Spotfire® Platform.
They are suitable for most of the use case scenarios. 

You are welcome to modify the recipes and adapt them to your specific use case, in compliance with the Apache License 2.0. 
If you do so, however, we recommend that you proceed by extending these images. 
In other words, we suggest creating your recipes that use these official container images as base layer (using `FROM tibco/<image-name>:<image-tag>`) rather than modifying these official recipes.
This will make it easier for you to update your images when new official recipes are released.

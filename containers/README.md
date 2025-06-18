# Spotfire container images

## Overview

This directory contains the recipes to build and examples to use the [**Spotfire® Platform**](https://www.spotfire.com/) container images. See the respective README files for details and usage examples.

**Note**: You can build each image on its own as described in their respective READMEs, or you can use the provided `Makefile` within this directory to build all the images with just one single command (this `Makefile` also takes care of their internal dependencies).

## Prerequisites

- [Required **Spotfire** installation packages](build-files.mk). You can download them from the [Spotfire Download site](https://www.spotfire.com/downloads).
- A **Linux host** with admin permissions to build and execute the containers.
  You can use a bare metal installed server, a virtual machine, or WSL on Windows.
- An [OCI-compliant](https://opencontainers.org/) container image building tool (for example, `docker`, `podman` or alternative), for building the container images.

**Note**: Spotfire® is a commercial product. You must have a valid license for each of the Spotfire components you choose to build and run as containers.

## Build the images

1. Copy the required files into the `<this-repo>/containers/downloads` directory.

   See [build-files.mk](build-files.mk) for a list of files needed to build the images or run `make downloads-list` to list them.

2. From the `<this-repo>/containers` directory, build the container images:
    ```bash
    make build
    ```

The provided `Makefile` builds all the container images taking care of the building dependencies.
You can build each of the containers images separately if you want.
You can find details on how to build each container image in their respective READMEs.

### Push the images to a container registry

After building the container images, you can push them to a container registry to make them available to the deployment tools (e.g. Helm).

For example, to push the images to your container registry in 127.0.0.1:32000:
```bash
make CONTAINER_REGISTRY=127.0.0.1:32000 push
```

**Note**: You are responsible for ensuring that your use of the container image complies with your license for the Spotfire product(s) contained in the image, including any limitations that prevent you from publishing the image for use by others, whether internally or externally.

### Customizing and extending the images

The provided recipes offer a standard deployment for the Spotfire® Platform, suitable for most scenarios. It is recommended to extend the images rather than modify them directly. To extend, create new recipes using the official container images as the base layer (using `FROM spotfire/<image-name>:<image-tag>`). This approach simplifies updates when new official recipes are released.

Generally, it is recommended to use the default application versions provided in the Cloud Deployment Kit (CDK) for Spotfire®. However, in some cases, you may need to build container images with different application versions. To do this, update the application version in [versions.mk](../versions.mk) (e.g., `SPOTFIRE_SERVER_VERSION=12.0.1`), place the corresponding application files in the `containers/downloads` directory, and build the new containers using the `make` command from the `containers/` directory.

```bash
make IMAGE_BUILD_ID=my-custom-image-0.1
```

This command appends `-my-custom-image-0.1` to the default tags, formatted as `<application_version>-v<cloud_deployment_kit_version>-my-custom-image-0.1`.

**Note**: Building with non-default application versions can be problematic because the CDK has not been developed with these versions in mind, and it might not work as expected. Thorough testing is recommended to ensure compatibility.

When using customized or extended container images with Helm charts, ensure to override the `image.tag` during the Helm chart installation to match your custom image tag.

### Licenses

After building the container images, you can view or export the Spotfire license files that contain information about licenses for the contained software. The following example finds the license files contained within a spotfire image.
```bash
# Set up the spotfire image name and tag.
SPOTFIRE_IMAGE=<image-name:image-tag>
id=$(docker create spotfire/$SPOTFIRE_IMAGE)
docker export $id | tar xvf - --wildcards "opt/spotfire/*.pdf"
docker rm $id
# The 'license files' will be extracted under the $(pwd)/opt/spotfire folder
```

See [here](../README.md#licenses) for more information on the applicable licenses for this project (_Cloud Deployment Kit for Spotfire_) and for the software included in the built container images.

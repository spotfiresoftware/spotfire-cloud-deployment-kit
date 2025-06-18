# spotfire-deployment

## About this image

This directory contains the official container recipe for the **Spotfire® deployment package**.

This container stores the client deployment file `Spotfire.Dxp.sdn` in `/opt/spotfire/deployment-files/`.
This way, it can be used as an init-container configuration job to create and populate a Spotfire deployment area.

## How to build this image

The easiest and recommended way to build all the Spotfire container images is using the provided `containers/Makefile`. See [Spotfire Cloud Deployment Kit on GitHub](https://github.com/spotfiresoftware/spotfire-cloud-deployment-kit).

You can also build this image individually.
Follow the instructions below or adjust them according to your needs.

Steps:

- From the `<this-repo>/containers` folder, run `make spotfire-deployment` to build this image, or `make spotfire-deployment --dry-run` to preview the required commands.

# spotfire-base

## About this image

This directory contains the common base layer for **Spotfire®** official container recipes.

## How to build this image

The easiest and recommended way to build all the Spotfire container images is using the provided `containers/Makefile`. See [Spotfire Cloud Deployment Kit on GitHub](https://github.com/spotfiresoftware/spotfire-cloud-deployment-kit).

You can also build this image individually.
Follow the instructions below or adjust them according to your needs.

Steps:

- From the `<this-repo>/containers` folder, run `make spotfire-base` to build this image, or `make spotfire-base --dry-run` to preview the required commands.

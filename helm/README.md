# Spotfire helm charts

## Overview

This directory contains the recipes to build and examples to use the [**TIBCO Spotfire® Platform**](https://www.tibco.com/products/tibco-spotfire) helm charts:

- [spotfire-server](charts/spotfire-server/README.md): TIBCO Spotfire Server helm chart.
- [spotfire-pythonservice](charts/spotfire-pythonservice/README.md): TIBCO Spotfire Service for Python helm chart.
- [spotfire-terrservice](charts/spotfire-terrservice/README.md): TIBCO Enterprise Runtime for R - Server Edition helm chart.

See the respective README files for details and usage examples.

**Note**: There are other recipes in the `charts` directory not listed here.
They are used internally for better templates reusability, and they include common software requirements and functions.

**Note**: You can build each chart on its own as described in their respective READMEs or use the provided `Makefile` within this directory to build all the charts with just one single command (this  `Makefile` also takes care of their internal dependencies).

## Prerequisites

- You have built the [Spotfire container images](../docker/README.md) or have configured a container repository hosting those container images.
- Kubernetes 1.23+, a working kubernetes cluster from a ([certified k8s distro](https://www.cncf.io/certification/software-conformance/)).
- Helm 3+, for building and deploying the charts.

## Build the charts

You can simply run `make` from the helm directory to package all the charts within this directory.
The included `Makefile` builds each of the charts taking care of any dependencies.

```bash
make
```

**Note**: The built charts are saved into the directory: `<this-repo>/helm/packages`.

### Alternative: build charts one by one

You can also package the provided charts one by one, following these steps from each of the provided charts directories:

1. Enter into the chart directory. For example:
    ```bash
    cd <this-repo>/helm/chart/<spotfire-chart>
    ```

2. Update the chart dependencies:
    ```bash
    helm dependency update .
    ```

3. Package the chart:
    ```bash
    helm package . -d <helm-charts-destination-path>
    ```

Repeat for all the charts.

**Note**: The helm chart packages have dependencies, you may need to check the provided `Makefile` for more details.

### Customizing and extending the charts

These recipes provide a standard, canonical, typical or vanilla deployment for the TIBCO Spotfire® Platform.
They are suitable for most of the use case scenarios.

You are welcome to modify the recipes and adapt them to your specific use case, in compliance with the Apache License 2.0.
If you do so, however, we recommend that you proceed by extending these charts.
In other words, creating your charts that import these official charts rather than modifying these official recipes.
This way it will be much easier for you to update your charts when new official recipes are released.

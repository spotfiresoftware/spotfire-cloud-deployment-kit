# Spotfire helm charts

## Overview


This directory contains the recipes to build and examples to use the [**Spotfire®**](https://www.spotfire.com/) Helm charts:

- [spotfire-server](charts/spotfire-server/README.md): Spotfire Server helm chart.
- [spotfire-webplayer](charts/spotfire-webplayer/README.md): Spotfire Web Player helm chart.
- [spotfire-automationservices](charts/spotfire-automationservices/README.md): Spotfire Automation Services helm chart.
- [spotfire-rservice](charts/spotfire-rservice/README.md): Spotfire Service for R helm chart.
- [spotfire-pythonservice](charts/spotfire-pythonservice/README.md): Spotfire Service for Python helm chart.
- [spotfire-terrservice](charts/spotfire-terrservice/README.md): Spotfire Enterprise Runtime for R - Server Edition helm chart.

See the respective README files for details and usage examples.

**Note**: There are other recipes in the `charts` directory not listed here. They are used internally for better template reusability, and they include common software requirements and functions.

## Prerequisites

- You have built the [Spotfire container images](../containers/README.md) or have configured a container repository hosting those container images.
- Kubernetes 1.24+, a working kubernetes cluster from a ([certified k8s distro](https://www.cncf.io/certification/software-conformance/)).
- Helm 3+, for building and deploying the charts.

## Building the charts

You can build each chart on its own as described in the respective READMEs, or you can use the provided `Makefile` within this directory to build all the charts with just one single command. (This `Makefile` also takes care of their internal dependencies.)

To package all the charts in this directory, run `make` from the helm directory.
The included `Makefile` builds each of the charts, taking care of any dependencies.

```bash
make
```

**Note**: The built charts are saved into the directory `<this-repo>/helm/packages`.

### Alternative: Building the charts one by one

You can package the provided charts, one by one, by following these steps from each of the provided charts directories:

1. Go to the chart directory. For example:
    ```bash
    cd <this-repo>/helm/charts/<spotfire-chart>
    ```

2. Update the chart dependencies:
    ```bash
    helm dependency update .
    ```

3. Package the chart:
    ```bash
    helm package . -d <helm-charts-destination-path>
    ```

Repeat for each of the charts.

**Note**: The helm chart packages have dependencies; check the provided `Makefile` for more details.

### Customize and extend the charts

These recipes provide a standard, canonical, typical, or vanilla deployment for the Spotfire® Platform.
They are suitable for most of the use case scenarios.

You are welcome to use and modify the recipes and adapt them to your specific use case, in compliance with the Apache License 2.0.
However, we recommend that you extend these charts, rather than modify them.
To extend the charts, create charts that import these official charts.
This way, it is easier for you to update your charts when new official recipes are released.

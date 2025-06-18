# Using pre-built Spotfire artifacts from the OCI Registry

The Spotfire container images and Helm charts are hosted on the Spotfire OCI registry at `oci.spotfire.com`.

The Spotfire OCI registry is an [OCI (Open Container Initiative)](https://opencontainers.org/) compliant registry.
An OCI registry is a service that stores and distributes container images and other OCI artifacts.
It follows the [OCI Distribution Specification](https://github.com/opencontainers/distribution-spec), which defines a standard API for container image distribution.
This allows users to push, pull, and manage container images and Helm charts in a consistent and interoperable manner across different platforms and tools.

This guide is for users who want to utilize pre-built Spotfire container images and Helm charts provided by Spotfire. If you prefer to build your own images or charts, or modify the existing ones, refer to the [Spotfire Cloud Deployment Kit](https://github.com/spotfiresoftware/spotfire-cloud-deployment-kit/) on GitHub. 

## Accessing the Spotfire OCI Registry

To request access to the Spotfire OCI registry, follow these steps:

1. Open a support case via the [Support Portal](https://support.tibco.com/) stating that you want access to the Spotfire OCI registry. Make sure you select "_Spotfire Server_" as the Product when creating the case.
2. Support will provide you with the necessary access credentials along with any additional instructions.

With these credentials, you can pull container images and charts from the Spotfire OCI registry.
Set the username and password provided by support in your shell using the following commands:

```bash
REGISTRY_USERNAME=<your_username>
REGISTRY_PASSWORD=<your_password_or_token>
```

To log in to the registry for Helm charts, use the following command:
```bash
helm registry login -u $REGISTRY_USERNAME oci.spotfire.com/charts
```

To log in to the registry for container images, use the following command:
```bash
docker login -u $REGISTRY_USERNAME oci.spotfire.com/images
```

Now you are ready to install Spotfire directly from the OCI registry. Refer to [Deploying Spotfire on Kubernetes](deploy-anywhere.md) after you have logged in.

## Using the Spotfire OCI Registry

To pull Spotfire container images and Helm charts from the Spotfire OCI registry, follow the procedures below. You can also push them to your private registry, if preferred.

This guide uses `curl` to list available images and charts via the standard [Registry HTTP API](https://distribution.github.io/distribution/spec/api/), but other tools can also be used. Additionally, you can visit the [Spotfire Cloud Deployment Kit releases page](https://github.com/spotfiresoftware/spotfire-cloud-deployment-kit/releases) on GitHub to view available images and tags.

### Helm charts

To list available Helm charts in the Spotfire OCI registry, use the following `curl` commands:

List charts in the registry:
```bash
curl --user $REGISTRY_USERNAME:$REGISTRY_PASSWORD https://oci.spotfire.com/v2/charts/_catalog
```

List versions for a specific chart:
```bash
curl --user $REGISTRY_USERNAME:$REGISTRY_PASSWORD https://oci.spotfire.com/v2/charts/spotfire-server/tags/list
```

To pull the Spotfire server chart with a specific version, use the following command:
```bash
helm pull oci://oci.spotfire.com/charts/spotfire-server --version {{ SPOTFIRE_SERVER_CHART_VERSION }}
```

To transfer Helm charts to your private registry, use the following commands:
```bash
helm pull oci://oci.spotfire.com/charts/spotfire-server --version {{ SPOTFIRE_SERVER_CHART_VERSION }}
helm push spotfire-server-<version>.tgz  <your-chart-registry>/spotfire/spotfire-server
```

Repeat the above steps for each Spotfire Helm chart.

### Container images

To list available images and charts in the Spotfire OCI registry, use the following `curl` commands:

List images in the registry:
```bash
curl --user $REGISTRY_USERNAME:$REGISTRY_PASSWORD https://oci.spotfire.com/v2/spotfire/_catalog
```

List tags for a specific image:
```bash
curl --user $REGISTRY_USERNAME:$REGISTRY_PASSWORD https://oci.spotfire.com/v2/spotfire/spotfire-server/tags/list
```

To pull a container image, log in to the registry and pull the desired image:
```bash
docker pull oci.spotfire.com/<image>:<tag>
```

For example, to pull the Spotfire server image with tag `{{ SPOTFIRE_SERVER_IMAGE_TAG }}`:
```bash
docker pull oci.spotfire.com/spotfire/spotfire-server:{{ SPOTFIRE_SERVER_IMAGE_TAG }}
```

To transfer images to your private registry, use the following commands for each image:

```bash
docker pull oci.spotfire.com/spotfire/spotfire-server:{{ SPOTFIRE_SERVER_IMAGE_TAG }}
docker tag oci.spotfire.com/spotfire/spotfire-server:{{ SPOTFIRE_SERVER_IMAGE_TAG }} <your-container-registry>/spotfire/spotfire-server:{{ SPOTFIRE_SERVER_IMAGE_TAG }}
docker push <your-container-registry>/spotfire/spotfire-server:{{ SPOTFIRE_SERVER_IMAGE_TAG }}
```

**Note:** The `spotfire-server` is used as an example. Replace it with the actual image name and tag you intend to use.
# Deploying Spotfire on Kubernetes

This guide provides step-by-step instructions for deploying Spotfire on a Kubernetes cluster using container images and Helm charts from the [Spotfire container registry](spotfire-oci-registry.md). 

The Spotfire OCI registry is an [OCI (Open Container Initiative)](https://opencontainers.org/) compliant registry.
To know how to use the Spotfire OCI registry and get access credentials, see [using the Spotfire OCI registry](spotfire-oci-registry.md).

By the end of this guide, you will have a functional Spotfire environment running in your Kubernetes cluster.
You will deploy the [spotfire-platform](../helm/charts/spotfire-platform/README.md) Helm chart, an umbrella chart that includes all other Spotfire charts/components.
From this chart, Spotfire services can be optionally enabled or disabled as needed.

There are also specific quick-start guides for various cloud platforms to help you get started with any of those platforms:

- [AWS](../examples/aws/aws-eks.md)
- [Azure](../examples/azure/azure-aks.md)
- [Google Cloud Platform](../examples/google/google-gke.md)

## Prerequisites

- Valid credentials to access the [Spotfire OCI registry](spotfire-oci-registry.md).
- A working Kubernetes cluster from a [certified K8s distribution](https://www.cncf.io/certification/software-conformance/) (version >= {{ MIN_KUBERNETES_VERSION }}).
- [`kubectl`](https://kubernetes.io/docs/tasks/tools/) installed and configured.
- [`Helm 3+`](https://helm.sh/docs/intro/install/) installed.

## Deploying Spotfire in a Kubernetes cluster

To deploy Spotfire in a Kubernetes cluster, follow these steps in a terminal:

1. Set your Spotfire OCI registry credentials:
    ```bash
    export REGISTRY_USERNAME=<username>
    export REGISTRY_PASSWORD=<password>
    ```

2. Create a namespace for your deployment:
    ```bash
    kubectl create namespace spotfire
    ```

3. Create a pull secret for the Spotfire container registry:
    ```bash
    kubectl create secret docker-registry spotfire-registry-secret \
        --namespace spotfire \
        --docker-server=oci.spotfire.com
        --docker-username=$REGISTRY_USERNAME \
        --docker-password=$REGISTRY_PASSWORD \
    ```

    The secret allows the Kubernetes cluster to pull Spotfire container images from the Spotfire OCI registry.

4. Log in to the Spotfire Helm charts registry:
    ```bash
    helm registry login -u $REGISTRY_USERNAME -p $REGISTRY_PASSWORD oci.spotfire.com/charts
    ```

    This step is necessary to access the Spotfire Helm charts in the Spotfire OCI registry.

5. Deploy the Spotfire Platform using the `spotfire-platform` Helm chart.
    For example:
    ```bash
    helm upgrade --install spotfire-platform \
        oci://oci.spotfire.com/charts/spotfire-platform \
        --version "{{ SPOTFIRE_PLATFORM_CHART_VERSION }}"
        --namespace spotfire \
        --set global.spotfire.acceptEUA=true \
        --set global.spotfire.image.registry=oci.spotfire.com \
        --set global.spotfire.image.pullSecrets[0]="spotfire-registry-secret" \
        --set postgresql.enabled=true \
        --set spotfire-webplayer.enabled=false \
        --set spotfire-automationservices.enabled=false \
        --set spotfire-pythonservice.enabled=false \
        --set spotfire-rservice.enabled=false \
        --set spotfire-terrservice.enabled=false \
        --set spotfire-server.configuration.site.publicAddress=http://spotfire.example.com \
    ```

    **Note**: Setting `postgresql.enabled=true` will enable the embedded PostgreSQL database, which is intended for testing and demo purposes only. For production, use a dedicated database.

Points to note:
  - Ensure you are installing a recent version of the chart by checking the [Spotfire OCI registry](spotfire-oci-registry.md) or the [Spotfire Cloud Deployment Kit releases page](https://github.com/spotfiresoftware/spotfire-cloud-deployment-kit/releases).
  - The `global.spotfire.acceptEUA` value is set to `true` to accept the [Cloud Software Group, Inc. End User Agreement](https://www.cloud.com/legal/terms).
  - The `global.spotfire.image.registry` value is set to the Spotfire OCI registry.
  - The `global.spotfire.image.pullSecrets` value is set to the pull secret created in step 3.
  - By default, the `spotfire-platform` chart deploys only the `spotfire-server`. You can enable the deployment of other Spotfire services as needed.
  - **Important**: The `postgresql.enabled` value is set to `true` to use the included PostgreSQL Helm chart for testing purposes. For production, use a dedicated database server, or make sure you understand how to configure a containerized PostgreSQL deployment for production.

For more configuration details, refer to the [Spotfire charts documentation](../helm/charts/spotfire-platform/README.md).

# Deploying Spotfire on Google Kubernetes Engine (GKE)

This page provides an overview of the main steps needed to prepare an environment in Google Cloud,
and to deploy the [Spotfire Platform](https://www.spotfire.com/) on [Google Kubernetes Engine (GKE)](https://cloud.google.com/kubernetes-engine),
using the [Spotfire CDK](https://github.com/spotfiresoftware/spotfire-cloud-deployment-kit).

You will deploy the Spotfire Platform on Google Cloud Platform (GCP) using the following services: 
- Kubernetes cluster: [Google Kubernetes Engine (GKE)](https://cloud.google.com/kubernetes-engine)
- Database server: [Google SQL PostgreSQL](https://cloud.google.com/sql/docs/postgres/introduction)
- Blob storage: [Google Cloud Storage](https://cloud.google.com/storage)
- Load balancer: [Google Cloud Load Balancing](https://cloud.google.com/load-balancing)

This is a quickstart guide.
For more information, see the official documentation.
Always follow the documentation and recommended best practices from the vendor.

Remember to change the provided example values to adapt them to your own environment and needs.

## Prerequisites

- An account in Google Cloud Platform with permissions for the required services
- A Linux host with the following clients installed:
    - [gcloud cli](https://cloud.google.com/sdk/docs/install-sdk).
    - [Kubectl](https://kubernetes.io/docs/tasks/tools/).
    - [Helm 3+](https://helm.sh/docs/intro/install/).

**Note:** The Google Cloud CLI (`gcloud`) is used in the examples below, but you can use the Google Cloud web interface, REST API, libraries or any other available methods.

## Steps

### 1. Prepare your GCP environment

- Login to your GCP account and set up your project.
    ```bash
    gcloud auth login
    export PROJECT_ID=<my-project-name>
    export LOCATION=europe-north1
    gcloud config set project $PROJECT_ID
    ```

### 2. Create a Google Kubernetes Engine (GKE) cluster

1. Define the variables for your cluster:
    ```bash
    export CLUSTER_NAME=my-gke
    export MACHINE_TYPE=n2-standard-8 # 8 vCPUs, 32 GB RAM
    export NODE_COUNT=1
    ```

    **Note:** In this example we create a 3-nodes cluster using the `n2-standard-8` virtual machine type (8 vCPUs, 32 GB).
    See the [Machine families resource and comparison guide](https://cloud.google.com/compute/docs/machine-resource) to understand which SKU you need for your K8s nodes.
    The Google Cloud N-Family of machines are general purpose VMs for Enterprise-grade containerized applications.

    **Note:** See the [Spotfire system requirements](https://spotfi.re/sr) for the minimum and recommended sizing.
    Observe your K8s resource utilization to understand which node size and how many nodes do you need.

2. Create the Google Kubernetes Engine (GKE):
    ```bash
    gcloud container clusters create $CLUSTER_NAME \
        --preemptible \
        --num-nodes=$NODE_COUNT \
        --location $LOCATION \
        --machine-type=$MACHINE_TYPE
    ```

    The `--num-nodes` specifies how many nodes will be created in each zone, such that if you specify `--num-nodes=4` and choose 2 locations, then 8 nodes will be created.
    By default, GKE uses 3 zones, so with `--num-nodes=1` it will create 3 nodes in total.

    In this example we create a regional cluster, in which the control plane is replicated across multiple zones in a region.
    Make sure you understand the difference between a [regional cluster](https://cloud.google.com/kubernetes-engine/docs/how-to/creating-a-regional-cluster) and a [zonal cluster](https://cloud.google.com/kubernetes-engine/docs/how-to/creating-a-zonal-cluster).

    **Note:** To minimize your cloud bill, this command is using preemptible nodes, which are cheaper than a normal virtual machine. This is useful for testing purposes.

    It will take ~5-10 minutes to create the K8s cluster.

    For more information, see [gcloud container clusters create](https://cloud.google.com/sdk/gcloud/reference/container/clusters/create).

3. Set up the Google Kubernetes Engine auth plugin and configure `kubectl` to use the new GKE cluster:
    ```bash
    gcloud components install gke-gcloud-auth-plugin
    export USE_GKE_GCLOUD_AUTH_PLUGIN=True
    gcloud container clusters get-credentials $CLUSTER_NAME --location $LOCATION
    ```

4. Verify that you can connect to the cluster using `kubectl`:
    ```bash
    kubectl get nodes -o wide
    ```

For more information, see [GKE documentation](https://cloud.google.com/kubernetes-engine/docs/concepts/kubernetes-engine-overview), [Learn GKE fundamentals](https://cloud.google.com/kubernetes-engine/docs/learn), or learn about best practices in [Best practices for GKE networking](https://cloud.google.com/kubernetes-engine/docs/best-practices/networking).


### 3. Deploy Spotfire

1. Create a namespace for your deployment:
    ```bash
    export NAMESPACE=spotfire-quickstart
    kubectl create namespace $NAMESPACE
    ```

2. Create a pull secret for the Spotfire container registry:
    ```bash
    export REGISTRY_SERVER=oci.spotfire.com
    export REGISTRY_SECRET=spotfire-oci-secret
    export REGISTRY_USERNAME=<username>
    export REGISTRY_PASSWORD=<password>

    kubectl create secret docker-registry $REGISTRY_SECRET \
        --namespace $NAMESPACE \
        --docker-server=$REGISTRY_SERVER \
        --docker-username=$REGISTRY_USERNAME \
        --docker-password=$REGISTRY_PASSWORD
    ```
    The secret is used by the Kubernetes cluster to pull the Spotfire container images from the Spotfire OCI registry.

3. Log in to the Spotfire Helm charts registry:
    ```bash
    helm registry login -u $REGISTRY_USERNAME oci.spotfire.com/charts
    ```
    This is needed to access the Spotfire Helm charts in the Spotfire OCI registry.

4. Deploy the Spotfire Platform using the `spotfire-platform` Helm chart.
    For example:
    ```bash
    export MY_SPOTFIRE_RELEASE=vanilla-spotfire

    helm upgrade --install $MY_SPOTFIRE_RELEASE \
        oci://$REGISTRY_SERVER/charts/spotfire-platform \
        --version 2.0.0 \
        --namespace=$NAMESPACE \
        --set global.spotfire.acceptEUA=true \
        --set global.spotfire.image.registry=$REGISTRY_SERVER \
        --set global.spotfire.image.pullSecrets[0]=$REGISTRY_SECRET \
        --set spotfire-server.configuration.site.publicAddress=http://spotfire.example.com \
        --set spotfire-server.postgresql.enabled=true \
        ...
    ```
    For more information, see the [spotfire-platform Helm chart](../../helm/charts/spotfire-platform/README.md).

You have now deployed the Spotfire platform on Google Cloud,
using Google Kubernetes Engine (GKE).

### 4. Next steps

You can now continue with:
- [Configuring a Google Network Load Balancer or a Google Application Load Balancer](google-gce-ingress.md).
- [Configuring a Google Cloud SQL for PostgreSQL database as the Spotfire database](google-cloud-sql-postgres.md).
- [Configuring a Google Cloud Storage bucket as the Spotfire external library storage](google-cloud-storage.md).

## Cleanup

To avoid unneeded resource usage, once you have completed these tutorials, delete any created resources:
```bash
gcloud container clusters delete $CLUSTER_NAME --location $LOCATION
...
```
For more information, see [Delete a GKE cluster](https://cloud.google.com/sdk/gcloud/reference/container/clusters/delete).

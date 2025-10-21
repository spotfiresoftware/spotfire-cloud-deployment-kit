# Deploying Spotfire on Azure Kubernetes Service (AKS)

This page provides an overview of the main steps needed to prepare an environment in Azure and to deploy the [Spotfire Platform](https://www.spotfire.com/) on [Azure Kubernetes Service (AKS)](https://azure.microsoft.com/en-us/products/kubernetes-service),
using the [Spotfire CDK](https://github.com/spotfiresoftware/spotfire-cloud-deployment-kit).

You will deploy the Spotfire Platform on Azure using the following services:
- Kubernetes cluster: [Azure Kubernetes Service (AKS)](https://azure.microsoft.com/en-us/products/kubernetes-service/).
- Database server: [Azure Database for PostgreSQL](https://azure.microsoft.com/en-us/products/postgresql/).
- Blob storage: [ Azure Blob Storage](https://azure.microsoft.com/en-us/products/storage/blobs/)
- Load balancer: [Azure Application Gateway](https://azure.microsoft.com/en-us/products/application-gateway)

This is a quickstart guide.
For more information, see the official documentation.
Always follow the documentation and recommended best practices from the vendor.

Remember to change the provided example values to adapt them to your own environment and needs.

## Prerequisites

- An account in Azure with permissions for the required services
- A Linux host with the following clients installed:
    - [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/?view=azure-cli-latest)
    - [Kubectl](https://kubernetes.io/docs/tasks/tools/)
    - [Helm 3+](https://helm.sh/docs/intro/install/)

**Note:** The Azure CLI (`az`) is used in the examples below, but you can use the Azure web interface, REST API, libraries or any other available methods.

## Steps

### 1. Prepare a resource group, virtual network and subnets

1. Create your resource group:
    ```bash
    export RESOURCE_GROUP=spotfire-quickstart
    export LOCATION=swedencentral
    az group create --name $RESOURCE_GROUP --location $LOCATION
    ```

2. Create a virtual network and subnets for your AKS cluster and Azure database. For example:
    ```bash
    export SPOTFIRE_VNET=spotfire-vnet
    export K8S_SUBNET=k8s-subnet
    export DB_SUBNET=db-subnet
   
    az network vnet create \
        --resource-group $RESOURCE_GROUP \
        --name $SPOTFIRE_VNET \
        --address-prefixes 10.10.0.0/16

    az network vnet subnet create \
        --resource-group $RESOURCE_GROUP \
        --vnet-name $SPOTFIRE_VNET \
        --name $K8S_SUBNET \
        --address-prefixes 10.10.1.0/24

    az network vnet subnet create \
        --resource-group $RESOURCE_GROUP \
        --vnet-name $SPOTFIRE_VNET \
        --name $DB_SUBNET \
        --address-prefixes 10.10.2.0/24
    ```

3. Save the AKS subnet resource ID for later:
    ```bash
    export K8S_SUBNET_ID=$(az network vnet subnet show \
        --resource-group $RESOURCE_GROUP \
        --vnet-name $SPOTFIRE_VNET \
        --name $K8S_SUBNET \
        --query id --output tsv)
    ```

For more information, see the [Azure Virtual Network documentation](https://learn.microsoft.com/en-us/azure/virtual-network/).

### 2. Create an Azure Kubernetes Service (AKS) cluster

1. Define the variables for your cluster:
    ```bash
    export CLUSTER_NAME=my-aks
    export NODE_SIZE=Standard_D8_v4
    export NODE_COUNT=3
    export AUTH_IP_ADDRESSES=123.45.0.0/16
    ```

    **Note:** In this example we create a 3-nodes cluster using the `Standard_D8_v4` virtual machine type (8 vCPUs, 32 GB).
    See the [Azure virtual machine sizes](https://learn.microsoft.com/en-us/azure/virtual-machines/sizes/overview) to understand which SKU you need for your K8s nodes.
    The Azure D-Family of VM-sizes are general purpose VMs for Enterprise-grade applications.
 
    **Note:** See the [Spotfire system requirements](https://spotfi.re/sr) for the minimum and recommended sizing.
    Observe your K8s resource utilization to understand which node size and how many nodes do you need.

2. Create the AKS cluster:
    ```bash
    az aks create \
        --resource-group $RESOURCE_GROUP \
        --name $CLUSTER_NAME \
        --location $LOCATION \
        --node-count $NODE_COUNT \
        --node-vm-size $NODE_SIZE \
        --enable-addons monitoring \
        --generate-ssh-keys \
        --vnet-subnet-id $K8S_SUBNET_ID \
        --api-server-authorized-ip-ranges $AUTH_IP_ADDRESSES
    ```

    It will take ~5-10 minutes to create the K8s cluster.

3. Configure `kubectl` to use the new AKS cluster:
    ```bash
    az aks get-credentials \
        --resource-group $RESOURCE_GROUP \
        --name $CLUSTER_NAME
    ```

4. Verify that you can connect to the cluster using `kubectl`:
    ```bash
    kubectl get nodes -o wide
    ```

For more information, see the [Azure Kubernetes Service (AKS) Documentation](https://docs.microsoft.com/en-us/azure/aks/).

You can learn about reference architectures, diagrams, and best practices in [Azure Architecture Center: Best practices](https://learn.microsoft.com/en-us/azure/architecture/best-practices/index-best-practices).

See also [AKS best practices](https://learn.microsoft.com/en-us/azure/aks/best-practices).

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
        --set spotfire-server.postgresql.enabled=true
    ```
    For more information, see the [spotfire-platform Helm chart](../../helm/charts/spotfire-platform/README.md).

You have now deployed the Spotfire platform on Azure,
using Azure Kubernetes Service (AKS).

### 4. Next steps

You can now continue with:
- [Configuring an Azure Load Balancer or an Azure Application Gateway](azure-appgw-ingress.md).
- [Configuring an Azure Database for PostgreSQL as the Spotfire database](azure-database-postgres.md).
- [Configuring an Azure Blob Storage as the Spotfire external library storage](azure-blob-storage.md).

## Cleanup

To avoid unneeded resource usage, once you have completed these tutorials, delete any created resources:
```bash
az aks delete --name $CLUSTER_NAME --resource-group $RESOURCE_GROUP --yes --no-wait
...
```
For more information, see [Delete an AKS cluster](https://learn.microsoft.com/en-us/azure/aks/delete-cluster).

You can also remove all the resources within a resource group with a single command:
```bash
az group delete --name $RESOURCE_GROUP --yes --no-wait
```

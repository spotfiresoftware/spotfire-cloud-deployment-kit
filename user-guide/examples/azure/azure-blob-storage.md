# Configuring an Azure Blob Storage as the Spotfire external library storage

This page provides an overview of the main steps needed to use an [Azure Blob Storage](https://learn.microsoft.com/en-us/azure/storage/blobs/storage-blobs-introduction)
and to deploy the [Spotfire Platform](https://www.spotfire.com/) on [Azure Kubernetes Service (AKS)](https://azure.microsoft.com/en-us/products/kubernetes-service),
using the [Spotfire CDK](https://github.com/spotfiresoftware/spotfire-cloud-deployment-kit).

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
- You have completed the previous quickstarts:
    - [Deploying Spotfire on Azure Kubernetes Service (AKS)](azure-aks.md)
    - [Configuring an Azure Load Balancer or an Azure Application Gateway](azure-appgw-ingress.md)
    - [Configuring an Azure Database for PostgreSQL as the Spotfire database](azure-database-postgres.md)

**Note:** The Azure CLI (`az`) is used in the examples below, but you can use the Azure web interface, REST API, libraries or any other available methods.

## Steps

### 1. Create an Azure Blob Storage

1. If not already set, define the following environment variables (as from the previous quickstarts):
    ```bash
    export RESOURCE_GROUP=spotfire-quickstart
    export LOCATION=swedencentral
    export SPOTFIRE_VNET=spotfire-vnet
    export K8S_SUBNET=k8s-subnet
    export DB_SUBNET=db-subnet
    export NAMESPACE=spotfire-quickstart
    ```

2. Create an Azure Blob Storage account:
    ```bash
    export ACCOUNT_NAME=<account-name>

    az storage account create \
        --name $ACCOUNT_NAME \
        --resource-group $RESOURCE_GROUP \
        --location $LOCATION \
        --sku Standard_LRS \
        --allow-blob-public-access false \
        --publish-internet-endpoints false \
        --public-network-access enabled \
        --vnet-name $SPOTFIRE_VNET \
        --subnet $DB_SUBNET \
        --default-action Deny \
        --bypass AzureServices
    ```
    For more information, see the [Azure Blob Storage Quickstart](https://learn.microsoft.com/en-us/azure/storage/blobs/storage-quickstart-blobs-cli).

    **Note:** The storage account name must be between 3 and 24 characters in length and use numbers and lower-case letters only.

    **Note:** The storage account name must be unique for Azure. Use a long and uncommon string.

3. Show your connection string:
    ```bash
    az storage account show-connection-string --name $ACCOUNT_NAME
    ```

4. Allow access from your admin IP address or subnetwork:
    ```bash
    az storage account network-rule add \
        --resource-group $RESOURCE_GROUP \
        --account-name $ACCOUNT_NAME \
        --ip-address $AUTH_IP_ADDRESSES
    ```

5. Create a blob container in that storage account:
    ```bash
    export STORAGE_CONTAINER=<container-name>

    az storage container create \
        --account-name $ACCOUNT_NAME \
        --name $STORAGE_CONTAINER \
        --auth-mode login
    ```

6. Show your created blob container in that account:
    ```bash
    az storage container list --account-name $ACCOUNT_NAME
    ```

For more information, see the [az storage](https://learn.microsoft.com/en-us/cli/azure/storage?view=azure-cli-latest) CLI reference.

### 2. Allow access from the AKS services to the Azure Blob Storage

1. Enable a Service Endpoint for Azure Blob Storage on the AKS subnet:
    ```bash
    az network vnet subnet update \
        --name $K8S_SUBNET \
        --vnet-name $SPOTFIRE_VNET \
        --resource-group $RESOURCE_GROUP \
        --service-endpoints "Microsoft.Storage"
    ```

2. Allow access to the Azure Blob Storage Access from the AKS subnet:
    ```bash
    az storage account network-rule add \
        --resource-group $RESOURCE_GROUP \
        --account-name $ACCOUNT_NAME \
        --vnet-name $SPOTFIRE_VNET \
        --subnet $K8S_SUBNET
    ```

### 3. Deploy Spotfire

1. Create a Helm values file using the following `azure-blob-storage.yaml` example template:
    ```yaml
    spotfire-server:
      configuration:
        configurationScripts:
        - name: config-library-external-azure-storage-storage
          # https://docs.tibco.com/pub/spotfire_server/latest/doc/html/TIB_sfire_server_tsas_admin_help/server/topics/config-library-external-azure-blob-storage.html
          script: |
            config-library-external-azure-blob-storage \
              --container-name="<container-name>" \
              --key-prefix="spotfirelibrary/" \
              --connection-string="<connection-string>" \
              --bootstrap-config="${BOOTSTRAP_FILE}"
        - name: config-library-external-data-storage
          # https://docs.tibco.com/pub/spotfire_server/latest/doc/html/TIB_sfire_server_tsas_admin_help/server/topics/config-library-external-data-storage.html
          script: |
            config-library-external-data-storage \
              --tool-password="${TOOL_PASSWORD}" \
              --enabled=true \
              --external-storage=AZURE_BLOB_STORAGE \
              --bootstrap-config="${BOOTSTRAP_FILE}"
    ```
    **Note:** The expected connection string format is: 
     `--connection-string="DefaultEndpointsProtocol=https;EndpointSuffix=core.windows.net;AccountName=<account-name>;AccountKey=<account-key>"`

    For more information, see the [config-library-external-data-storage](https://docs.tibco.com/pub/spotfire_server/latest/doc/html/TIB_sfire_server_tsas_admin_help/server/topics/config-library-external-data-storage.html) and [config-library-external-azure-blob-storage](https://docs.tibco.com/pub/spotfire_server/latest/doc/html/TIB_sfire_server_tsas_admin_help/server/topics/config-library-external-azure-blob-storage.html) documentation.

2. Deploy the `spotfire-platform` Helm chart using the `azure-blob-storage.yaml` values file.
    For example:
    ```bash
    export NAMESPACE=spotfire-quickstart
    export MY_SPOTFIRE_RELEASE=vanilla-spotfire
    export REGISTRY_SERVER=oci.spotfire.com
    export REGISTRY_SECRET=spotfire-oci-secret

    helm upgrade --install $MY_SPOTFIRE_RELEASE \
        oci://$REGISTRY_SERVER/charts/spotfire-platform \
        --version 2.0.0 \
        --namespace=$NAMESPACE \
        --set global.spotfire.acceptEUA=true \
        --set global.spotfire.image.registry=$REGISTRY_SERVER \
        --set global.spotfire.image.pullSecrets[0]=$REGISTRY_SECRET \
        --set spotfire-server.configuration.site.publicAddress=http://spotfire.example.com \
        -f azure-database-postgres.yaml \
        -f azure-blob-storage.yaml
    ```
    For more information, see the [spotfire-platform Helm chart](../../helm/charts/spotfire-platform/README.md).

You have now deployed the Spotfire platform on Azure,
using an Azure Blob Storage as the Spotfire external library storage.

You can learn about reference architectures, diagrams, and best practices in Azure in [Azure Architecture Center: Best practices and](https://learn.microsoft.com/en-us/azure/architecture/best-practices/index-best-practices).

See also the [Security recommendations for Blob storage](https://learn.microsoft.com/en-us/azure/storage/blobs/security-recommendations).

## Cleanup

To avoid unneeded resource usage, once you have completed this tutorial, delete any created resources:

```bash
az storage container delete --name $ACCOUNT_NAME --resource-group $RESOURCE_GROUP
...
```
For more information, see [Delete Azure storage account](https://learn.microsoft.com/en-us/cli/azure/storage/account?view=azure-cli-latest).


You can also remove all the resources within a resource group with a single command:
```bash
az group delete --name $RESOURCE_GROUP --yes --no-wait
```

# Configuring an Azure Database for PostgreSQL as the Spotfire database

This page provides an overview of the main steps needed to use an [Azure Database for PostgreSQL - Flexible Server](https://learn.microsoft.com/en-us/azure/postgresql/) instance as the Spotfire database
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

**Note:** The Azure CLI (`az`) is used in the examples below, but you can use the Azure web interface, REST API, libraries or any other available methods.

## Steps

### 1. Create an Azure Database for PostgreSQL (Flexible Server) database

First, create a relational database instance in the Azure account, choosing a network with connectivity to your K8s cluster.
For simplicity, in this quickstart we create the database in the same virtual network as the AKS cluster, see [here](azure-aks.md).

For more information, see [Create an Azure Database for PostgreSQL](https://learn.microsoft.com/en-us/azure/postgresql/flexible-server/quickstart-create-server-cli) and [az postgres flexible-server reference](https://learn.microsoft.com/en-us/cli/azure/postgres/flexible-server?view=azure-cli-latest#az-postgres-flexible-server-create).

**Note:** To migrate an existing PostgreSQL database to Azure database for PostgreSQL, see [Migration service in Azure Database for PostgreSQL](https://learn.microsoft.com/en-us/azure/postgresql/migrate/migration-service/overview-migration-service-postgresql).

1. If not already set, define the following environment variables (as from the previous quickstart):
    ```bash
    export RESOURCE_GROUP=spotfire-quickstart
    export LOCATION=swedencentral
    export SPOTFIRE_VNET=spotfire-vnet
    export DB_SUBNET=db-subnet
    ```

2. Create a private DNS zone and capture its ID:
    ```bash
    export PRIVATE_DNS_ZONE_NAME=spotdns.private.postgres.database.azure.com

    az network private-dns zone create \
        --resource-group $RESOURCE_GROUP \
        --name $PRIVATE_DNS_ZONE_NAME
    export PRIVATE_DNS_ZONE_ID=$(az network private-dns zone show \
        --resource-group $RESOURCE_GROUP \
        --name $PRIVATE_DNS_ZONE_NAME \
        --query "id" \
        --output tsv)
    ```

3. Create an Azure Database for PostgreSQL instance:
    ```bash 
    export DB_INSTANCE_NAME=<db-instance-name>
    export DB_ADMIN_USERNAME=<changeAdminUsername>
    export DB_ADMIN_PASSWORD=<changeAdminPassword>
    export SKU_NAME=Standard_D2s_v3 # 2 vCPUs, 8 GB RAM

    az postgres flexible-server create \
        --resource-group $RESOURCE_GROUP \
        --name $DB_INSTANCE_NAME \
        --location $LOCATION \
        --vnet $SPOTFIRE_VNET \
        --subnet $DB_SUBNET \
        --admin-user $DB_ADMIN_USERNAME \
        --admin-password $DB_ADMIN_PASSWORD \
        --tier GeneralPurpose \
        --sku-name $SKU_NAME \
        --version 16 \
        --private-dns-zone $PRIVATE_DNS_ZONE_ID
    ```
    **Note:** It will take ~5-10 minutes to create the database instance.

    **Note:** See the [Compute options in Azure Database for PostgreSQL](https://learn.microsoft.com/en-us/azure/postgresql/flexible-server/concepts-compute) and the [Azure virtual machine sizes](https://learn.microsoft.com/en-us/azure/virtual-machines/sizes/overview) to understand which SKU you need for your database.
    For a production environment you might want to use a `GeneralPurpose` or `MemoryOptimized` tier SKU.

4. List your created instance and take note of its private IP address:
    ```bash
    az postgres flexible-server list
    ```

5. Get the FQDN (Fully Qualified Domain Name) of the database:
    ```bash
    az postgres flexible-server show \
        --resource-group $RESOURCE_GROUP \
        --name $DB_INSTANCE_NAME \
        --query "fullyQualifiedDomainName" \
        --output tsv
    ```
    Your FQDN should look like this `<db-instance-name>.postgres.database.azure.com`.
    And then, your JDBC connection string would look similar to this:
    ```text
    jdbc:postgresql://<db-instance-name>.postgres.database.azure.com:5432/<db-instance-name>
    ```

    **Note:** By following the previous steps, the Azure Database for PostgreSQL is created with [networking with private access (VNet integration)](https://learn.microsoft.com/en-us/azure/postgresql/flexible-server/concepts-networking-private), which means that it is accessible within the same virtual network.
    In other words, the AKS services can already connect to the Azure database, because they were created in different subnets within the same virtual network.
    If, instead, you are using an already existing database in other network (or depending on your Azure network configuration), you might need to set up a [private endpoint connection for your Azure database](https://learn.microsoft.com/en-us/azure/postgresql/flexible-server/concepts-networking-private-link).

### 2. Deploy Spotfire

1. Create a Helm values file using the following `azure-database-postgres.yaml` example template:
    ```yaml
    spotfire-server:
      database:
        bootstrap:
          databaseUrl: "jdbc:postgresql://<db-instance-name>.postgres.database.azure.com:5432/<db-instance-name>"
          username: "<changeAdminUsername>"
          password: "<changeAdminPass>"
        create-db:
          adminUsername: "<changeAdminUsername>"
          adminPassword: "<changeAdminPass>"
          databaseUrl: "jdbc:postgresql://<db-instance-name>.postgres.database.azure.com:5432/postgres"
          doNotCreateUser: true
          spotfiredbDbname: "<db-instance-name>"
    ```

2. Deploy the `spotfire-platform` Helm chart using the `azure-database-postgres.yaml` additional values.
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
        --set global.spotfire.image.registry=$REGISTRY_SERVER\
        --set global.spotfire.image.pullSecrets[0]=$REGISTRY_SECRET \
        --set spotfire-server.configuration.site.publicAddress=http://spotfire.example.com \
        -f azure-database-postgres.yaml \
        ...
    ```
    For more information, see the [spotfire-platform Helm chart](../../helm/charts/spotfire-platform/README.md).

You have now deployed the Spotfire platform on Azure,
using an Azure Database for PostgreSQL instance as the Spotfire database.

You can learn about reference architectures, diagrams, and best practices in Azure in [Azure Architecture Center: Best practices](https://learn.microsoft.com/en-us/azure/architecture/best-practices/index-best-practices).

## Cleanup

To avoid unneeded resource usage, once you have completed this tutorial, delete any created resources:
```bash
az postgres flexible-server delete --name $DB_INSTANCE_NAME --resource-group $RESOURCE_GROUP --yes
...
```
For more information, see [Delete Azure SQL instances](https://learn.microsoft.com/en-us/cli/azure/postgres/flexible-server/db?view=azure-cli-latest#az-postgres-flexible-server-db-delete).

You can also remove all the resources within a resource group with a single command:
```bash
az group delete --name $RESOURCE_GROUP --yes --no-wait
```

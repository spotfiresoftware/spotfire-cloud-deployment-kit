# Configuring a Google Cloud SQL for PostgreSQL database as the Spotfire database

This page provides an overview of the main steps needed to use a [Google Cloud SQL for PostgreSQL](https://cloud.google.com/sql/docs/postgres/) instance as the Spotfire database
to deploy the [Spotfire Platform](https://www.spotfire.com/) on [Google Kubernetes Engine (GKE)](https://cloud.google.com/kubernetes-engine),
using the [Spotfire CDK](https://github.com/spotfiresoftware/spotfire-cloud-deployment-kit).

This is a quickstart guide.
For more information, see the official documentation.
Always follow the documentation and recommended best practices from the vendor.

Remember to change the provided example values to adapt them to your own environment and needs.

## Prerequisites

- An account in Google Cloud Platform with permissions for the required services
- A Linux host with the following clients installed:
    - [gcloud cli](https://cloud.google.com/sdk/docs/install-sdk)
    - [Kubectl](https://kubernetes.io/docs/tasks/tools/)
    - [Helm 3+](https://helm.sh/docs/intro/install/)
- You have completed the previous quickstarts:
    - [Deploying Spotfire on Google Kubernetes Engine (GKE)](google-gke.md)
    - [Configuring a Google Network Load Balancer or a Google Application Load Balancer](google-gce-ingress.md)

**Note:** The Google Cloud CLI (`gcloud`) is used in the examples below, but you can use the Google Cloud web interface, REST API, libraries or any other available methods.

## Steps

### 1. Create a Google Cloud SQL for PostgreSQL database

First, create a relational database instance in the Google account, choosing a network with connectivity to your K8s cluster.

For more information, see [Cloud SQL PostgreSQL - Create instances](https://cloud.google.com/sql/docs/postgres/create-instance) and [Connect to Cloud SQL for PostgreSQL from Google Kubernetes Engine](https://cloud.google.com/sql/docs/postgres/connect-instance-kubernetes#expandable-2).

**Note:** To migrate an existing PostgreSQL database to Google SQL, see [Database Migration Service](https://cloud.google.com/database-migration?hl=en) and
[Migrate a database to Cloud SQL for PostgreSQL by using Database Migration Service](https://cloud.google.com/database-migration/docs/postgres/quickstart).

**Note:** Here, we create a Google SQL database instance with only a private IP address. This requires configuring private services access to enable connections from other Google Cloud services, such as GKE.

1. If not already set, define the following environment variables (as from the previous quickstart):
    ```bash
    export PROJECT_ID=spotfire-product-mgmt
    export LOCATION=europe-north1
    ```

2. Check if you already have allocated an IP range for a private services access connection:
    ```bash
    gcloud compute addresses list --global --filter="purpose=VPC_PEERING"
    ```
    If not, run the gcloud compute addresses create command to allocate an IP range for a private services access connection:
    ```bash
    gcloud compute addresses create google-managed-services-default \
      --global \
      --purpose=VPC_PEERING \
      --prefix-length=16 \
      --description="peering range for Google" \
      --network=default
    ```
    For more information, see [Configure private services access](https://cloud.google.com/vpc/docs/configure-private-services-access#gcloud).

3. Run the gcloud services `vpc-peerings connect` command to create the private services access connection:
    ```bash
    gcloud services vpc-peerings connect \
      --service=servicenetworking.googleapis.com \
      --ranges=google-managed-services-default \
      --network=default
    ```

4. Create a Cloud SQL for PostgreSQL instance with a private IP address:
    ```bash
    export DB_INSTANCE_NAME=<db-instance-name>
    export DB_ADMIN_PASSWORD=<changeAdminPassword>
    export MACHINE_TYPE=db-custom-2-7680 # 2 vCPUs, 8 GB RAM

    gcloud services enable sqladmin.googleapis.com
    gcloud sql instances create $DB_INSTANCE_NAME \
        --database-version=POSTGRES_16 \
        --region=$LOCATION \
        --tier=$MACHINE_TYPE \
        --root-password=$DB_ADMIN_PASSWORD \
        --no-assign-ip \
        --network=default
    ```
    It will take ~5 minutes to create the database instance.

    For more information, see [Google SQL - Create instances](https://cloud.google.com/sql/docs/postgres/create-instance#gcloud).

    See [Introduction to Cloud SQL for PostgreSQL editions](https://cloud.google.com/sql/docs/postgres/editions-intro) to understand which edition you need for your database.

5. List your created instance and take note of its private IP address:
    ```bash
    gcloud sql instances list
    ```

### 2. Deploy Spotfire

1. Create a Helm values file using the following `google-cloud-sql-postgres.yaml` example template.
    Replace the IP address with the private IP address of your database.
    ```yaml
    spotfire-server:
      database:
        bootstrap:
          databaseUrl: "jdbc:postgresql://<db-private-IP-address>:5432/spotfiredb"
          username: "postgres"
          password: "<changeAdminPass>"
        create-db:
          adminUsername: "postgres"
          adminPassword: "<changeAdminPass>"
          databaseUrl: "jdbc:postgresql://<db-private-IP-address>:5432/postgres"
          doNotCreateUser: true
          spotfiredbDbname: spotfiredb
    ```

2. Deploy the `spotfire-platform` Helm chart using the `google-cloud-sql-postgres.yaml` additional values.
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
        -f google-cloud-sql-postgres.yaml
    ```
   For more information, see the [spotfire-platform Helm chart](../../helm/charts/spotfire-platform/README.md).

You have now deployed the Spotfire Platform on Google Cloud,
using a Google Cloud SQL for PostgreSQL instance as the Spotfire database.

You can learn about reference architectures, diagrams, and best practices in Google Cloud in [Cloud Architecture Center](https://cloud.google.com/architecture).

## Cleanup

To avoid unneeded resource usage, once you have completed this tutorial, delete any created resources:
```bash
gcloud container clusters delete $CLUSTER_NAME --location $LOCATION
gcloud sql instances delete $DB_INSTANCE_NAME
...
```
For more information, see [Google SQL - Delete instances](https://cloud.google.com/sql/docs/postgres/delete-instance#gcloud).

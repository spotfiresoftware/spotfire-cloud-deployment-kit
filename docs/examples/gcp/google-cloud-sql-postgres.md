# Configuring a Google Cloud SQL database as the Spotfire database

## Overview

This page provides an overview of the main steps to use a [Google Cloud SQL PostgreSQL](https://cloud.google.com/sql/docs/postgres/) instance as the Spotfire database, when deploying the [Spotfire Platform](https://www.spotfire.com/) on [Google Kubernetes Engine (GKE)](https://cloud.google.com/kubernetes-engine) using the [Spotfire CDK](https://github.com/spotfiresoftware/spotfire-cloud-deployment-kit).

**Note**: This is a quick start guide. For more information, see the official documentation.

**Note**: Remember to change the provided example values and extend the provided steps to adapt them to your specific needs and to align to the recommended best practices.

## Prerequisites

- An account in Google Cloud Platform with permissions for the required GCP services.
- [gcloud cli](https://cloud.google.com/sdk/docs/install-sdk).
- [Kubectl](https://kubernetes.io/docs/tasks/tools/).
- [Helm 3+](https://helm.sh/docs/intro/install/).

**Note**: We use gcloud cli for the steps below, but you can use the Google Cloud web interface, REST API, libraries or any other available methods.

## Steps

### 1. Create a Google Cloud SQL database

First, we create a relational database instance in the Google account, choosing a network with connectivity to the GKE cluster.

For more information, see [Cloud SQL PostgreSQL - Create instances](https://cloud.google.com/sql/docs/postgres/create-instance) and [Connect to Cloud SQL for PostgreSQL from Google Kubernetes Engine](https://cloud.google.com/sql/docs/postgres/connect-instance-kubernetes#expandable-2).

**Note**: To migrate an existing PostgreSQL database to Google SQL, see
[Database Migration Service](https://cloud.google.com/database-migration?hl=en) and
[Migrate a database to Cloud SQL for PostgreSQL by using Database Migration Service](https://cloud.google.com/database-migration/docs/postgres/quickstart).

**Note**: We create a Google SQL database instance with only a private IP address. This requires configuring private services access to enable connections from other Google Cloud services, such as GKE.

**Note**: Replace the variables within "<>" with the appropriate values.

1. Check out if you already have allocated an IP range for a private services access connection:
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

2. Run the gcloud services `vpc-peerings connect` command to create the private services access connection:
    ```bash
    gcloud services vpc-peerings connect \
      --service=servicenetworking.googleapis.com \
      --ranges=google-managed-services-default \
      --network=default
    ```

3. Create a Cloud SQL instance with a private IP address:
    ```bash
    export DB_INSTANCE_NAME=<db instance name>
    export DB_ADMIN_PASSWORD=<changeAdminPass>
    gcloud services enable sqladmin.googleapis.com
    gcloud sql instances create $DB_INSTANCE_NAME \
      --database-version=POSTGRES_15 \
      --cpu=1 \
      --memory=4GB \
      --region=$REGION \
      --root-password=$DB_ADMIN_PASSWORD \
      --no-assign-ip \
      --network=default
    ```
    **Note**: It will take ~5 minutes to create the database instance.

    List your created instance and take note of its private IP address:
    ```bash
    gcloud sql instances list
    ```

### 2 .Deploy Spotfire

1. Create a helm values file using the following `google-cloud-sql-postgres.yaml` example template.
    Replace the IP address with your database private IP address.
    ```yaml
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

2. Deploy the `spotfire-server` Helm chart using the `google-cloud-sql-postgres.yaml` additional values.
    For example:
    ```bash
    helm upgrade --install <my-spotfire-server-release> \
      <my-charts-location>/spotfire-server \
      --set global.spotfire.acceptEUA=true \
      --set global.spotfire.image.registry=<my-private-registry> \
      --namespace=$NAMESPACE \
      --set configuration.site.publicAddress=http://spotfire.local \
      -f google-cloud-sql-postgres.yaml
      ...
    ```

Congratulations, you have deployed the Spotfire Platform on Google Cloud
using a Google Cloud SQL database as the Spotfire database.

You can also learn about reference architectures, diagrams, and best practices in Google Cloud in [Cloud Architecture Center](https://cloud.google.com/architecture)

### 3. Cleanup

- To avoid unneeded resource usage, and once you have completed this tutorial, delete any created resources:
    ```bash
    gcloud container clusters delete $CLUSTER_NAME --location $REGION
    gcloud sql instances delete $DB_INSTANCE_NAME
    ...
    ```
    For more information, see [Delete Google SQL instances](https://cloud.google.com/sql/docs/postgres/delete-instance#gcloud).

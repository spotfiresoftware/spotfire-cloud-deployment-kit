# Configuring a Google Cloud Storage bucket as the Spotfire external library storage

This page provides an overview of the main steps needed to use a [Google Storage bucket](https://cloud.google.com/storage/docs/buckets) 
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
    - [Configuring a Google Cloud SQL for PostgreSQL database as the Spotfire database](google-cloud-sql-postgres.md)

**Note:** The Google Cloud CLI (`gcloud`) is used in the examples below, but you can use the Google Cloud web interface, REST API, libraries or any other available methods.

## Steps

### 1. Create a Google Storage bucket

1. If not already set, define the following environment variables (as from the previous quickstarts):
    ```bash
    export RESOURCE_GROUP=spotfire-quickstart
    export LOCATION=europe-north1
    export NAMESPACE=spotfire-quickstart
    ```

2. Create a Google Storage bucket:
    ```bash
    export BUCKET_NAME=<my-bucket>
    gcloud storage buckets create gs://$BUCKET_NAME \
        --location=$LOCATION
    ```
    For more information, see [Create buckets](https://cloud.google.com/storage/docs/creating-buckets).

3. Verify your bucket:
    ```bash
    gcloud storage ls
    ```

### 2. Deploy Spotfire

1. Create a Helm values file using the following `google-cloud-storage-bucket.yaml` example template:
    ```yaml
    configuration:
      configurationScripts:
        - name: config-library-external-google-storage-storage
          # https://docs.tibco.com/pub/spotfire_server/latest/doc/html/TIB_sfire_server_tsas_admin_help/server/topics/config-library-external-google-cloud-storage.html
          script: |
            config-library-external-google-cloud-storage \
              --bucket-name="<GCP bucket name>" \
              --key-prefix="spotfire-library/" \
              --project-id="<GCP project ID>" \
              --credential-file-path=<creds file path> \
              --bootstrap-config="${BOOTSTRAP_FILE}"
        - name: config-library-external-data-storage
          # https://docs.tibco.com/pub/spotfire_server/latest/doc/html/TIB_sfire_server_tsas_admin_help/server/topics/config-library-external-s3-storage.html
          script: |
            config-library-external-data-storage \
              --tool-password="${TOOL_PASSWORD}" \
              --enabled=true \
              --external-storage=GOOGLE_CLOUD_STORAGE \
              --bootstrap-config="${BOOTSTRAP_FILE}"
    ```

    For more information, see the [config-library-external-data-storage](https://docs.tibco.com/pub/spotfire_server/latest/doc/html/TIB_sfire_server_tsas_admin_help/server/topics/config-library-external-data-storage.html) and [config-library-external-google-cloud-storage](https://docs.tibco.com/pub/spotfire_server/latest/doc/html/TIB_sfire_server_tsas_admin_help/server/topics/config-library-external-google-cloud-storage.html) documentation.

2. Deploy the `spotfire-platform` Helm chart using the `google-cloud-storage-bucket.yaml` additional values file.
    For example:
    ```bash
    export NAMESPACE=spotfire-quickstart
    export MY_SPOTFIRE_RELEASE=vanilla-spotfire
    export REGISTRY_SERVER=oci.spotfire.com
    export REGISTRY_SECRET=spotfire-oci-secret

    helm upgrade --install $MY_SPOTFIRE_RELEASE \
        oci://$REGISTRY_SERVER/charts/spotfire-platform \
        --version "{{ SPOTFIRE_PLATFORM_CHART_VERSION }}" \
        --namespace=$NAMESPACE \
        --set global.spotfire.acceptEUA=true \
        --set global.spotfire.image.registry=$REGISTRY_SERVER \
        --set global.spotfire.image.pullSecrets[0]=$REGISTRY_SECRET \
        --set spotfire-server.configuration.site.publicAddress=http://spotfire.example.com \
        -f google-cloud-sql-postgres.yaml \
        -f google-cloud-storage-bucket.yaml
    ```
    For more information, see the [spotfire-platform Helm chart](../../helm/charts/spotfire-platform/README.md).

You have now deployed the Spotfire Platform on Google Cloud,
using a Google Cloud Storage bucket as the Spotfire external library storage.

You can learn about reference architectures, diagrams, and best practices in Google Cloud in [Cloud Architecture Center](https://cloud.google.com/architecture)

### 3. Cleanup

To avoid unneeded resource usage, once you have completed this tutorial, delete any created resources:
```bash
gcloud container clusters delete $CLUSTER_NAME --location $LOCATION
gcloud sql instances delete $DB_INSTANCE_NAME
gcloud storage rm --recursive gs://$BUCKET_NAME
...
```
For more information, see [Delete Google Storage buckets](https://cloud.google.com/storage/docs/deleting-buckets#delete-bucket-cli).

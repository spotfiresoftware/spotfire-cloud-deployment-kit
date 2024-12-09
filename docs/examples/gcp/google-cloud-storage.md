# Configuring a Google Cloud Storage bucket as the Spotfire external library storage

## Overview

This page provides an overview of the main steps to use a [Google Storage](https://cloud.google.com/load-balancing/docs/application-load-balancer)  when deploying the [Spotfire Platform](https://www.spotfire.com/) on [Google Kubernetes Engine (GKE)](https://cloud.google.com/kubernetes-engine) using the [Spotfire CDK](https://github.com/spotfiresoftware/spotfire-cloud-deployment-kit).

**Note**: This is a quick start guide. For more information, see the official documentation.

**Note**: Remember to change the provided example values and extend the provided steps to adapt them to your specific needs and to align to the recommended best practices.

## Prerequisites

- An account in Google Cloud Platform with permissions for the required GCP services.
- [gcloud cli](https://cloud.google.com/sdk/docs/install-sdk).
- [Kubectl](https://kubernetes.io/docs/tasks/tools/).
- [Helm 3+](https://helm.sh/docs/intro/install/).

**Note**: We use gcloud cli for the steps below, but you can use the Google Cloud web interface, REST API, libraries or any other available methods.

## Steps

### 1. Create a Google Storage bucket

1. Create a Google Storage bucket:
    ```bash
    export BUCKET_NAME=<my-bucket>
    gcloud storage buckets create gs:/$BUCKET_NAME \
        --location=$REGION
    ```
    For more information, see [Create buckets](https://cloud.google.com/storage/docs/creating-buckets).

2. Verify your bucket:
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
            config-library-external-google-cloud-storage --bucket-name="<GCP bucket name>" --key-prefix="spotfire-library/" --project-id="<GCP project ID>" --credential-file-path=<creds file path> --bootstrap-config="${BOOTSTRAP_FILE}"
        - name: config-library-external-data-storage
          # https://docs.tibco.com/pub/spotfire_server/latest/doc/html/TIB_sfire_server_tsas_admin_help/server/topics/config-library-external-s3-storage.html
          script: |
            config-library-external-data-storage --tool-password="${TOOL_PASSWORD}" --enabled=true --external-storage=GOOGLE_CLOUD_STORAGE --bootstrap-config="${BOOTSTRAP_FILE}"
    ```

    For more information, see the [config-library-external-data-storage](https://docs.tibco.com/pub/spotfire_server/latest/doc/html/TIB_sfire_server_tsas_admin_help/server/topics/config-library-external-data-storage.html) and [config-library-external-google-cloud-storage](https://docs.tibco.com/pub/spotfire_server/latest/doc/html/TIB_sfire_server_tsas_admin_help/server/topics/config-library-external-google-cloud-storage.html) documentation.

2. Deploy the `spotfire-server` Helm chart using the  `google-cloud-storage-bucket.yaml` additional values.
   For example:
    ```bash
    helm upgrade --install my-spotfire-server-release \
      <my-charts-location>/spotfire-server \
      --set global.spotfire.acceptEUA=true \
      --set global.spotfire.image.registry=<my-private-registry> \
      --namespace=$NAMESPACE \
      -f google-cloud-storage-bucket.yaml \
      ...
    ```
   
    For more information, see the ["Installing" section in the Readme for the `spotfire-server` helm chart](../../../helm/charts/spotfire-server/README.md#installing).

    **Note**: If the release is already installed, then use:
    ```bash
    helm upgrade --install my-spotfire-server-release \
        <my-charts-location>/spotfire-server \
        --set configuration.apply=always \
        --set database.create-db.enabled=false \
        -f google-cloud-storage-bucket.yaml \
        ...
    ```

    **Note**: To reflect the service account annotation change on the pod, the existing `spotfire-server` and `spotfire-config` pods are re-created (either by deleting old pods or scale in/out respective replicaset).

Congratulations, you have deployed the Spotfire Platform on Google Cloud using
a Google Cloud Storage bucket as the Spotfire external library storage.

You can also learn about reference architectures, diagrams, and best practices in Google Cloud in [Cloud Architecture Center](https://cloud.google.com/architecture)

### 3. Cleanup

- To avoid unneeded resource usage, and once you have completed this tutorial, delete any created resources:
    ```bash
    gcloud container clusters delete $CLUSTER_NAME --location $REGION
    gcloud storage rm --recursive gs://$BUCKET_NAME
    ...
    ```
    For more information, see [Delete Google Storage buckets](https://cloud.google.com/storage/docs/deleting-buckets#delete-bucket-cli).
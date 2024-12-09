# Configuring a Google Application Load Balancer with the GKE Ingress controller

## Overview

This page provides an overview of the main steps to use a [Google Application Load Balancer](https://cloud.google.com/load-balancing/docs/application-load-balancer) with the [GKE Ingress](https://cloud.google.com/kubernetes-engine/docs/concepts/ingress) controller, when deploying the [Spotfire Platform](https://www.spotfire.com/) on [Google Kubernetes Engine (GKE)](https://cloud.google.com/kubernetes-engine) using the [Spotfire CDK](https://github.com/spotfiresoftware/spotfire-cloud-deployment-kit).

**Note**: This is a quick start guide. For more information, see the official documentation.

**Note**: Remember to change the provided example values and extend the provided steps to adapt them to your specific needs and to align to the recommended best practices.

## Prerequisites

- An account in Google Cloud Platform with permissions for the required GCP services.
- [gcloud cli](https://cloud.google.com/sdk/docs/install-sdk).
- [Kubectl](https://kubernetes.io/docs/tasks/tools/).
- [Helm 3+](https://helm.sh/docs/intro/install/).

**Note**: We use gcloud cli for the steps below, but you can use the Google Cloud web interface, REST API, libraries or any other available methods.

## Steps

### 1. Create a custom Backend health check

When you expose one or more Services through an Ingress using the default Ingress controller, GKE creates a classic Application Load Balancer or an internal Application Load Balancer. Both of these load balancers support multiple backend services on a single URL map. Each of the backend services corresponds to a Kubernetes Service, and each backend service must reference a Google Cloud health check.

The GKE Ingress creates a default health check for each backend service and the backend probes need to return an HTTP 200 (OK) status. It is not possible to change this expected response.

1. To define custom health checks, you can define a custom `BackendConfig` object. 
    We create a custom backend health check using the `spotfire-server-haproxy` stats port (since it returns `200` status as needed). 
   
    You can use the provided example `spotfire-server-haproxy-http-health-check.yaml`:
    ```bash
    apiVersion: cloud.google.com/v1
    kind: BackendConfig
    metadata:
      name: http-health-check-config
    spec:
      healthCheck:
        checkIntervalSec: 10
        port: 1024
        type: HTTP
        requestPath: /stats
    ```
   
    For more information, see [Health checks](https://cloud.google.com/kubernetes-engine/docs/concepts/ingress#health_checks).

2. Apply the custom backend health check configuration:
    ```bash
    kubectl apply \
      -n $NAMESPACE \
      -f spotfire-server-haproxy-http-health-check.yaml
    ```

### 2. Deploy Spotfire

We need to create an ingress with your domain.
We can do it from the `spotfire-server` Helm chart.
After that, we can associate your domain with the external IP address of the created Google Application Load Balancer. 

1. Create an Helm values file using the following `gce-ingress.yaml` example template:
    ```yaml
    configuration:
      site:
        publicAddress: <your domain name>
    haproxy:
      service:
        type: NodePort
        annotations:
          cloud.google.com/neg: '{"ingress": true}'
          cloud.google.com/backend-config: '{"default": "http-health-check-config"}'
    ingress:
      # -- Enables configuration of ingress to expose Spotfire Server. Requires ingress support in the Kubernetes cluster.
      enabled: true
      className: gce
      hosts:
        - host: "<your domain name>"
          paths:
          - path: /
            pathType: Prefix
      # -- Annotations for the ingress object. For valid annotations, see the documentation for your ingress controller.
      # -- Ingress configuration on Google Cloud: https://cloud.google.com/kubernetes-engine/docs/how-to/ingress-configuration
      # -- Ingress GCE FAQ: https://github.com/kubernetes/ingress-gce
      annotations:
        # This tells Google Cloud to create an External Load Balancer to realize this Ingress
        kubernetes.io/ingress.class: gce
        # This enables HTTP connections from Internet clients
        kubernetes.io/ingress.allow-http: "true"
    ```
    **Note**: We use the GCE annotation `cloud.google.com/backend-config` to point to our custom backend health check.

    For more information, see [GKE Ingress for Application Load Balancers](https://cloud.google.com/kubernetes-engine/docs/concepts/ingress) and
   [Ingress configuration on Google Cloud](https://cloud.google.com/kubernetes-engine/docs/how-to/ingress-configuration).

2. Deploy the `spotfire-server` Helm chart using the `gce-ingress.yaml` additional values.
    For example:
    ```bash
    helm upgrade --install my-spotfire-server-release \
      <my-charts-location>/spotfire-server \
      --set global.spotfire.acceptEUA=true \
      --set global.spotfire.image.registry=<my-private-registry> \
      --namespace=$NAMESPACE \
      -f gce-ingress.yaml \
      ...
    ```
   **Note**: The associated Google Application Load Balancer creation takes some minutes.

3. Show the created Spotfire ingress details:
    ```bash
    kubectl describe -n $NAMESPACE ingress spotfire-server
    ```
    And take note of the created Application Load Balancer external IP address.

4. Add a record for the IP address to your DNS matching your configured <your domain name> in your preferred DNS provider.

5. Access the Spotfire UI using your domain: http://&lt;your domain name>.

Congratulations, you have deployed the Spotfire Platform on Google Cloud using
a Google Application Load Balancer with the GKE Ingress controller.

You might continue with some additional steps:
- Check out the [Ingress user guide](https://kubernetes.io/docs/concepts/services-networking/ingress/) for details about Ingress features.
- Configure [static IP and a domain name](https://cloud.google.com/kubernetes-engine/docs/tutorials/configuring-domain-name-static-ip) for your Ingress application using Ingress.
- Using [Google-managed SSL certificates](https://cloud.google.com/kubernetes-engine/docs/how-to/managed-certs)

You can also learn about reference architectures, diagrams, and best practices in Google Cloud in [Cloud Architecture Center](https://cloud.google.com/architecture)

### 3. Cleanup

- To avoid unneeded resource usage, and once you have completed this tutorial, delete any created resources:
    ```bash
    gcloud container clusters delete $CLUSTER_NAME --location $REGION
    gcloud sql instances delete $DB_INSTANCE_NAME
    ...
    ```
   For more information, see [Delete instances](https://cloud.google.com/sql/docs/postgres/delete-instance#gcloud).
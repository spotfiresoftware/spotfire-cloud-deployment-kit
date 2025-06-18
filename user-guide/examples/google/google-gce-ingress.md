# Configuring a Google Network Load Balancer or a Google Application Load Balancer with the GKE Ingress controller

This page provides an overview of the main steps needed to use a [Google Application Load Balancer](https://cloud.google.com/load-balancing/docs/application-load-balancer) with the [GKE Ingress](https://cloud.google.com/kubernetes-engine/docs/concepts/ingress) controller, 
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
- You have completed the previous quickstart:
    - [Deploying Spotfire on Google Kubernetes Engine (GKE)](google-gke.md)

**Note:** The Google Cloud CLI (`gcloud`) is used in the examples below, but you can use the Google Cloud web interface, REST API, libraries or any other available methods.

## Steps

For load balancing in Google Cloud with GKE, you can use:
- [Google Cloud Network Load Balancer](https://cloud.google.com/load-balancing/docs/passthrough-network-load-balancer): Layer 4 load balancing (TCP/SSL/Other)
- [Google Cloud Application Load Balancer](https://cloud.google.com/load-balancing/docs/application-load-balancer): Layer 7 load balancing (HTTP/HTTPS)

For more information, see [Cloud Load Balancing overview](https://cloud.google.com/load-balancing/docs/load-balancing-overview) and
[LoadBalancer Services in the GKE documentation](https://cloud.google.com/kubernetes-engine/docs/concepts/service-load-balancer).

### When to use layer 4 or layer 7 load balancing

- Use layer 4 when:
    - Performance is critical.
    - You do not need advanced routing based on application-layer information.
- Use layer 7 when:
    - You need routing based on HTTP headers, URL paths, or hostnames.
    - SSL/TLS termination is required at the load balancer.

Typically, you can use layer 4 load balancing for testing purposes or smaller deployments.
You can use layer 7 load balancing for an enterprise deployment with advanced routing and SSL/TLS termination.

### Alternative 1: Google Cloud Network Load Balancer direct to GKE service

For simpler scenarios, you might prefer to set up a network Load Balancer together with a K8s service of type `LoadBalancer`.

The [Google Cloud Passthrough Network Load Balancer](https://cloud.google.com/load-balancing/docs/passthrough-network-load-balancer) operates at Layer 4 (TCP/UDP) and can be used to direct traffic from the internet to your GKE cluster.
When you create a service of type `LoadBalancer` in GKE, Google Cloud automatically provisions a Google Cloud Network Load Balancer for that service with a public IP.

#### 1. Deploy Spotfire

1. If not already set, define the following environment variables (as from the previous quickstart):
    ```bash
    export LOCATION=europe-north1
    ```

2. Deploy the `spotfire-platform` Helm chart with the HAProxy service type set to `LoadBalancer`:
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
        --set spotfire-server.haproxy.service.type="LoadBalancer" \
    ...
    ```
    It will take 5-10 minutes to create the associated Google Network Load Balancer.

    For more information, see the [spotfire-platform Helm chart](../../helm/charts/spotfire-platform/README.md).

3. Show the Google Cloud Load Balancer external IP address:
    ```bash
    kubectl get services -n $NAMESPACE
    ```

4. Add a record for the IP address to the DNS matching your configured domain name (as from the example, `spotfire.example.com`) in your DNS provider.
    (For testing purposes, you can just add it to your `/etc/hosts` file or to your local DNS resolver).

5. Access the Spotfire web administration interface using your domain: http://spotfire.example.com.

You have now deployed the Spotfire platform on Google Cloud,
with a Google Cloud Network Load Balancer, using the default reverse proxy service (HAProxy).

### Alternative 2. Google Cloud Application Load Balancer with GKE Ingress Controller

For more advanced routing, you might use an Ingress Controller, which adds flexibility for Layer 7 routing (such as path- or host-based routing) and SSL termination.

You can use Google Cloud Application Gateway together with a [GKE Ingress](https://cloud.google.com/kubernetes-engine/docs/concepts/ingress) in your GKE cluster.

#### 1. Create a custom Backend health check

When you expose one or more Services through an Ingress using the default Ingress controller, GKE creates a classic Application Load Balancer or an internal Application Load Balancer. Both of these load balancers support multiple backend services on a single URL map. Each of the backend services corresponds to a Kubernetes Service, and each backend service must reference a Google Cloud health check.

The GKE Ingress creates a default health check for each backend service and the backend probes must return an HTTP 200 (OK) status. It is not possible to change this expected response.

1. To define custom health checks, you can define a custom `BackendConfig` object.
    Here, we create a custom backend health check using the `spotfire-server-haproxy` stats port (since it returns `200` status as needed).

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

You must create an Ingress with your domain. You can do it directly from the `spotfire-platform` Helm chart.
After that, associate your domain with the external IP address of the created Google Application Load Balancer. 

1. Create a Helm values file using the following `google-gce-ingress.yaml` example template:
    ```yaml
    spotfire-server:
      configuration:
        site:
          publicAddress: http://spotfire.example.com
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
        - host: spotfire.example.com
          paths:
          - path: /
            pathType: Prefix
        # -- Annotations for the ingress object. For valid annotations, see the documentation for your ingress controller.
        # -- Ingress configuration on Google Cloud: https://cloud.google.com/kubernetes-engine/docs/how-to/ingress-configuration
        # -- Ingress GCE FAQ: https://github.com/kubernetes/ingress-gce
        annotations:
          # This tells Google Cloud to create an External Load Balancer to realize his Ingress
          kubernetes.io/ingress.class: gce
          # This enables HTTP connections from Internet clients
          kubernetes.io/ingress.allow-http: "true"
    ```
    **Note:** Here we use the GCE (Google Container Engine) annotation `cloud.google.com/backend-config` to point to our custom backend health check.

    For more information, see [GKE Ingress for Application Load Balancers](https://cloud.google.com/kubernetes-engine/docs/concepts/ingress) and
      [Ingress configuration on Google Cloud](https://cloud.google.com/kubernetes-engine/docs/how-to/ingress-configuration).

2. Deploy the `spotfire-platform` Helm chart using the `google-gce-ingress.yaml` additional values.
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
        -f google-gce-ingress.yaml \
        ...
    ```
    It takes 5-10 minutes to create the associated Google Application Load Balancer.

3. Show the created Spotfire Ingress details:
    ```bash
    kubectl describe -n $NAMESPACE ingress
    ```
    Take note of the created Load Balancer external IP address.

4. Add a record for the IP address to the DNS matching your configured domain name (as from the example, `spotfire.example.com`) in your DNS provider.
    (For testing purposes, you can just add it to your `/etc/hosts` file or to your local DNS resolver).

5. Access the Spotfire web administration interface using your domain: http://spotfire.example.com.

You have now deployed the Spotfire Platform on Google Cloud,
using a Google Application Load Balancer with the GKE Ingress controller.

### Next steps

You might continue with some additional steps:
- Check out the [Ingress user guide](https://kubernetes.io/docs/concepts/services-networking/ingress/) for details about Ingress features.
  - Configure [static IP and a domain name](https://cloud.google.com/kubernetes-engine/docs/tutorials/configuring-domain-name-static-ip) for your Ingress application using Ingress.
  - Use [Google-managed SSL certificates](https://cloud.google.com/kubernetes-engine/docs/how-to/managed-certs).

You can also learn about reference architectures, diagrams, and best practices in Google Cloud in [Cloud Architecture Center](https://cloud.google.com/architecture).

### 3. Cleanup

To avoid unneeded resource usage, once you have completed this tutorial, delete any created resources:
```bash
gcloud container clusters delete $CLUSTER_NAME --location $LOCATION
gcloud sql instances delete $DB_INSTANCE_NAME
...
```
For more information, see [Delete instances](https://cloud.google.com/sql/docs/postgres/delete-instance#gcloud).
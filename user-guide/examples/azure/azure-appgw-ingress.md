# Configuring an Azure Load Balancer or an Azure Application Gateway

This page provides an overview of the main steps needed to use an [Azure Load Balancer](https://learn.microsoft.com/en-us/azure/load-balancer/load-balancer-overview) or an [Azure Application Gateway](https://learn.microsoft.com/en-us/azure/application-gateway/overview)
to deploy the [Spotfire Platform](https://www.spotfire.com/) on [Azure Kubernetes Service (AKS)](https://azure.microsoft.com/en-us/products/kubernetes-service),
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
- You have completed the previous quickstart:
    - [Deploying Spotfire on Azure Kubernetes Service (AKS)](azure-aks.md)

**Note:** The Azure CLI (`az`) is used in the examples below, but you can use the Azure web interface, REST API, libraries or any other available methods.

## Steps

For load balancing in Azure, you can use:
- [Azure Load Balancer](https://learn.microsoft.com/en-us/azure/load-balancer/load-balancer-overview): Layer 4 load balancing (TCP/SSL/Other)
- [Azure Application Gateway](https://learn.microsoft.com/en-us/azure/application-gateway/overview): Layer 7 load balancing (HTTP/HTTPS)

For more information, see [Azure Architecture Center: Load-balancing options](https://learn.microsoft.com/en-us/azure/architecture/guide/technology-choices/load-balancing-overview).

### When to use layer 4 or layer 7 load balancing

- Use layer 4 when:
    - Performance is critical.
    - You do not need advanced routing based on application-layer information.
- Use layer 7 when:
    - You need routing based on HTTP headers, URL paths, or hostnames.
    - SSL/TLS termination is required at the load balancer.

Typically, you can use layer 4 load balancing for testing purposes or smaller deployments.
You can use layer 7 load balancing for an enterprise deployment with advanced routing and SSL/TLS termination.

### Alternative 1: Azure Load Balancer direct to AKS service

For simpler scenarios, you might prefer to set up a network Load Balancer together with a K8s service of type `LoadBalancer`.

The Azure Load Balancer operates at Layer 4 (TCP/UDP) and can be used to direct traffic from the internet to your AKS cluster.
When you create a service of type `LoadBalancer` in AKS, Azure automatically provisions an Azure Load Balancer for that service with a public IP.

#### 1. Deploy Spotfire

1. If not already set, define the following environment variables (as from the previous quickstart):
    ```bash
    export RESOURCE_GROUP=spotfire-quickstart
    export CLUSTER_NAME=my-aks
    export SPOTFIRE_VNET=spotfire-vnet
    ```

2. Deploy the `spotfire-platform` Helm chart with the HAProxy service type set to `LoadBalancer`:
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
        --set spotfire-server.haproxy.service.type="LoadBalancer"
    ```
    **Note:** The associated Azure Load Balancer creation takes 5-10 minutes.

    For more information, see the [spotfire-platform Helm chart](../../helm/charts/spotfire-platform/README.md).

3. Show the Azure Load Balancer external IP address:
    ```bash
    kubectl get services -n $NAMESPACE
    ```

4. Add a record for the IP address to the DNS matching your configured domain name (as from the example, `spotfire.example.com`) in your DNS provider.
    (For testing purposes, you can just add it to your `/etc/hosts` file or to your local DNS resolver).

5. Access the Spotfire web administration interface using your domain: http://spotfire.example.com.

You have now deployed the Spotfire platform on Azure,
with an Azure Load Balancer, using the default reverse proxy service (HAProxy).

For more information, see [Load Balancer in AKS](https://learn.microsoft.com/en-us/azure/aks/load-balancer-standard).

### Alternative 2. Azure Application Gateway as Ingress Controller

For more advanced routing, you might use an Ingress Controller, which adds flexibility for Layer 7 routing (such as path- or host-based routing) and SSL termination.

You can use Azure Application Gateway together with an [Application Gateway Ingress Controller (AGIC)](https://learn.microsoft.com/en-us/azure/application-gateway/ingress-controller-overview) in your AKS cluster.

**Note:** You can use other Ingress Controllers, see [Ingress in Azure Kubernetes Service (AKS)](https://learn.microsoft.com/en-us/azure/aks/concepts-network-ingress).

#### 1. Create an Azure Application Gateway

1. If not already set, define the following environment variables (as from the previous quickstart):
    ```bash
    export RESOURCE_GROUP=spotfire-quickstart
    export CLUSTER_NAME=my-aks
    export SPOTFIRE_VNET=spotfire-vnet
    ```

2. Create a public IP, and an Azure Application Gateway in its own virtual network:
    ```bash
    export APPGW_VNET=appgw-vnet
    export APPGW_SUBNET=appgw-subnet
    export APPGW_NAME=myApplicationGateway

    az network vnet subnet create \
        --name $APPGW_SUBNET \
        --vnet-name $SPOTFIRE_VNET \
        --resource-group $RESOURCE_GROUP \
        --address-prefix 10.10.3.0/24

    az network public-ip create \
        --name spotfire-pip \
        --resource-group $RESOURCE_GROUP \
        --allocation-method Static \
        --sku Standard
    az network vnet create --name $APPGW_VNET \
        --resource-group $RESOURCE_GROUP \
        --address-prefix 10.0.0.0/16 \
        --subnet-name $APPGW_SUBNET \
        --subnet-prefix 10.0.0.0/24

    az network application-gateway create --name $APPGW_NAME \
        --resource-group $RESOURCE_GROUP \
        --sku Standard_v2 \
        --public-ip-address spotfire-pip \
        --vnet-name $SPOTFIRE_VNET  \
        --subnet $APPGW_SUBNET \
        --priority 100
    ```

    **Note:** The associated Azure Application Gateway creation takes 5-10 minutes.

    **Note:** The Application Gateway Ingress Controller (AGIC) add-on only supports application gateway v2 SKUs (Standard and WAF), and not the application gateway v1 SKUs.

3. Enable the AGIC add-on in your existing AKS cluster:
    ```bash
    appgwId=$(az network application-gateway show \
        --name $APPGW_NAME \
        --resource-group $RESOURCE_GROUP \
        -o tsv --query "id")
    az aks enable-addons --name $CLUSTER_NAME \
        --resource-group $RESOURCE_GROUP \
        --addon ingress-appgw \
        --appgw-id $appgwId
    ```

4. Peer both AKS and Azure Application Gateway virtual networks together:
    ```bash
    aksVnetId=$(az network vnet show \
        --name $SPOTFIRE_VNET \
        --resource-group $RESOURCE_GROUP \
        -o tsv --query "id")
    az network vnet peering create \
        --name AppGWtoAKSVnetPeering \
        --resource-group $RESOURCE_GROUP \
        --vnet-name $APPGW_VNET \
        --remote-vnet $aksVnetId \
        --allow-vnet-access

    appGWVnetId=$(az network vnet show \
        --name $APPGW_VNET \
        --resource-group $RESOURCE_GROUP \
        -o tsv --query "id")
    az network vnet peering create \
        --name AKStoAppGWVnetPeering \
        --resource-group $RESOURCE_GROUP \
        --vnet-name $SPOTFIRE_VNET \
        --remote-vnet $appGWVnetId \
        --allow-vnet-access
    ```

For more information, see [Enable application gateway ingress controller add-on for an existing AKS cluster](https://learn.microsoft.com/en-us/azure/application-gateway/tutorial-ingress-controller-add-on-existing).

#### 2. Deploy Spotfire

You need to create an ingress with your domain and associate it with the created Azure Application Gateway, using the Application Gateway Ingress Controller (AGIC).
You can do it directly from the `spotfire-platform` Helm chart.

1. Create a Helm values file using the following `azure-appgw-ingress.yaml` example template:
    ```yaml
    spotfire-server:
      configuration:
        site:
          publicAddress: http://spotfire.example.com
      haproxy:
        service:
          type: NodePort
      ingress:
        # -- Enables configuration of ingress to expose Spotfire Server. Requires ingress support in the Kubernetes cluster.
        enabled: true
        ingressClassName: azure-application-gateway
        hosts:
        - host: spotfire.example.com
          paths:
          - path: /
            pathType: Prefix
        # -- Annotations for the ingress object. For valid annotations, see the documentation for your ingress controller.
        annotations:
          appgw.ingress.kubernetes.io/cookie-based-affinity: "true"
          # appgw.ingress.kubernetes.io/ssl-redirect: "true"
          # appgw.ingress.kubernetes.io/appgw-ssl-certificate
          # ...
    ```

    For more information, see [Annotations for Application Gateway Ingress Controller](https://learn.microsoft.com/en-us/azure/application-gateway/ingress-controller-annotations).

2. Deploy the `spotfire-platform` Helm chart using the `azure-appgw-ingress.yaml` additional values.
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
        -f azure-appgw-ingress.yaml
    ```
    For more information, see the [spotfire-platform Helm chart](../../helm/charts/spotfire-platform/README.md).

3. Show the created Spotfire ingress details:
    ```bash
    kubectl describe -n $NAMESPACE ingress
    ```
    And take note of the created Load Balancer external IP address.

4. Add a record for the IP address to the DNS matching your configured domain name (as from the example, `spotfire.example.com`) in your DNS provider.
    (For testing purposes, you can just add it to your `/etc/hosts` file or to your local DNS resolver).

5. Access the Spotfire web administration interface using your domain: http://spotfire.example.com.

You have now deployed the Spotfire platform on Azure,
using an Azure Application Gateway together with the Application Gateway Ingress Controller (AGIC).

### Next steps

You might continue with some additional steps:
- Check out the [Ingress user guide](https://kubernetes.io/docs/concepts/services-networking/ingress/) for details about Ingress features.
- [Azure DNS](https://learn.microsoft.com/en-us/azure/dns/).
- [Overview of TLS termination and end to end TLS with Application Gateway](https://learn.microsoft.com/en-us/azure/application-gateway/ssl-overview).

You can learn about reference architectures, diagrams, and best practices in Azure in [Azure Architecture Center: Best practices](https://learn.microsoft.com/en-us/azure/architecture/best-practices/index-best-practices).

## Cleanup

To avoid unneeded resource usage, once you have completed this tutorial, delete any created resources:
```bash
az network application-gateway delete --name $APPGW_NAME --resource-group $RESOURCE_GROUP 
...
```
For more information, see [Delete Azure Application Gateway](https://learn.microsoft.com/en-us/cli/azure/network/application-gateway?view=azure-cli-latest#az-network-application-gateway-delete).

You can also remove all the resources within a resource group with a single command:
```bash
az group delete --name $RESOURCE_GROUP --yes --no-wait
```

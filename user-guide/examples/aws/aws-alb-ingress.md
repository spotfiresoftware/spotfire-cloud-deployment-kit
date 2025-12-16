# Configuring an AWS Network Load Balancer (NLB) or an AWS Application Load Balancer (ALB) with the AWS Ingress Controller

## Overview

This page provides an overview of the main steps needed to use a [AWS Elastic Load Balancer](https://aws.amazon.com/elasticloadbalancing/),
to deploy the [Spotfire Platform](https://www.spotfire.com/) on [AWS Elastic Kubernetes Service (EKS)](https://aws.amazon.com/eks/),
using the [Spotfire CDK](https://github.com/spotfiresoftware/spotfire-cloud-deployment-kit).

This is a quickstart guide.
For more information, see the official documentation.
Always follow the documentation and recommended best practices from the vendor.

Remember to change the provided example values to adapt them to your own environment and needs.

## Prerequisites

- An account in AWS with permissions for the required services
- A Linux host with the following clients installed:
    - [Amazon CLI](https://aws.amazon.com/cli/)
    - [AWS ekscli](https://docs.aws.amazon.com/eks/latest/userguide/eksctl.html)
    - [Kubectl](https://kubernetes.io/docs/tasks/tools/)
    - [Helm 3+](https://helm.sh/docs/intro/install/)
- You have completed the previous quickstart:
    - [Deploy Spotfire on AWS Elastic Kubernetes Service (EKS)](aws-eks.md)

**Note:** The AWS CLI (`aws`) and `ekscli` are used in the examples below, but you can use the AWS web interface, REST API, libraries or any other available methods.

## Steps

For load balancing in AWS with EKS, you can use:

- [Network Load Balancer (NLB)](https://docs.aws.amazon.com/elasticloadbalancing/latest/network/introduction.html): Layer 4 load balancing (TCP/SSL/Other)
- [Application Load Balancer (ALB)](https://docs.aws.amazon.com/elasticloadbalancing/latest/application/introduction.html): Layer 7 load balancing (HTTP/HTTPS)

For more information, see the [AWS Load Balancer documentation](https://docs.aws.amazon.com/elasticloadbalancing/latest/userguide/what-is-load-balancing.html).

### When to use layer 4 or layer 7 load balancing

- Use layer 4 when:
    - Performance is critical.
    - You do not need advanced routing based on application-layer information.
- Use layer 7 when:
    - You need routing based on HTTP headers, URL paths, or hostnames.
    - SSL/TLS termination is required at the load balancer.

Typically, you can use layer 4 load balancing for testing purposes or smaller deployments.
You can use layer 7 load balancing for an enterprise deployment with advanced routing and SSL/TLS termination.

### Alternative 1: AWS Network Load Balancer (NLB)

For simpler scenarios, you might prefer to set up a network Load Balancer together with a K8s service of type `LoadBalancer`.

The [AWS Network Load Balancer](https://docs.aws.amazon.com/elasticloadbalancing/latest/network/introduction.html) operates at the network layer (Layer 4) and can be used to direct traffic from the internet to your EKS cluster.

1. Create an AWS Network Load Balancer:
    ```bash
    export NLB_NAME=my-nlb
    export VPC_ID=<vpc-id>
    export SUBNET_ID=<subnet-id>

    aws elbv2 create-load-balancer \
        --name $NLB_NAME \
        --type network \
        --scheme internet-facing \
        --subnets $SUBNET_ID \
        --tags Key=Name,Value=$NLB_NAME
    ```

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
        --version "{{ SPOTFIRE_PLATFORM_CHART_VERSION }}" \
        --namespace=$NAMESPACE \
        --set global.spotfire.acceptEUA=true \
        --set global.spotfire.image.registry=$REGISTRY_SERVER \
        --set global.spotfire.image.pullSecrets[0]=$REGISTRY_SECRET \
        --set spotfire-server.configuration.site.publicAddress=http://spotfire.example.com \
        --set spotfire-server.haproxy.service.type="LoadBalancer"
    ```
   It will take 5-10 minutes to create the associated AWS Network Load Balancer.

   For more information, see the [spotfire-platform Helm chart](../../helm/charts/spotfire-platform/README.md).

3. Show the AWS Load Balancer external IP address:
    ```bash
    kubectl get services -n $NAMESPACE
    ```

4. Add a record for the IP address to the DNS matching your configured domain name (as from the example, `spotfire.example.com`) in your DNS provider.
   (For testing purposes, you can just add it to your `/etc/hosts` file or to your local DNS resolver).

5. Access the Spotfire web administration interface using your domain: http://spotfire.example.com.

You have now deployed the Spotfire platform on AWS,
with an AWS Network Load Balancer, using the default reverse proxy service (HAProxy).

### Alternative 2. AWS Application Load Balancer (ALB) with the AWS Ingress Controller

For more advanced routing, you might use an Ingress Controller, which adds flexibility for Layer 7 routing (such as path- or host-based routing) and SSL termination.

You can use an [Application Load Balancer (ALB)](https://docs.aws.amazon.com/elasticloadbalancing/latest/application/introduction.html) together with an [AWS Ingress](https://kubernetes-sigs.github.io/aws-load-balancer-controller) in your EKS cluster.

#### 1. Install the AWS Load Balancer Controller

1. Download the IAM policy required for the AWS Load Balancer Controller:
    ```bash
    curl -O https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.12.0/docs/install/iam_policy.json
    ```

2. Create the IAM Policy:
    ```bash
    aws iam create-policy \
        --policy-name AWSLoadBalancerControllerIAMPolicy \
        --policy-document file://iam_policy.json
    ```

3. Create an IAM role for the controller and attach the policy to it:
    ```bash
    export ACCOUNT_ID=<account-id>

    eksctl utils associate-iam-oidc-provider \
        --region=$REGION \
        --cluster=$CLUSTER_NAME \
        --approve
    eksctl create iamserviceaccount \
        --cluster=$CLUSTER_NAME \
        --namespace=kube-system \
        --name=aws-load-balancer-controller \
        --attach-policy-arn=arn:aws:iam::$ACCOUNT_ID:policy/AWSLoadBalancerControllerIAMPolicy \
        --override-existing-serviceaccounts \
        --region $REGION \
        --approve
    ```

4. Install the AWS Load Balancer Controller:
    ```bash
    helm repo add eks https://aws.github.io/eks-charts
    helm repo update
    helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
        -n kube-system \
        --set clusterName=$CLUSTER_NAME \
        --set serviceAccount.create=false \
        --set serviceAccount.name=aws-load-balancer-controller
    ```

For more information, see [Install AWS Load Balancer Controller with Helm](https://docs.aws.amazon.com/eks/latest/userguide/lbc-helm.html) and [AWS Load Balancer Controller installation](https://kubernetes-sigs.github.io/aws-load-balancer-controller/latest/deploy/installation/).

#### 2. Deploy Spotfire

You must create an Ingress with your domain. You can do it directly from the `spotfire-platform` Helm chart.
After that, associate your domain with the external IP address of the created AWS Application Load Balancer (ALB).

1. Create a Helm values file using the following `aws-alb-ingress.yaml` example template:
    ```yaml
    spotfire-server:
      configuration:
        site:
          publicAddress: http://spotfire.example.com
      haproxy:
        service:
          type: NodePort
          annotations:
            # AWS-specific annotations for the Service
            service.beta.kubernetes.io/aws-load-balancer-type: "alb"
            service.beta.kubernetes.io/aws-load-balancer-scheme: "internet-facing"  # Use "internal" for internal ALB
      ingress:
        # -- Enables configuration of ingress to expose Spotfire Server. Requires ingress support in the Kubernetes cluster.
        enabled: true
        className: alb
        hosts:
          - host: spotfire.example.com
            paths:
              - path: /
                pathType: Prefix
        # -- Annotations for the ingress object. For valid annotations, see the documentation for your ingress controller.
        # -- Ingress annotations page (https://kubernetes-sigs.github.io/aws-load-balancer-controller/v2.2/guide/ingress/annotations/#annotations).
        annotations:
          # This tells AWS to create an Application Load Balancer (ALB) to realize this Ingress
          kubernetes.io/ingress.class: alb
          # This enables HTTP connections from Internet clients
          alb.ingress.kubernetes.io/scheme: internet-facing  # Use "internal" for internal ALB
          # Optional: Enable HTTP to HTTPS redirection
          #alb.ingress.kubernetes.io/listen-ports: '[{"HTTP": 80}, {"HTTPS": 443}]'
          #alb.ingress.kubernetes.io/actions.ssl-redirect: '{"Type": "redirect", "RedirectConfig": { "Protocol": "HTTPS", "Port": "443", "StatusCode": "HTTP_301"}}'
          # Optional: Attach a TLS certificate for HTTPS
          #alb.ingress.kubernetes.io/certificate-arn: arn:aws:acm:region:account-id:certificate/certificate-id
    ```

    For more information, see [Annotations for Application Load Balancer Ingress Controller](https://kubernetes-sigs.github.io/aws-load-balancer-controller/v2.7/guide/ingress/annotations/).

2. Deploy the `spotfire-platform` Helm chart using the `aws-alb-ingress.yaml` additional values.
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
        -f aws-alb-ingress.yaml
    ```
   It takes 5-10 minutes to create the associated AWS Application Load Balancer.

3. Show the created Spotfire Ingress details:
    ```bash
    kubectl describe -n $NAMESPACE ingress
    ```
   Take note of the created Load Balancer external IP address.

4. Add a record for the IP address to the DNS matching your configured domain name (as from the example, `spotfire.example.com`) in your DNS provider.
   (For testing purposes, you can just add it to your `/etc/hosts` file or to your local DNS resolver).

5. Access the Spotfire web administration interface using your domain: http://spotfire.example.com.

You have now deployed the Spotfire platform on AWS,
using an AWS Application Load Balancer (ALB) with the AWS Ingress Controller.

### Next steps

You might continue with some additional steps:
- Check out the [Ingress user guide](https://kubernetes.io/docs/concepts/services-networking/ingress/) for details about Ingress features.
    - Configure [static IP and a domain name](https://kubernetes.io/docs/concepts/services-networking/ingress/#name-based-virtual-hosting) for your Ingress.
    - Use [AWS ACM](https://docs.aws.amazon.com/acm/latest/userguide/acm-overview.html) to manage SSL/TLS certificates for your ALB.

You can also learn about reference architectures, diagrams, and best practices in the [AWS Architecture Center](https://aws.amazon.com/architecture/) and [EKS best practices guide for Load Balancing](https://docs.aws.amazon.com/eks/latest/best-practices/load-balancing.html)

### 3. Cleanup

To avoid unneeded resource usage, once you have completed this tutorial, delete any created resources:
```bash
eksctl delete cluster --name $CLUSTER_NAME
aws elbv2 delete-load-balancer --load-balancer-arn $LB_ARN
...
```

For more information, see the [AWS EKS documentation](https://docs.aws.amazon.com/eks/latest/userguide/delete-cluster.html) and [AWS Load Balancer documentation](https://docs.aws.amazon.com/elasticloadbalancing/latest/application/application-load-balancer-delete.html).

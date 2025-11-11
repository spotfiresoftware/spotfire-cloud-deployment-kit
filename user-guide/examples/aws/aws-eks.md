# Deploying Spotfire on Amazon Elastic Kubernetes Service (EKS)

This page provides an overview of the main steps needed to prepare an environment in AWS and to deploy the [Spotfire Platform](https://www.spotfire.com/) on [Amazon Elastic Kubernetes Service (EKS)](https://docs.aws.amazon.com/eks/),
using the [Spotfire CDK](https://github.com/spotfiresoftware/spotfire-cloud-deployment-kit).

You will deploy the Spotfire Platform on AWS using the following services:
- Kubernetes cluster: [Amazon Elastic Kubernetes Service (EKS)](https://aws.amazon.com/eks/).
- Database server: [Amazon RDS for PostgreSQL](https://aws.amazon.com/rds/postgresql/).
- Blob storage: [Amazon S3](https://aws.amazon.com/s3/).
- Load balancer: [Amazon Elastic Load Balancer (ELB)](https://aws.amazon.com/elasticloadbalancing/).

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

**Note:** The AWS CLI (`aws`) and `ekscli` are used in the examples below, but you can use the AWS web interface, REST API, libraries or any other available methods.

## Steps

### 1. Prepare your AWS environment

- Login to your AWS account and set up your project:
    ```bash
    aws sso login
    export REGION=eu-north-1
    ```

### 2. Create an EKS cluster

1. Define the variables for your cluster:
    ```bash
    export CLUSTER_NAME=my-eks
    export NODE_TYPE=m5.xlarge
    export NUM_NODES=2
    ```

    **Note:** In this example we create a 3-nodes cluster using the `m5.xlarge` virtual machine type (8 vCPUs, 32 GB).
    See the [Amazon EC2 Instance types](https://aws.amazon.com/ec2/instance-types/) to understand which SKU you need for your K8s nodes.
    The AWS M-Family of machines are general purpose VMs for Enterprise-grade containerized applications.

    **Note:** See the [Spotfire system requirements](https://spotfi.re/sr) for the minimum and recommended sizing.
    Observe your K8s resource utilization to understand which node size and how many nodes do you need.

2. Create the Amazon Elastic Kubernetes Service (EKS):
    ```bash
    eksctl create cluster \
        --name $CLUSTER_NAME \
        --region $REGION \
        --nodegroup-name $CLUSTER_NAME-nodes \
        --node-type $NODE_TYPE \
        --nodes $NUM_NODES
    ```

    It will take ~10-15 minutes to create the K8s cluster.

    For more information, see [Get started with Amazon EKS – eksctl](https://docs.aws.amazon.com/eks/latest/userguide/getting-started-eksctl.html).

3. After creating the cluster, you must configure `kubectl` to use the new EKS cluster:
    ```bash
    aws eks update-kubeconfig \
       --region $REGION \
       --name $CLUSTER_NAME
    ```

4. Verify that you can connect to the cluster using `kubectl`:
    ```bash
    kubectl get nodes -o wide
    aws eks describe-cluster \
        --region $REGION \
        --name $CLUSTER_NAME
    ```

For more information, see the [Amazon Elastic Kubernetes Service Documentation](https://docs.aws.amazon.com/eks/).

You can learn about reference architectures, diagrams, and best practices in the [AWS Architecture Center](https://aws.amazon.com/architecture/).

See also the [Amazon EKS Best Practices Guide](https://docs.aws.amazon.com/eks/latest/best-practices/introduction.html).

### 3. Deploy Spotfire

1. Create a namespace for your deployment:
    ```bash
    export NAMESPACE=spotfire-quickstart
    kubectl create namespace $NAMESPACE
    ```

2. Create a pull secret for the Spotfire container registry:
    ```bash
    export REGISTRY_SERVER=oci.spotfire.com
    export REGISTRY_SECRET=spotfire-oci-secret
    export REGISTRY_USERNAME=<username>
    export REGISTRY_PASSWORD=<password>

    kubectl create secret docker-registry $REGISTRY_SECRET \
        --namespace $NAMESPACE \
        --docker-server=$REGISTRY_SERVER \
        --docker-username=$REGISTRY_USERNAME \
        --docker-password=$REGISTRY_PASSWORD
    ```
    The secret is used by the Kubernetes cluster to pull the Spotfire container images from the Spotfire OCI registry.

3. Log in to the Spotfire Helm charts registry:
    ```bash
    helm registry login -u $REGISTRY_USERNAME oci.spotfire.com/charts
    ```
   This is needed to access the Spotfire Helm charts in the Spotfire OCI registry.

4. Deploy the Spotfire Platform using the `spotfire-platform` Helm chart.
    For example:
    ```bash
    export MY_SPOTFIRE_RELEASE=vanilla-spotfire

    helm upgrade --install $MY_SPOTFIRE_RELEASE \
        oci://$REGISTRY_SERVER/charts/spotfire-platform \
        --version 2.0.0 \
        --namespace=$NAMESPACE \
        --set global.spotfire.acceptEUA=true \
        --set global.spotfire.image.registry=$REGISTRY_SERVER \
        --set global.spotfire.image.pullSecrets[0]=$REGISTRY_SECRET \
        --set spotfire-server.configuration.site.publicAddress=http://spotfire.example.com \
        --set postgresql.enabled=true
    ```
    For more information, see the [spotfire-platform Helm chart](../../helm/charts/spotfire-platform/README.md).

You have now deployed the Spotfire platform on AWS,
using Amazon Elastic Kubernetes Service (EKS).

### 4. Next steps

You can now continue with:
- [Configuring an Amazon Network Load Balancer or an Amazon Application Load Balancer](aws-alb-ingress.md).
- [Configuring an Amazon RDS for PostgreSQL database as the Spotfire database](aws-rds-postgres.md).
- [Configuring an Amazon S3 bucket as the Spotfire external library storage](aws-s3.md).

## Cleanup

To avoid unneeded resource usage, once you have completed these tutorials, delete any created resources:
```bash
eksctl delete cluster --name $CLUSTER_NAME
...
```
For more information, see [Delete an Amazon EKS cluster](https://docs.aws.amazon.com/eks/latest/userguide/delete-cluster.html).




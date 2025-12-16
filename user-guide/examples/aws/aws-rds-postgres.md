
# Configuring an Amazon RDS as the Spotfire database

This page provides an overview of the main steps to use a [Amazon RDS for PostgreSQL](https://aws.amazon.com/rds/postgresql/) instance as the Spotfire database
to deploy the [Spotfire Platform](https://www.spotfire.com/) on [AWS Elastic Kubernetes Service (EKS)](https://aws.amazon.com/eks/),
using the [Spotfire CDK](https://github.com/spotfiresoftware/spotfire-cloud-deployment-kit).

This is a quickstart guide.
For more information, see the official documentation.
Always follow the documentation and recommended best practices from the vendor.

Remember to change the provided example values to adapt them to your own environment and needs.

## Prerequisites

- An account in AWS with permissions for the required services.
- A Linux host with the following clients installed:
    - [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html).
    - [Kubectl](https://kubernetes.io/docs/tasks/tools/).
    - [Helm 3+](https://helm.sh/docs/intro/install/).
- You have completed the previous quickstarts:
    - [Deploying Spotfire on Amazon Elastic Kubernetes Service (EKS)](aws-eks.md).
    - [Configuring an AWS Network Load Balancer (NLB) or an AWS Application Load Balancer (ALB) with the AWS Ingress Controller](aws-alb-ingress.md).

**Note:** The AWS CLI (`awscli`) is used in the examples below, but you can use the AWS web interface, REST API, libraries or any other available methods.

## Steps

### 1. Create an AWS RDS for PostgreSQL database

Create a relational database instance in the AWS account, choosing the correct VPC that is associated with the EKS cluster.
For simplicity, in this quickstart we create the database in the same VPC as the EKS cluster, see [here](aws-eks.md).

For more information, see [Creating an Amazon RDS DB instance](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER_CreateDBInstance.html).

**Note:** To migrate an existing PostgreSQL database to Amazon RDS for PostgreSQL, see the instructions at [https://aws.amazon.com/tutorials/move-to-managed/migrate-postgresql-to-amazon-rds/](https://aws.amazon.com/tutorials/move-to-managed/migrate-postgresql-to-amazon-rds/).

1. Identify the private subnets in your EKS VPC:
    ```bash
    PRIVATE_SUBNETS=$(aws ec2 describe-subnets \
        --filters "Name=tag:Name,Values=*Private*" "Name=tag:alpha.eksctl.io/cluster-name,Values=$CLUSTER_NAME" \
        --query 'Subnets[*].SubnetId' \
        --output text)
    echo "Private Subnets: $PRIVATE_SUBNETS"
    ```

2. Create a DB subnet group:
    ```bash
    export DB_SUBNET_GROUP_NAME=<eks-rds-subnet-group>

    aws rds create-db-subnet-group \
        --db-subnet-group-name $DB_SUBNET_GROUP_NAME \
        --db-subnet-group-description "Subnet group for RDS accessible from EKS" \
        --subnet-ids $PRIVATE_SUBNETS
    ```

3. Create a Security Group for RDS:
    ```bash
    export SECURITY_GROUP_NAME=<eks-rds-sg>

    aws ec2 create-security-group \
        --group-name $SECURITY_GROUP_NAME \
        --description "Security group for RDS accessible from EKS" \
        --vpc-id $VPC_ID
   
    SECURITY_GROUP_ID=$(aws ec2 describe-security-groups \
        --filters Name=group-name,Values=$SECURITY_GROUP_NAME \
        --query 'SecurityGroups[0].GroupId' \
        --output text)
    echo $SECURITY_GROUP_ID

    # Get the cluster security group ID (managed by EKS)
    EKS_CLUSTER_SG=$(aws eks describe-cluster --name $CLUSTER_NAME \
        --query "cluster.resourcesVpcConfig.clusterSecurityGroupId" \
        --output text)
    echo "EKS Cluster Security Group ID: $EKS_CLUSTER_SG"

    aws ec2 authorize-security-group-ingress \
        --group-id $SECURITY_GROUP_ID \
        --protocol tcp \
        --port 5432 \
        --source-group $EKS_CLUSTER_SG
    ```

4. Create a Cloud SQL for PostgreSQL instance with a private IP address:
    ```bash
    export DB_INSTANCE_NAME=<db-instance-name>
    export DB_ADMIN_PASSWORD=<changeAdminPassword> # more than 8 characters
    export MACHINE_TYPE=db.m4.large # 2 vCPUs, 8 GB RAM

    aws rds create-db-instance \
        --db-instance-identifier $DB_INSTANCE_NAME \
        --db-instance-class $MACHINE_TYPE \
        --engine postgres \
        --engine-version 16 \
        --allocated-storage 20 \
        --master-username postgres \
        --master-user-password $DB_ADMIN_PASSWORD \
        --vpc-security-group-ids $SECURITY_GROUP_ID \
        --db-subnet-group-name $DB_SUBNET_GROUP_NAME \
        --no-publicly-accessible \
        --backup-retention-period 7
    ```
    It will take a few minutes to create the RDS instance.
    You can monitor the RDS instance creation with:
    ```bash
    watch -n 30 "aws rds describe-db-instances \
        --db-instance-identifier  $DB_INSTANCE_NAME \
        --query \"DBInstances[0].[DBInstanceStatus, DBInstanceArn, Endpoint.Address]\" \
        --output text"
    ```

    **Note:** Adjust the database version and sizing according with your needs.
    See available [AWS DB instance classes](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Concepts.DBInstanceClass.Summary.html).

    See [Introduction to Amazon RDS](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Welcome.html) to understand which edition you need for your database.

### 2. Deploy Spotfire

1. Create a helm values file using the following `aws-rds-postgres.yaml` example template:
    ```yaml
    spotfire-server:
      database:
        bootstrap:
          databaseUrl: "jdbc:postgresql://<db-instance-name-endpoint>:5432/<db-instance-name>"
          username: "<changeAdminUsername>"
          adminPassword: "<changeAdminPass>"
        create-db:
          adminUsername: "<changeAdminUsername>"
          adminPassword: "<changeAdminPass>"
          databaseUrl: "jdbc:postgresql://<db-instance-name>:5432/"
          doNotCreateUser: true
          spotfiredbDbname: "<db-instance-name>"
    ```

2. Deploy the `spotfire-platform` Helm chart using the `aws-rds-postgres.yaml` additional values.
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
        -f aws-rds-postgres.yaml
    ```

    For more information, see the [spotfire-platform Helm chart](../../helm/charts/spotfire-platform/README.md).

You have now deployed the Spotfire platform on AWS,
using an AWS RDS for PostgreSQL instance as the Spotfire database.

You can learn about reference architectures, diagrams, and best practices in AWS in [AWS Architecture Center](https://aws.amazon.com/architecture).

## Cleanup

To avoid unneeded resource usage, once you have completed this tutorial, delete any created resources:
```bash
eksctl delete cluster --name $CLUSTER_NAME
aws rds delete-db-instance --db-instance-identifier $DB_INSTANCE_NAME --skip-final-snapshot
```
For more information, see [Deleting a DB instance](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER_DeleteInstance.html).

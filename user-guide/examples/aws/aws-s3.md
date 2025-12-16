# Configuring an AWS S3 bucket as the Spotfire external library storage

This page provides an overview of the main steps to use a [Amazon S3 bucket](https://aws.amazon.com/s3)
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
    - [Configuring an Amazon RDS as the Spotfire database](aws-rds-postgres.md).

**Note:** The AWS CLI (`awscli`) is used in the examples below, but you can use the AWS web interface, REST API, libraries or any other available methods.

## Steps

### Back up the database and export the library contents

Execute this step only if the Spotfire environment is already deployed on the EKS cluster with a database as backend library storage, and if you want to migrate it to Amazon S3. Otherwise, move to the next step.

1. Back up the Spotfire database.
   In the `spotfire-cli` pod, export the Spotfire Library contents and remove the content from the library. See [Configuring external library storage in AWS](https://docs.tibco.com/pub/spotfire_server/latest/doc/html/TIB_sfire_server_tsas_admin_help/server/topics/configuring_external_library_storage_in_aws.html).

   **Note:** For large size library content, configure the [volume for library export and import](../../helm/charts/spotfire-server/README.md#volume-for-library-export-and-import).

- If the volume mount is not configured, copy the exported library zip file to your local computer. For more information, see [kubectl cp command reference ](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#cp).

- If the secrets are not auto-generated, make a note of them by running the command.
    ```bash
    kubectl get secrets <releaseName>-spotfire-platform -n <namespace> -o yaml
    ```

### 1. Create an AWS S3 bucket

1. Create an AWS S3 bucket.
   For more information, see [Creating a bucket](https://docs.aws.amazon.com/AmazonS3/latest/userguide/create-bucket-overview.html).

2. Create a policy with Read/Write access to the S3 bucket object.
   For more information, see [Amazon S3: Allows read and write access to objects in an S3 Bucket](https://docs.aws.amazon.com/IAM/latest/UserGuide/reference_policies_examples_s3_rw-bucket.html).

3. Create an OpenID Connect (OIDC) identity provider with audience `sts.amazonaws.com`.
   For more information, see [Creating an IAM OIDC provider for your cluster](https://docs.aws.amazon.com/eks/latest/userguide/enable-iam-roles-for-service-accounts.html).

4. Create a web identity IAM role for the service account `<releaseName>-spotfire-platform` and attach to this role the Read/Write access policy created in step 2.
   For more information, see [IAM roles for service accounts](https://docs.aws.amazon.com/eks/latest/userguide/iam-roles-for-service-accounts.html).

   Example: Assume role trust policy on the web identity role for the service account `<releaseName>-spotfire-platform`:
    ```json
    {
      "Version": "2012-10-17",
      "Statement": [
        {
          "Action": "sts:AssumeRoleWithWebIdentity",
          "Effect": "Allow",
          "Sid": "",
          "Principal": {
            "Federated": "<identity provider ARN>"
          },
          "Condition": {
            "StringLike": {
              "<provider>:sub": [
                "system:serviceaccount:<Namespace>:<releaseName>-spotfire-platform"
              ]
            }
          }
        }
      ]
    }
    ```

   **Note:** The value for "\<provider\>" can be found on the summary page of the newly-created identity provider in step 3.

### 3. Deploy Spotfire


1. Create a Helm values file using the following `aws-s3-bucket.yaml` example template:
    ```yaml
    spotfire-server:
      serviceAccount:
        annotations:
          eks.amazonaws.com/role-arn: "<Web identity IAM role ARN>"
      configuration:
        configurationScripts:
        - name: config-library-external-s3-storage
          # https://docs.tibco.com/pub/spotfire_server/latest/doc/html/TIB_sfire_server_tsas_admin_help/server/topics/config-library-external-s3-storage.html
          script: |
            config-library-external-s3-storage \
              --region="<S3 bucket region>" \
              --bucket-name="<S3 bucket name>" \
              --key-prefix="spotfire-library/" \
              --access-key="default" \
              --secret-key="NONE" \
              --bootstrap-config="${BOOTSTRAP_FILE}"
        - name: config-library-external-data-storage
          # https://docs.tibco.com/pub/spotfire_server/latest/doc/html/TIB_sfire_server_tsas_admin_help/server/topics/config-library-external-data-storage.html
          script: |
            config-library-external-data-storage \
              --tool-password="${TOOL_PASSWORD}" \
              --enabled=true \
              --external-storage=AMAZON_S3 \
              --bootstrap-config="${BOOTSTRAP_FILE}"
    ```

   For more information, see the [config-library-external-data-storage](https://docs.tibco.com/pub/spotfire_server/latest/doc/html/TIB_sfire_server_tsas_admin_help/server/topics/config-library-external-data-storage.html) and [config-library-external-s3-blob-storage](https://docs.tibco.com/pub/spotfire_server/latest/doc/html/TIB_sfire_server_tsas_admin_help/server/topics/config-library-external-s3-storage.html) documentation.

2. Deploy the `spotfire-platform` Helm chart using the `aws-s3-bucket.yaml` values file.
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
        -f aws-rds-postgres.yaml \
        -f aws-s3-bucket.yaml
    ```
   For more information, see the [spotfire-platform Helm chart](../../helm/charts/spotfire-platform/README.md).

You have now deployed the Spotfire platform on AWS,
using an AWS S3 bucket as the Spotfire external library storage.

**Note**: If the release is already installed, then use the command `helm upgrade --install` in place of `helm install`, along with the following additional parameters:
- `--set configuration.apply=always`
- `--set database.create-db.enabled=false ...`

**Note** To reflect the service account annotation change on the pod, the old Spotfire Server and the cli pod are re-created (either by deleting old pods or scale in/out respective replicaset).

## Import the library contents

Execute this step only if the Spotfire environment was previously deployed and the library contents are exported as a part of [Back up and export the library contents](#back-up-the-database-and-export-the-library-contents):

- In the cli pod, import the library using the command [import-library-content](https://docs.tibco.com/pub/spotfire_server/latest/doc/html/TIB_sfire_server_tsas_admin_help/server/topics/import-library-content.html).

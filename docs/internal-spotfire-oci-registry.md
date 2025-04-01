# Using Pre-Built Artifacts from Spotfire OCI registry

The Spotfire container images and Helm charts are available from the Spotfire OCI registry, at `oci.spotfire.com`.  

You can use the [Spotfire Cloud Deployment kit](../README.md) to build your own custom artifacts,
extend them and customize them to adapt them to your specific needs.  
Note that chart versions and container image versions are designed to work together as a release. Care should be taken to keep chart and container image versions in sync with the selected release. 

## Working with container images and Helm charts

Use the following commands to pull the Spotfire container images and Helm charts from the Spotfire OCI registry.
You can later decide to push them to your own private registry if you wish to not use them directly from the Spotfire OCI registry.

### Container images

You can use standard container tools (e.g.: docker, podman, etc.) to pull the Spotfire container images from the Spotfire OCI registry.

#### Pulling container images

1. Log in to the Spotfire container images registry:
    ```bash
    export MY_USER=<username>
    export SPOTFIRE_CONTAINER_REGISTRY=oci.spotfire.com
    docker login -u $MY_USER $SPOTFIRE_CONTAINER_REGISTRY
    ```

2. Pull a container image:
    ```bash
    docker pull $SPOTFIRE_CONTAINER_REGISTRY/spotfire/<image>:<tag>
    ```

    For example:
    ```bash
    docker pull $SPOTFIRE_CONTAINER_REGISTRY/spotfire/spotfire-server:14.5.0-1
    ```

#### Browsing the container registry

You can browse the Spotfire container registry using the standard [Registry HTTP API](https://distribution.github.io/distribution/spec/api/).

Example: List the available repositories in the catalog using `curl`:
```bash
curl --user "$MY_USER:$MY_PASS" https://oci.spotfire.com/v2/spotfire/_catalog
```

Example: List all the tags under a given repository using `curl`:
```bash
curl --user "$MY_USER:$MY_PASS" https://oci.spotfire.com/v2/spotfire/spotfire-server/tags/list
```

For a list of Helm chart versions and their mapping to container image tags, and contained application version, 
see the [Spotfire Cloud Deployment Kit release notes](https://github.com/spotfiresoftware/spotfire-cloud-deployment-kit/releases).

#### Pushing container images to your private registry

If you need to copy the images to your own private registry, you can use, for example, the following commands for each of the Spotfire container images:

```bash
docker pull oci.spotfire.com/spotfire/spotfire-server:<tag>
docker tag oci.spotfire.com/spotfire/spotfire-server:<tag> <your-container-registry>/spotfire/spotfire-server:<tag>
docker push <your-container-registry>/spotfire/spotfire-server:<tag>
```

### Helm charts

#### Pulling Helm charts

1. Log in to the Spotfire Helm charts registry:
    ```bash
    export MY_USER=<username>
    helm registry login -u $MY_USER oci.spotfire.com
    ```

2. Pull a Spotfire Helm chart:
    ```bash
    helm pull oci://oci.spotfire.com/charts/<chart> --version <version>
    ```

    For example:
    ```bash
    helm pull oci://oci.spotfire.com/charts/spotfire-server --version 0.2.4
    ```

#### Catalog of released versions

You can browse the Spotfire Helm charts registry using the standard [Registry HTTP API](https://distribution.github.io/distribution/spec/api/).

Example: List the available repositories in the catalog using `curl`:
```bash
curl --user "$MY_USER:$MY_PASS" https://oci.spotfire.com/v2/charts/_catalog
```

Example: List all the tags under a given repository using `curl`:
```bash
curl --user "$MY_USER:$MY_PASS" https://oci.spotfire.com/v2/charts/spotfire-server/tags/list
```

#### Pushing Helm charts to your private registry

To copy the Helm charts to your own private registry, you can use the following commands for each of the Spotfire container images:

```bash
helm pull oci://oci.spotfire.com/charts/spotfire-server --version <version>
helm push spotfire-server-<version>.tgz <your-chart-registry-url>/spotfire/spotfire-server:<version>
```

For both helm charts and container images, if you are deploying into an environment with restricted internet connectivity you would need to pull charts and container images in order to deploy to your cluster.  

#### Installing charts and container images directly from the Spotfire OCI registry  

Spotfire for Kubernetes provides a convenience chart which can be used to deploy into your kubernetes cluster.  The [spotfire-platform](../helm/charts/spotfire-platform/README.md) is a chart which can be referenced or used as a sample chart and can be deployed directly into your kubernetes namespace.  Spotfire is designed to allow access to a registry by use of a pull secret.  A namespace should be created or selected and a secret would be created in the namespace. Then the spotfire-platform chart would be installed in the same namespace, using the pull secret to access helm charts and container images from the Spotfire OCI registry.

Example: Install the spotfire-platform in your kubernetes namespace.  Assuming the namespace has been created.

```bash
export NAMESPACE=<my-namespace>
export SECRET_NAME=<my-secret-name>
export PUBLIC_ADDRESS=<my-public-address>
export MY_USER=<username>
export MY_PASS=<password>
export MY_EMAIL=<optional_email_address>

kubectl create secret docker-registry $SECRET_NAME \
  --docker-username=$MY_USER \
  --docker-password=$MY_PASS \
  --docker-email=$MY_EMAIL \
  --docker-server=oci.spotfire.com \
  -n ${NAMESPACE} 

helm upgrade --install spotfire-platform -n ${NAMESPACE} \
  --set global.spotfire.acceptEUA=true \
  --set global.spotfire.image.registry=oci.spotfire.com \
  --set global.spotfire.image.pullSecrets[0]=$SECRET_NAME \
  --set spotfire-server.ingress.enabled=true \
  --set postgresql.enabled=true \
  --set spotfire-server.ingress.hosts[0].host=$PUBLIC_ADDRESS \
  oci://oci.spotfire.com/charts/spotfire-platform --version 0.2.4 --values ./my-custom-values.yaml
```

The spotfire-server requires a database. This example enables a postgres database for testing purposes.  You may want to use this for getting started,
but for production you would need to provision your own database.

### Licensing  

You are responsible for ensuring that your use of the Spotfire container images complies with your license for the Spotfire product(s) contained in the image, including any limitations that prevent you from publishing the image for use by others, whether internally or externally. 
For more information, see [Licenses](../README.md#licenses)

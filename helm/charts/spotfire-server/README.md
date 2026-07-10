# spotfire-server

![Version: 5.0.0](https://img.shields.io/badge/Version-5.0.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 15.0.0](https://img.shields.io/badge/AppVersion-15.0.0-informational?style=flat-square)

Deploy Spotfire® Server on Kubernetes using Helm. This chart handles database schema setup, autoscaling, persistent storage, ingress routing, and configuration out of the box.

**Homepage:** <https://github.com/spotfiresoftware/spotfire-cloud-deployment-kit>

## Source Code

* <https://github.com/spotfiresoftware/spotfire-cloud-deployment-kit>

## Requirements

Kubernetes: `>=1.24.0-0`

| Repository | Name | Version |
|------------|------|---------|
| file://../spotfire-common | spotfire-common | 5.0.0 |
| https://fluent.github.io/helm-charts | log-forwarder(fluent-bit) | 0.55.* |
| https://haproxytech.github.io/helm-charts | haproxy | 1.27.* |

## Overview

Using this chart, you can deploy the following:
- The required Spotfire Server database schemas on a supported database server (for example, Postgres).
- An ([Ingress](https://kubernetes.io/docs/concepts/services-networking/ingress/)) with routing rules for accessing the configured reverse proxy.
- Shared storage locations ([Persistent Volumes](https://kubernetes.io/docs/concepts/storage/persistent-volumes/)) for the Spotfire library import and export, custom jars, deployment packages, and other purposes.

The Spotfire Server pod includes:
- A [Fluent Bit](https://fluentbit.io/) sidecar container for log forwarding.
- Service annotations for [Prometheus](https://prometheus.io/) scrapers. The Prometheus server discovers the service endpoint using these specifications and scrapes metrics from the exporter.
- Predefined configuration for horizontal pod autoscaling with [KEDA](https://keda.sh/docs) and Prometheus.
- A reverse proxy ([HAProxy](https://www.haproxy.org/)) for accessing the Spotfire Server cluster service, with session affinity for external HTTP access.

This chart is tested to work with [NGINX Ingress Controller](https://github.com/kubernetes/ingress-nginx), [Elasticsearch](https://www.elastic.co/elasticsearch/), [Prometheus](https://prometheus.io/) and [KEDA](https://keda.sh/).

## Prerequisites

- Familiarity with Kubernetes, containers, and Helm chart concepts and usage.
- [Helm 3+](https://helm.sh/).
- [Kubectl CLI](https://kubernetes.io/docs/reference/kubectl/).
- A [supported database server](https://docs.tibco.com/pub/spotfire/general/sr/sr/topics/tibco_spotfire_server.html) for use as the Spotfire database.
- [Ingress controller](https://kubernetes.io/docs/concepts/services-networking/ingress-controllers/) (optional).
- [PV (Persistent Volume)](https://kubernetes.io/docs/concepts/storage/persistent-volumes/) provisioner support in the underlying infrastructure (optional).

**Note**: You can use any of the databases supported by Spotfire Server with these recipes. You can choose to run the database in containers, VMs, or on bare metal servers, or you can use a cloud database service. For more information on how to configure connection settings to the supported databases using this Helm chart,
see the [Supported databases configuration table](#supported-databases-configuration) and the [Values table](#values).

## Usage

Replace all placeholders (shown in angle brackets like `<NAMESPACE>`) with your actual values before running the commands.

### Step 1: Create namespace

```bash
kubectl create namespace "<NAMESPACE>"
```

### Step 2: Prepare database connection

Complete either Step 2a or Step 2b depending on your setup.

#### Step 2a: Deploy a PostgreSQL database (optional)

> Skip this step if you already have access to a [supported database](https://docs.tibco.com/pub/spotfire_server/latest/doc/html/TIB_sfire_server_tsas_admin_help/server/topics/spotfire_database_setup.html).

This example deploys the [CloudPirates PostgreSQL chart](https://artifacthub.io/packages/helm/cloudpirates-postgres/postgres), which auto-generates the admin password:

```bash
helm install <DB_RELEASE> oci://registry-1.docker.io/cloudpirates/postgres \
  --namespace="<NAMESPACE>" \
  --set-string image.tag="17"
```

**Note**:
- `--set-string image.tag="17"` pins the major version to PostgreSQL 17.
- The auto-generated password is stored in the secret `<DB_RELEASE>-postgresql` under the key `postgres-password`.
- If you uninstall and reinstall the chart and the PostgreSQL PVC still exists, PostgreSQL will ignore a changed password (the PVC holds the original password). Delete the PVC first (`kubectl delete pvc <DB_RELEASE>-postgresql-0`) to reset — this also deletes all stored data.

#### Step 2b: Create a database credentials secret (optional)

> Skip this step if you completed Step 2a - the secret is created automatically.

If you are using an existing database, create a secret with its admin password:

```bash
kubectl create secret generic spotfire-db-credentials \
  --namespace="<NAMESPACE>" \
  --from-literal=adminPassword="<DB_ADMIN_PASSWORD>"
```

### Step 3: Deploy the Spotfire Server chart

Create a `values.yaml` file (e.g., `spotfire-server-values.yaml`). See the [Values table](#values) for details of the values.

```yaml
# spotfire-server-values.yaml
acceptEUA: true

global:
  spotfire:
    image:
      registry: "<REGISTRY>"
      pullPolicy: Always

configuration:
  site:
    publicAddress: "<SPOTFIRE_PUBLIC_ADDRESS>"

database:
  create-db:
    enabled: true
    spotfiredbDbname: "<DB_NAME>"
    databaseUrl: "jdbc:postgresql://<DB_HOST>:<DB_PORT>/"
    adminUsername: "<DB_ADMIN_USERNAME>"
    adminPasswordExistingSecret:
      name: "<DB_SECRET_NAME>"
      key: "<DB_SECRET_KEY>"

  bootstrap:
    databaseUrl: "jdbc:postgresql://<DB_HOST>:<DB_PORT>/<DB_NAME>"
```

Install the chart:

```bash
helm install "<SPOTFIRE_SERVER_RELEASE>" . \
  --namespace="<NAMESPACE>" \
  --create-namespace \
  --values spotfire-server-values.yaml
```

**Configuration**:
- Setting `acceptEUA: true` means you agree that your use of the Spotfire software is governed by the terms of the [Cloud Software Group, Inc. End User Agreement](https://www.cloud.com/legal/terms).
- Replace `<REGISTRY>` with your private registry address where the Spotfire container images are stored. See the Kubernetes documentation for how to [Pull an Image from a Private Registry](https://kubernetes.io/docs/tasks/configure-pod-container/pull-image-private-registry/).
- Replace `<SPOTFIRE_PUBLIC_ADDRESS>` with the full URL (including `http://` or `https://`) that your Spotfire server will be available on (for example, `https://spotfire.example.com`).

**Database**:
- When `database.create-db.enabled=true`, database schemas are created and configured during install. See [create-db](https://docs.tibco.com/pub/spotfire_server/latest/doc/html/TIB_sfire_server_tsas_admin_help/server/topics/create-db.html) documentation for details.
- Replace `<DB_ADMIN_USERNAME>`, `<DB_SECRET_NAME>`, and `<DB_SECRET_KEY>` with the values for your Step 2 path:

  | | `<DB_SECRET_NAME>` | `<DB_SECRET_KEY>` | `<DB_ADMIN_USERNAME>` |
  |---|---|---|---|
  | **Step 2a** (CloudPirates PostgreSQL) | `<DB_RELEASE>-postgresql` | `postgres-password` | `postgres` |
  | **Step 2b** (existing database) | `spotfire-db-credentials` | `adminPassword` | your admin username |
- In some cases you may need to place additional files in the container and supply their absolute path in the connection URL. See the [Volumes](#volumes) section.

**Quick troubleshooting**: If installation hangs or fails, start by checking the `config-job` logs.

```bash
kubectl get pods --namespace "<NAMESPACE>" \
  --selector=job-name="<SPOTFIRE_SERVER_RELEASE>-config-job-1" \
  --sort-by=.metadata.creationTimestamp -o name | \
  while read pod; do
    printf '\n---------- %s ----------\n' "$pod"
    kubectl logs --namespace "<NAMESPACE>" "$pod"
  done
```

**Note**: This lists logs from all config job runs in pod creation order (oldest to newest).

Check pod status and recent namespace events:

```bash
kubectl get pods --namespace "<NAMESPACE>"
kubectl get events --namespace "<NAMESPACE>"
```

### Step 4: Retrieve credentials and access Spotfire Server

After a successful install, retrieve the auto-generated credentials and the Spotfire Server URL.

#### Spotfire admin password

```bash
export SPOTFIREADMIN_PASSWORD=$(kubectl get secret --namespace "<NAMESPACE>" \
  "<SPOTFIRE_SERVER_RELEASE>-spotfire-server" \
  -o jsonpath="{.data.SPOTFIREADMIN_PASSWORD}" | base64 --decode)
echo "Admin password: $SPOTFIREADMIN_PASSWORD"
```

The default admin username is set by `configuration.spotfireAdmin.username` (defaults to `admin`).

#### Spotfire database password

```bash
export SPOTFIREDB_PASSWORD=$(kubectl get secret --namespace "<NAMESPACE>" \
  "<SPOTFIRE_SERVER_RELEASE>-spotfire-server" \
  -o jsonpath="{.data.SPOTFIREDB_PASSWORD}" | base64 --decode)
echo "Database password: $SPOTFIREDB_PASSWORD"
```

**Note**: If you supplied your own secret via `configuration.spotfireAdmin.passwordExistingSecret` or `database.bootstrap.passwordExistingSecret`, use your custom secret name and key instead.

#### Spotfire Server URL

If you are using an Ingress, skip this section and go to [Step 5](#step-5-expose-via-ingress-optional) instead.

##### Access via port-forward (local development)

Otherwise, use `kubectl port-forward` to reach the server locally:

```bash
export POD_NAME=$(kubectl get pods --namespace "<NAMESPACE>" \
  -l "app.kubernetes.io/name=spotfire-server,app.kubernetes.io/instance=<SPOTFIRE_SERVER_RELEASE>,app.kubernetes.io/component=server,app.kubernetes.io/part-of=spotfire" \
  -o jsonpath="{.items[0].metadata.name}")
kubectl --namespace "<NAMESPACE>" port-forward "$POD_NAME" 8080:8080
# Visit http://127.0.0.1:8080
```

##### Access via LoadBalancer service

For `LoadBalancer` service types, wait for an external IP and then use:

```bash
export SERVICE_IP=$(kubectl get svc --namespace "<NAMESPACE>" \
  "<SPOTFIRE_SERVER_RELEASE>-spotfire-server" \
  --template "{{ range (index .status.loadBalancer.ingress 0) }}{{ . }}{{ end }}")
echo "http://$SERVICE_IP:80"
```

### Step 5: Expose via Ingress (optional)

If you have an [ingress controller](https://kubernetes.io/docs/concepts/services-networking/ingress-controllers/) in your cluster, add the following to `spotfire-server-values.yaml` and run `helm upgrade`:

```yaml
ingress:
  enabled: true
  ingressClassName: nginx
  hosts:
    - host: "<INGRESS_HOST>"
      paths:
        - path: /
          pathType: Prefix
```

```bash
helm upgrade "<SPOTFIRE_SERVER_RELEASE>" . \
  --namespace="<NAMESPACE>" \
  --values spotfire-server-values.yaml
```

**Note**: Replace `<INGRESS_HOST>` with the hostname or DNS name that resolves to your ingress controller (for example, `spotfire.example.com`).

## Configuration

### Running custom spotfire-config tool tasks during helm install / upgrade

To add a custom configuration or to run custom tasks during a helm install or upgrade, you can run a custom `spotfire-config` tool task.
There are three types of `config.sh` scripts that you can run:
- `configuration.configurationScripts` - Scripts that modify the Spotfire Server configuration (`configuration.xml`).
- `configuration.commandScripts` - Scripts that do not modify the Spotfire Server configuration (for example, for creating users, assigning licenses, and so on).
- `configuration.preConfigCommandScripts` - The same as commandScripts, except these commands are run before the configuration is imported.

See the [Values](#values) section for more details.

**Note**: To deploy SDN files during helm install or upgrade, see [Using persistent volumes for deploying SDNs/SPKs](#volume-for-deploying-sdnsspks).

Example: Running custom `spotfire-config` tool tasks with an environment variable sourced from a secret:

1. Create a Kubernetes secret with the environment variable:

    ```bash
    kubectl create secret generic spotfire-user-credentials \
      --namespace="<NAMESPACE>" \
      --from-literal=NEW_USER_PASSWORD="<YOUR-USER-PASSWORD>"
    ```

2. Add the following to your `values.yaml` and run `helm install` or `helm upgrade`:

    ```yaml
    configuration:
      configurationScripts:
        - name: my_custom_script
          script: |
            echo "This is an example custom configuration task."
            set-config-prop \
              --name=lifecycle.changes-monitoring.draining.timeout-seconds \
              --value=180 \
              --configuration="${CONFIGURATION_FILE}" \
              --bootstrap-config="${BOOTSTRAP_FILE}"

        - name: my_second_script
          script: |
            echo "Scripts are executed in order. This one runs after the one above."

      commandScripts:
        - name: create_user
          script: >-
            create-user
            --bootstrap-config="${BOOTSTRAP_FILE}"
            --tool-password="${TOOL_PASSWORD}"
            --username="<SPOTFIRE_USERNAME>"
            --password="${NEW_USER_PASSWORD}"
            --ignore-existing=true

    extraEnvVarsSecret: spotfire-user-credentials
    ```

For more information about `config.sh` scripts, see the Spotfire Server documentation about [scripting a configuration](https://docs.tibco.com/pub/spotfire_server/latest/doc/html/TIB_sfire_server_tsas_admin_help/server/topics/scripting_a_configuration.html).

If your scripts require additional environment variables, use `extraEnvVarsSecret` or `extraEnvVarsCM` to add environment variables from existing Secrets or ConfigMaps.

### Managing configuration on helm install or upgrade

The key `configuration.apply` controls when to apply the values under the `configuration` key level.
See the following table for a summary of the possible values, descriptions, and when to use each of them.

| Value | Description | When it is useful |
|-------|-------------|-------------------|
| `always` | Apply on every `helm upgrade` or `helm install`| When you prefer to manage the configuration always using `configuration` keys. |
| `initialsetup` | Apply only on a new Spotfire Server install and if there is no configuration in the database | When you want to use `configuration` keys for the initial setup of the system, but you prefer to manage the configuration using an external tool. |
| `never` | Do not apply | When you prefer to manage the configuration externally without using `configuration` keys. |

**Note**: When set to `always`, the configuration made from tools other than helm might be overwritten when doing a helm upgrade.

**Note**: The Spotfire database must contain a configuration that is compatible with this helm chart and Spotfire running in Kubernetes. See `config-job-scripts/default-kubernetes-config.txt.gotmpl`. You must make sure a compatible configuration is active, either by manually setting a configuration, or by using the value `always` or `initialsetup` (only during initial setup), in which case the configuration job applies the configuration for you.

**Note**: If you prefer to manage the configuration externally, you can set `configuration.preferExistingConfig` to true.
See the [Values](#values) section for more details.

## Scaling

For scaling the `<SPOTFIRE_SERVER_RELEASE>` deployment, you can use `kubectl scale`, providing the target number of pod instances in the `--replicas` value.

```bash
kubectl scale deployment <SPOTFIRE_SERVER_RELEASE>-spotfire-server --replicas=3
```

### Autoscaling with KEDA

To use [KEDA](https://keda.sh/docs) for autoscaling, first install KEDA in the Kubernetes cluster. You must also install a Prometheus instance that scrapes metrics from the Spotfire pods.

Example: A `values.yaml` snippet configuration for enabling autoscaling with KEDA:
```yaml
kedaAutoscaling:
  enabled: true
  spotfireConfig:
    prometheusServerAddress: http://prometheus-server.monitor.svc.cluster.local
  threshold: 60
  minReplicas: 1
  maxReplicas: 3
```

The value specified for threshold determines the value that the query must reach before the service is scaled.

The `spotfire-server` has the following autoscaling defaults:
- metric: `spotfire_OS_OperatingSystem_SystemCpuLoad` (_CPU usage_ of the Spotfire Server instance).
- query: the sum of `spotfire_OS_OperatingSystem_SystemCpuLoad` (in percent) of all the Spotfire Server instances for the release name.

With these default settings, if the total CPU usage for all instances is greater than the threshold, then another instance is started to scale out the service.
If the total CPU usage for all instances falls under the threshold, then the service scales in.

For each multiple of the `kedaAutoscaling.threshold`, another instance is scaled out:
- With 1 replica, if the query value is at >60% CPU, then another replica is created.
- With 2 replicas, if the query value is at >120%, then another replica is created, and so on.

For more information, see the [HPA algorithm details](https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/#algorithm-details).

**Note**: To allow time for draining sessions when scaling in, tune the values for `draining.minimumSeconds` and `draining.timeoutSeconds`.

For more advanced scenarios, see [kedaAutoscaling.advanced](https://keda.sh/docs/latest/concepts/scaling-deployments/#advanced) and [kedaAutoscaling.fallback](https://keda.sh/docs/latest/concepts/scaling-deployments/#fallback).

Additionally, you can define your own [custom scaling triggers](https://keda.sh/docs/latest/concepts/scaling-deployments/#triggers). Helm template functionality is available:
```
kedaAutoscaling:
  triggers: {} # list of triggers to activate scaling of the target resource
```

**Note**: For more details on the autoscaling defaults, see `templates/keda-autoscaling.yaml` in the chart.

#### Update the Pod Deletion Cost annotation automatically

The [controller.kubernetes.io/pod-deletion-cost](https://kubernetes.io/docs/concepts/workloads/controllers/replicaset/#pod-deletion-cost) pod annotation influences in which order Kubernetes selects the pod to delete, for example, during scale-in.

Note that pod annotations should not be updated 'too' often (minutes rather than seconds), depending on the size of the cluster. The reason for this is that the Kubernetes API server is highly optimized for reads. `sleepIntervalSeconds` controls how often the updater should run, `thresholdPercent` and `minAbsDelta` controls how large the change must be for the annotation to be updated, that is, it specifies the size of a meaningful change.

The updater uses pod annotations `prometheus.io/path` and `prometheus.io/port` to find metrics endpoints. If these annotations are missing from the target server pods, those pods are skipped.

```yaml
podDeletionCost:
  enabled: true
```

The `spotfire-server` has the following defaults:
- cost formula: `-1000*spotfire_SpotfireServer_IsIdle + spotfire_InformationServices_InformationServicesMetrics_InformationServicesJobs + spotfire_SpotfireServer_ServerMetrics_UploadingAttachments`.
- sleepIntervalSeconds: `120`.
- `thresholdPercent`: `10`
- `minAbsDelta`: `5`

## Performance and Storage

### Improved performance and concurrency for temporary folder

In scenarios where information link results or large library files are cached concurrently, the Spotfire Server uses its temporary folder (default: `/opt/spotfire/spotfireserver/tomcat/temp`). In Kubernetes setups or underlying hosts, these reads and writes might become a bottleneck, negatively impacting performance and throughput. It can also happen that the default allowed ephemeral storage for the pod is too small.
It is recommended to use a more performant and larger Kubernetes volume. The storage size must accommodate:
- The attachment manager cache, see [Attachment manager cache](https://docs.tibco.com/pub/spotfire_server/latest/doc/html/TIB_sfire_server_tsas_admin_help/server/topics/attachment_manager_cache.html).
- Deployment area packages.

**Note**: For Azure AKS clusters, see also: [Use Azure Container Storage with local NVMe](https://learn.microsoft.com/en-us/azure/storage/container-storage/use-container-storage-with-local-disk).

Example: A `values.yaml` snippet for optimizing the Spotfire Server temp disk performance on Azure.
```yaml
extraVolumeMounts:
  - mountPath: /opt/spotfire/spotfireserver/tomcat/temp
    name: spotfire-temp-dir-volume
extraVolumes:
  - name: spotfire-temp-dir-volume
    ephemeral: # See Kubernetes documentation for ephemeral volumes: https://kubernetes.io/docs/concepts/storage/ephemeral-volumes/
      volumeClaimTemplate:
        metadata:
          labels:
            type: spotfire-ephemeral-volume
        spec:
          accessModes: ["ReadWriteOnce"]
          storageClassName: <STORAGE_CLASS_NAME> # Replace with your storage class name.
          resources:
            requests:
              storage: 10Gi # Specify the desired storage size.
```

If the correct permissions are not set on the volume, see [Troubleshooting the generic volumes folder permissions](#troubleshooting-the-generic-volumes-folder-permissions).

**Note**: A similar configuration can be applied to optimize the temporary disk performance of other Spotfire services on Azure. See each service README for their default temp folder.

## Uninstalling

To uninstall the `<SPOTFIRE_SERVER_RELEASE>` release:
```bash
helm --namespace <NAMESPACE> uninstall <SPOTFIRE_SERVER_RELEASE>
```

### Deleting any remaining resources

Normally, all services and pods are deleted using `helm uninstall`, but occasionally you might need to manually delete existing Spotfire persistent volume claims or incomplete jobs due to an interrupted operation or incorrect setup.

#### Delete unused persistent volume claims:

1. List the persistent volume claims:

    ```bash
    kubectl --namespace <NAMESPACE> get pvc
    ```

2. Delete the persistent volume claims. For example:

    ```bash
    kubectl --namespace <NAMESPACE> delete pvc data-<SPOTFIRE_SERVER_RELEASE>-postgresql-0
    ```
    **Warning**: Make sure to only delete persistent volume claims that you do not want to keep!

#### Delete old release jobs

1. List the jobs:

    ```bash
    kubectl --namespace <NAMESPACE> get jobs
    ```

2. Delete the jobs that you do not want to keep. For example:

    ```bash
    kubectl --namespace <NAMESPACE> delete job.batch/<SPOTFIRE_SERVER_RELEASE>-spotfire-server-basic-config-job
    ```

#### Delete the Kubernetes namespace and all resources in the namespace.

**Warning**: This cannot be undone!

```bash
kubectl delete namespace <NAMESPACE>
```

## Upgrading

### Read the Spotfire® Server manual

See the [Upgrading Spotfire](https://docs.tibco.com/pub/spotfire_server/latest/doc/html/TIB_sfire_server_tsas_admin_help/server/topics/upgrading_spotfire.html) page in the "Spotfire® Server and Environment - Installation and Administration" manual for any specific considerations or instructions related to the version you are upgrading to. This ensures you are aware of any known issues or steps to follow when upgrading.

### Backing up the database

Before doing any upgrading, make sure to back up the Spotfire database. This ensures that you have a copy of the database in its previous state, and that you can revert to this state if necessary. If you use external library storage, you should also create a snapshot of the external library storage that corresponds to the database backup state.

### Upgrading helm chart version

Some parameters might have been changed, moved or renamed and must be taken into consideration when upgrading the release. See [release notes](https://github.com/spotfiresoftware/spotfire-cloud-deployment-kit/releases) for more information.

### Upgrading the Spotfire Server version

When you upgrade a Spotfire Helm chart, consider the following to ensure a smooth upgrade process.

You must understand whether the new Helm chart version comes with a new Spotfire Server version. If it does, consider the implications of upgrading to a new server version and any potential compatibility issues or changes in functionality.

#### Upgrading Spotfire Server and Spotfire services

If you are upgrading to a newer Spotfire Server version and Spotfire services versions, first upgrade the Spotfire Server, and then upgrade the Spotfire services.

#### Database upgrade

If you prefer to let the Helm chart automatically perform Spotfire database schema upgrade, you can set the `database.upgrade` value to *true*.

By default automatic database upgrade is disabled meaning you must manually upgrade the database when installing a new Spotfire server version that requires the Spotfire database to be upgraded.

#### Verifying the upgrade

The Kubernetes job `config-job` is responsible for upgrading the Spotfire database. To verify that the upgrade was successful, you should check the `config-job` logs. This will help you to identify any issues or errors that might have occurred during the upgrade process, and to ensure that your Spotfire Server database has been successfully upgraded.

The Kubernetes job `config-job` uses the Spotfire Server Upgrade Tool. For details, see [Run the Spotfire Server Upgrade Tool](https://docs.tibco.com/pub/spotfire_server/latest/doc/html/TIB_sfire_server_tsas_admin_help/server/topics/run_the_spotfire_server_upgrade_tool.html).

## Additional: custom environment variables

You can use the following chart keys to add additional environment variables to the pods:
- `extraEnvVars`, `extraEnvVarsCM`, `extraEnvVarsSecret` - Extra environment variables for the `spotfire-server` pod
- `cliPod.extraEnvVars`, `cliPod.extraEnvVarsCM`, `cliPod.extraEnvVarsSecret` - Extra environment variables for the `cli` pod
- `configJob.extraEnvVars`, `configJob.extraEnvVarsCM`, `configJob.extraEnvVarsSecret` - Extra environment variables for the `config-job` pod

Use these keys to inject environment variables for usage in custom initialization and configuration scripts, or to set options for the Spotfire Server JVM and Tomcat.

Use `extraEnvVarsSecret` or `extraEnvVarsCM` to add environment variables from existing secrets or configMaps.

Example: A `values.yaml` snippet for JVM settings for the Spotfire Server:
```yaml
extraEnvVars:
  - name: CATALINA_INITIAL_HEAPSIZE
    value: 1024m
  - name: CATALINA_MAXIMUM_HEAPSIZE
    value: 2048m
  - name: CATALINA_OPTS
    value: "-Djava.net.preferIPv4Stack=true"
```

## Volumes

You can use volumes to mount external files into the containers file system to make them available to the containers.
You can also use volumes to persist data that is written by Spotfire Server to an external volume.

Setting up volumes permissions is usually handled by the Kubernetes administrators. See the Kubernetes documentation for best practices.

**Note**: You can create a pod running as the user `root` that uses a PersistentVolume or PersistentVolumeClaim to set the right permissions or to pre-populate the volume with jar files or library import files.

- For more information on volumes, see [Volumes](https://kubernetes.io/docs/concepts/storage/volumes/) and [Persistent Volumes](https://kubernetes.io/docs/concepts/storage/persistent-volumes/).
- For more information using PersistentVolumes and PersistentVolumeClaims in a Pod, see [Configure a Pod to Use a PersistentVolume for Storage](https://kubernetes.io/docs/tutorials/configuration/configure-persistent-volume-storage/).

You can use Kubernetes persistent volumes as a shared storage location for the _Spotfire library_ import and export location, custom jars, deployment packages, certificates, and other purposes.

Use predefined chart values for the most common needed Spotfire volumes. See [table](#spotfire-specific-volumes) below.
Using generic volumes is also possible. See section [Spotfire generic volumes](#spotfire-generic-volumes).

### Spotfire specific volumes

| Chart values                           | Purpose                                                                      |
|----------------------------------------|------------------------------------------------------------------------------|
| `volumes.certificates`                 | Use self-signed or custom certificates                                       |
| `volumes.customExt`                    | Use additional Java library files in the Spotfire Server                     |
| `volumes.customExtInformationservices` | Use additional Java library files for Information Services                   |
| `volumes.deployments`                  | Automatically deploy SDNs/SPKs files into a _Spotfire deployment area_       |
| `volumes.libraryImportExport`          | Common storage for Spotfire library import and export operations             |
| `volumes.troubleshooting`              | Persist `spotfire-server` JVM head dumps and information for troubleshooting |

**Note**: If a volume is not configured, it is not used, or the mountPath uses an emptyDir volume.

#### Volume for certificates

To use self-signed or custom certificates for connecting to LDAPS (such as `.jks` keystore files),
you can create a volume with the desired files and use
`volumes.certificates.existingClaim` to set the PersistentVolumeClaim.

*mountPath*:
- `/opt/spotfire/spotfireserver/tomcat/certs` (spotfire-server pod)
- `/opt/spotfire/spotfireconfigtool/certs` (config-job and cli pods)

**Note**: Ensure the `spotfire` user has read access to the volume.

For more information on using self-signed certificates for LDAPS with the Spotfire Server, see [Configuring LDAPS](https://docs.tibco.com/pub/spotfire_server/latest/doc/html/TIB_sfire_server_tsas_admin_help/server/topics/configuring_ldaps.html).

#### Volume for custom Java library files

To use custom jar files in the `spotfire-server` container, you can create a PersistentVolume with the desired files and use `volumes.customExt.existingClaim` to set the PersistentVolumeClaim to use.

*mountPath*:
- `/opt/spotfire/spotfireserver/tomcat/custom-ext` (spotfire-server pod)
- `/opt/spotfire/spotfireconfigtool/custom-ext` (config-job and cli pods)

**Note**: The `spotfire` user needs read permissions for the volume.

For information on using additional Java library files for Spotfire Server, see:

- [Authentication towards a custom JAAS module
  ](https://docs.tibco.com/pub/spotfire_server/latest/doc/html/TIB_sfire_server_tsas_admin_help/server/topics/authentication_towards_a_custom_jaas_module.html)
- [Post-authentication filter](https://docs.tibco.com/pub/spotfire_server/latest/doc/html/TIB_sfire_server_tsas_admin_help/server/topics/post-authentication_filter.html)

#### Volume for additional JDBC drivers

To be able to access data from a JDBC-compliant data source with Information Services, use `volumes.customExtInformationservices`:

*mountPath*:
- `/opt/spotfire/spotfireserver/tomcat/custom-ext-informationservices` (spotfire-server pod)
- `/opt/spotfire/spotfireconfigtool/custom-ext-informationservices` (config-job and cli pods)

See [Installing database drivers for Information Designer](https://docs.tibco.com/pub/spotfire_server/latest/doc/html/TIB_sfire_server_tsas_admin_help/server/topics/installing_database_drivers_for_information_designer.html) for more information.

#### Volume for deploying SDNs/SPKs

**Note**: By default, the deployment configuration job creates a deployment area using the release's `Spotfire.Dxp.sdn`, contained in the spotfire-deployment image.
If this is sufficient for your use case, you can skip this section.
However, if you want to customize the Spotfire deployment areas structure and the packages to be deployed on each of them, you can follow instead the steps in this section.
For more information, see the keys under `configuration.deployment`.

To automatically deploy SDNs/SPKs files into a _Spotfire deployment area_,
you can create a PersistentVolume with the desired files to mount on container start
and use `volumes.deployments.existingClaim` to set the PersistentVolumeClaim to use.

Steps:
1. Copy the desired SDNs/SPKs in a folder (such as `Test/`) in the PersistentVolume.
2. On helm install or upgrade, the `config-job` creates a _Spotfire deployment area_ with the folder name (if it does not exist), and the packages are deployed into that area.

Example: The following volume file structure creates the deployment areas "Production" and "Test", and deploys the provided SDN files in these respective deployment areas:
```text
Production/Spotfire.Dxp.sdn
Test/Spotfire.Dxp.sdn
Test/Spotfire.Dxp.PythonServiceLinux.sdn
```

*mountPath*: `/opt/spotfire/spotfireconfigtool/deployments` (config-job pod)

**Note**: The `spotfire` user needs read permissions for the volume. Spotfire deployment area names are case-insensitive, have a maximum length of 25 characters, and can include letters, numbers, underscores and dashes.

For more information, see [Spotfire Deployments and deployment areas](https://docs.tibco.com/pub/spotfire_server/latest/doc/html/TIB_sfire_server_tsas_admin_help/server/topics/deployments_and_deployment_areas.html).

#### Volume for library export and import

To use a common storage for Spotfire library import and export operations,
you can use `volumes.libraryImportExport.persistentVolumeClaim` or `volumes.libraryImportExport.existingClaim`
to control which PersistentVolume or PersistentVolumeClaim to use.

*mountPath*:
- `/opt/spotfire/spotfireserver/tomcat/application-data/library` (spotfire-server pod)
- `/opt/spotfire/spotfireconfigtool/library` (cli pod)

**Note**: The `spotfire` user needs read and write permissions for the volume.

For more information, see [importing to library](https://docs.tibco.com/pub/sfire-analyst/latest/doc/html/en-US/TIB_sfire-analyst_UsersGuide/index.htm#t=lib%2Flib_importing_to_library.htm&rhsearch=export&rhsyns=%20)
and [exporting from library](https://docs.tibco.com/pub/sfire-analyst/latest/doc/html/en-US/TIB_sfire-analyst_UsersGuide/index.htm#t=lib%2Flib_exporting_from_library.htm&rhsearch=export&rhsyns=%20).

#### Volume for troubleshooting files

To persist `spotfire-server` JVM head dumps and information for troubleshooting when pods are removed,
you can use `volumes.troubleshooting.persistentVolumeClaim` or `volumes.troubleshooting.existingClaim`
to control which PersistentVolume or PersistentVolumeClaim to use.

*mountPath*: `/opt/spotfire/troubleshooting/jvm-heap-dumps` (spotfire-server pod)

**Note**: The `spotfire` user needs write permissions for the volume.

### Spotfire generic volumes

A generic way to use volumes with the `spotfire-server` chart is with the `extraVolumeMounts` and `extraVolumes` chart variables.

There are specific variables for using these generic volumes on each pod:
- For the `spotfire-server` pod, use `extraVolumeMounts` and `extraVolumes`.
- For the `cli` pod, use `cliPod.extraVolumeMounts` and `cliPod.extraVolumes`.
- For the `config-job` pod, use `configJob.extraVolumeMounts` and `configJob.extraVolumes`.

Example:
```yaml
extraVolumeMounts:
  - name: example
    mountPath: /opt/spotfire/example
    subPath: example
extraVolumes:
  - name: example
    persistentVolumeClaim:
      claimName: exampleClaim
```

### Troubleshooting the generic volumes folder permissions
If there are any permission issues on the volume mount folders, use an extra init container to set the appropriate permissions.

Example: A `values.yaml` snippet for setting the desired permissions on a generic volume folder using an extra init container.
```yaml
extraInitContainers:
  - name: example-permission-provider
    image: busybox
    command:
    - "chmod"
    - "o+rwx" # Specify desired permissions on the mount folder.
    - "/opt/spotfire/example-folder"
    volumeMounts:
    - mountPath: "/opt/spotfire/example-folder"
      name: example
extraVolumes:
  - name: example
    persistentVolumeClaim:
      claimName: exampleClaim
```

## Always-on Spotfire configuration CLI pod

When `cliPod.enabled` is set to `true`, an always-on Spotfire configuration CLI pod is deployed with the chart. You can use this pod to manage and configure the Spotfire environment.

Example: Get the bash prompt into the configuration CLI pod:
```bash
kubectl exec -it $(kubectl get pods -l "app.kubernetes.io/component=cli, app.kubernetes.io/part-of=spotfire" -o jsonpath="{.items[0].metadata.name}" ) -- bash
```
Run the bootstrap.sh script to create a bootstrap.xml before starting to use config.sh
```bash
<SPOTFIRE_SERVER_RELEASE>-cli-<pod-id> $ ./bootstrap.sh
```

For more information, see [Configuration using the command line](https://docs.tibco.com/pub/spotfire_server/latest/doc/html/TIB_sfire_server_tsas_admin_help/server/topics/configuration_using_the_command_line.html).

## Supported databases configuration

| Database                | driver class                                 | create-db.databaseUrl                                    | bootstrap.databaseUrl                                                | Additional parameters                    |
|-------------------------|----------------------------------------------|----------------------------------------------------------|----------------------------------------------------------------------|------------------------------------------|
| Postgres                | org.postgresql.Driver                        | jdbc:postgresql://databasehost:databaseport/             | jdbc:postgresql://databasehost:databaseport/databasename             |                                          |
| Oracle                  | oracle.jdbc.OracleDriver                     | jdbc:oracle:thin:@//databasehost:databaseport/service    | jdbc:oracle:thin:@//databasehost:databaseport/service                | oracleRootfolder, oracleTablespacePrefix |
| MSSQL                   | com.microsoft.sqlserver.jdbc.SQLServerDriver | jdbc:sqlserver://databasehost:databaseport               | jdbc:sqlserver://databasehost:databaseport;DatabaseName=databasename |                                          |
| AWS Postgres            | org.postgresql.Driver                        | jdbc:postgresql://databasehost:databaseport/databasename | jdbc:postgresql://databasehost:databaseport/databasename             | doNotCreateUser = true                   |
| Aurora Postgres         | org.postgresql.Driver                        | jdbc:postgresql://databasehost:databaseport/databasename | jdbc:postgresql://databasehost:databaseport/databasename             | doNotCreateUser = true                   |
| AWS Oracle              | oracle.jdbc.OracleDriver                     | jdbc:oracle:thin:@databasehost:databaseport/ORCL         | jdbc:oracle:thin:@databasehost:databaseport/ORCL                     | variant = rds                            |
| AWS MSSQL               | com.microsoft.sqlserver.jdbc.SQLServerDriver | jdbc:sqlserver://databasehost:databaseport               | jdbc:sqlserver://databasehost:databaseport;DatabaseName=databaseName | variant = rds                            |
| Azure Postgres          | org.postgresql.Driver                        | jdbc:postgresql://databasehost:databaseport/databasename | jdbc:postgresql://databasehost:databaseport/databasename             | doNotCreateUser = true                   |
| Azure MSSQL             | com.microsoft.sqlserver.jdbc.SQLServerDriver | jdbc:sqlserver://databasehost:databaseport               | jdbc:sqlserver://databasehost:databaseport;DatabaseName=databaseName | variant = azure                          |
| Google Cloud Postgres   | org.postgresql.Driver                        | jdbc:postgresql://databasehost:databaseport/             | jdbc:postgresql://databasehost:databaseport/databasename             | doNotCreateUser = true                   |
| Google Cloud SQL Server | com.microsoft.sqlserver.jdbc.SQLServerDriver | jdbc:sqlserver://databasehost:databaseport               | jdbc:sqlserver://databasehost:databaseport;DatabaseName=databaseName | variant = google                         |

For more details, see for example:
- [Postgres JDBC](https://jdbc.postgresql.org/documentation/use/#connecting-to-the-database)
- [Oracle JDBC](https://docs.oracle.com/en/database/oracle/oracle-database/12.2/jjdbc/data-sources-and-URLs.html#GUID-C4F2CA86-0F68-400C-95DA-30171C9FB8F0)
- [Microsoft JDBC](https://learn.microsoft.com/en-us/sql/connect/jdbc/building-the-connection-url?view=sql-server-ver16)

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| global.spotfire.acceptEUA | bool | `nil` | Accept the [Cloud Software Group, Inc. End User Agreement](https://www.cloud.com/legal/terms) by setting the value to `true`. |
| global.spotfire.image.pullPolicy | string | `"IfNotPresent"` | The global container image pull policy. |
| global.spotfire.image.pullSecrets | list | `[]` | The global container image pull secrets. |
| global.spotfire.image.registry | string | `nil` | The global container image registry. Used for  container images unless overridden. |
| acceptEUA | bool | `nil` | Accept the [Cloud Software Group, Inc. End User Agreement](https://www.cloud.com/legal/terms) by setting the value to `true`. |
| affinity | object | `{}` |  |
| cliPod.affinity | object | `{}` |  |
| cliPod.enabled | bool | `true` |  |
| cliPod.extraEnvVars | list | `[]` | Additional environment variables all spotfire-server pods use.  - name: NAME    value: value |
| cliPod.extraEnvVarsCM | string | `""` |  |
| cliPod.extraEnvVarsSecret | string | `""` |  |
| cliPod.extraInitContainers | list | `[]` | Additional init containers to add to cli pod. More info: `kubectl explain deployment.spec.template.spec.initContainers` |
| cliPod.extraVolumeMounts | list | `[]` | Extra volumeMounts for the configJob Job. More info: `kubectl explain deployment.spec.template.spec.containers.volumeMounts` |
| cliPod.extraVolumes | list | `[]` | Extra volumes for the configJob Job. More info: `kubectl explain deployment.spec.template.spec.volumes` |
| cliPod.image.pullPolicy | string | `nil` | The spotfireConfig image pull policy. Overrides global.spotfire.image.pullPolicy. |
| cliPod.image.pullSecrets | list | `[]` |  |
| cliPod.image.registry | string | `nil` | The image registry for spotfireConfig. Overrides global.spotfire.image.registry value. |
| cliPod.image.repository | string | `"spotfire/spotfire-config"` | The spotfireConfig image repository. |
| cliPod.image.tag | string | `"15.0.0-v7.0.0"` | The spotfireConfig container image tag to use. |
| cliPod.logLevel | string | `""` | Set to TRACE to increase log level. Defaults to DEBUG if unset. |
| cliPod.nodeSelector | object | `{}` |  |
| cliPod.podAnnotations | object | `{}` | Podannotations for cliPod |
| cliPod.podSecurityContext | object | `{}` | The podSecurityContext setting for cliPod More info: `kubectl explain deployment.spec.template.spec.securityContext` |
| cliPod.resources | object | `{}` | The resources setting for cliPod. |
| cliPod.securityContext | object | `{}` | The securityContext setting for cliPod. More info: `kubectl explain deployment.spec.template.spec.containers.securityContext` |
| cliPod.tolerations | list | `[]` |  |
| cliPod.topologySpreadConstraints | list | `[]` |  |
| configJob.affinity | object | `{}` |  |
| configJob.extraEnvVars | list | `[]` | Additional environment variables for all spotfire-server pods to use.  - name: NAME    value: value |
| configJob.extraEnvVarsCM | string | `""` |  |
| configJob.extraEnvVarsSecret | string | `""` |  |
| configJob.extraInitContainers | list | `[]` | Additional init containers to add to the Spotfire server configuration pod. More info: `kubectl explain job.spec.template.spec.initContainers` |
| configJob.extraVolumeMounts | list | `[]` | Extra volumeMounts for the configJob Job. More info: `kubectl explain job.spec.template.spec.containers.volumeMounts` |
| configJob.extraVolumes | list | `[]` | Extra volumes for the configJob Job. More info: `kubectl explain job.spec.template.spec.volumes` |
| configJob.image.pullPolicy | string | `nil` | The spotfireConfig image pull policy. Overrides `global.spotfire.image.pullPolicy` value. |
| configJob.image.pullSecrets | list | `[]` |  |
| configJob.image.registry | string | `nil` | The image registry for spotfireConfig. Overrides `global.spotfire.image.registry` value. |
| configJob.image.repository | string | `"spotfire/spotfire-config"` | The spotfireConfig image repository. |
| configJob.image.tag | string | `"15.0.0-v7.0.0"` | The spotfireConfig container image tag to use. |
| configJob.logLevel | string | `""` | Set verbosity for debugging config-job execution. Empty (default): Standard output with DEBUG logging from the configuration tool. `DEBUG`: Shows raw bash script lines + DEBUG-level configuration tool logging. `TRACE`: Shows expanded bash commands with values + TRACE-level configuration tool logging. |
| configJob.nodeSelector | object | `{}` |  |
| configJob.podAnnotations | object | `{}` | Podannotations for configJob |
| configJob.podSecurityContext | object | `{}` | The podSecurityContext setting for configJob. More info: `kubectl explain job.spec.template.spec.securityContext` |
| configJob.resources | object | `{}` | The resources setting for configJob. |
| configJob.securityContext | object | `{}` | The securityContext setting for configJob. More info: `kubectl explain job.spec.template.spec.containers.securityContext` |
| configJob.tolerations | list | `[]` |  |
| configJob.ttlSecondsAfterFinished | int | `7200` | Set the length of time in seconds to keep job and its logs until the job is removed. |
| configuration.actionLog | object | File logging enabled, database logging disabled. | Action log settings. See [config-action-logger](https://docs.tibco.com/pub/spotfire_server/latest/doc/html/TIB_sfire_server_tsas_admin_help/server/topics/config-action-logger.html) for more information. |
| configuration.actionLog.categories | string | `""` | Action log categories and webCategories are a comma separated list of categories. See [config-action-logger](https://docs.tibco.com/pub/spotfire_server/latest/doc/html/TIB_sfire_server_tsas_admin_help/server/topics/action_log_categories.html) for a list of possible categories. default value when empty is "all" |
| configuration.actionLog.database.config-action-log-database-logger | object | Configuration of actionlog database settings is only applicable if configuration.actionLog.enabled is true | Configure actionlog database. See [config-action-log-database-logger](https://docs.tibco.com/pub/spotfire_server/latest/doc/html/TIB_sfire_server_tsas_admin_help/server/topics/config-action-log-database-logger.html) for more information. |
| configuration.actionLog.database.config-action-log-database-logger.additionalOptions | object | `{}` | Additional Options. See [config-action-log-database-logger - Options](https://docs.tibco.com/pub/spotfire_server/latest/doc/html/TIB_sfire_server_tsas_admin_help/server/topics/config-action-log-database-logger.html) for more information. |
| configuration.actionLog.database.config-action-log-database-logger.password | string | `""` | The password to be created for the Spotfire Actionlog database user. If not provided, this password is automatically generated. |
| configuration.actionLog.database.config-action-log-database-logger.username | string | `"spotfire_actionlog"` | The user to create for actionlog database access |
| configuration.actionLog.database.create-actionlogdb | object | Actionlog database is created only if configuration.actionLog.enabled is true | Create the actionlog database. See [create-actionlogdb](https://docs.tibco.com/pub/spotfire_server/latest/doc/html/TIB_sfire_server_tsas_admin_help/server/topics/create-actionlogdb.html) for more information. |
| configuration.actionLog.database.create-actionlogdb.actiondbDbname | string | `"spotfire_actionlog"` | Name for the Actionlog Database to be created to hold the Actionlog database table. |
| configuration.actionLog.database.create-actionlogdb.adminPassword | string | `""` | Admin password for the actionlog database. |
| configuration.actionLog.database.create-actionlogdb.adminPasswordExistingSecret | object | Not used unless .name is set | Read spotfire actionlog database password from an existing secret. If set, 'adminPassword' above is not used. |
| configuration.actionLog.database.create-actionlogdb.adminUsername | string | `"postgres"` | Admin username for the actionlog database. |
| configuration.actionLog.database.create-actionlogdb.databaseUrl | string | `"jdbc:postgresql://HOSTNAME/"` | Like `configuration.actionLog.database.config-action-log-database-logger.databaseUrl` but is used for the connection when creating the actionlog database. Evaluated as a template. |
| configuration.actionLog.database.create-actionlogdb.doNotCreateUser | bool | `false` | Set this to true, in case supported databases (AWS Postgres, Aurora Postgres, Azure Postgres, Google Cloud Postgres) does not allow user creation or the actionlog records are being stored on the spotfire database. |
| configuration.actionLog.database.create-actionlogdb.enabled | bool | `true` | if enabled is true, create the actionlog database |
| configuration.actionLog.database.create-actionlogdb.oracleRootfolder | string | `""` | Specify the value in case of Oracle database, otherwise keep it blank. |
| configuration.actionLog.database.create-actionlogdb.timeoutSeconds | string | `""` | Specifies the timeout, in seconds, for the operation. |
| configuration.actionLog.database.create-actionlogdb.variant | string | `""` | For connecting to MS SQL or Oracle on Amazon RDS, specify `rds`, for MS SQL on Azure, specify `azure`, otherwise omit the option. |
| configuration.apply | string | `"initialsetup"` | When to apply configurationScripts, commandScripts, admin user creation and action log settings. Possible values: * "always" = Apply on every `helm install` or `helm upgrade`. Note: Configuration made from other tools than helm might be overwritten when updating the helm release. * "initialsetup" = Only apply if Spotfire server database does not already have a configuration. It is suitable for setting up the initial configuration of the environment but where further configuration is done using the spotfire configuration tool. * "never" = Do not apply. Configuration must be configured using the spotfire configuration tool directly towards the database. |
| configuration.commandScripts | list | `[]` | A list of command scripts to run during helm installation. These commands will run once only and not subsequent helm release upgrades. Each list item should have the keys `name` and `script`. See [config.sh run script](https://docs.tibco.com/pub/spotfire_server/latest/doc/html/TIB_sfire_server_tsas_admin_help/server/topics/scripting_a_configuration.html). Commands in these scripts should NOT operate on `configuration.xml`. Operations such as adding/removing users and assigning licenses are typical administrative commands that can be specified here. |
| configuration.configurationScripts | list | `[]` | A list of configuration scripts to apply during helm installation. Each list item should have the keys `name` and `script`. See [config.sh run script](https://docs.tibco.com/pub/spotfire_server/latest/doc/html/TIB_sfire_server_tsas_admin_help/server/topics/scripting_a_configuration.html). Commands in these scripts should operate only on a local `configuration.xml`. Commands such as `set-config-prop` and `modify-ds-template` are examples of commands that can be used here. The local `configuration.xml` file is automatically imported after all configuration steps run in the order in which they are defined below. |
| configuration.deployment.clear | bool | `false` | Clear existing packages before any new files are added. Setting it `true` can cause extra delay because packages need to be added again every time the config-job is run. |
| configuration.deployment.defaultDeployment.deploymentAreaName | string | `"Production"` | The name of the deployment area to create or update |
| configuration.deployment.defaultDeployment.enabled | bool | `true` | Create deployment area with default Spotfire.Dxp.sdn taken from spotfire-deployment image. *Warning*: If set to `true` and a deployment volume (see `volumes.deployments` key) is used, a folder with name `deploymentAreaName` will be created and potentially overwrite any existing deployment with the same name on the persistent volume. |
| configuration.deployment.defaultDeployment.image.pullPolicy | string | `nil` | The spotfire-deployment image pull policy. Overrides `global.spotfire.image.pullPolicy`. |
| configuration.deployment.defaultDeployment.image.pullSecrets | list | `[]` |  |
| configuration.deployment.defaultDeployment.image.registry | string | `nil` | The image registry for spotfire-deployment. Overrides `global.spotfire.image.registry` value. |
| configuration.deployment.defaultDeployment.image.repository | string | `"spotfire/spotfire-deployment"` | The spotfire-deployment image repository. |
| configuration.deployment.defaultDeployment.image.tag | string | `"15.0.0-v7.0.0"` | The container image tag to use. |
| configuration.deployment.defaultDeployment.resources | object | `{}` | The resources setting for defaultDeployment. |
| configuration.deployment.enabled | bool | `true` | When enabled spotfire deployment areas will be created by the configuration job. See also `volumes.deployment`. |
| configuration.draining | object | `{"enabled":true,"minimumSeconds":90,"publishNotReadyAddresses":true,"timeoutSeconds":180}` | Configuration of the Spotfire Server container lifecycle PreStop hook. |
| configuration.draining.enabled | bool | `true` | Enables or disables the container lifecycle PreStop hook. |
| configuration.draining.minimumSeconds | int | `90` | The minimum time in seconds that the server should be draining, even if it is considered idle. |
| configuration.draining.publishNotReadyAddresses | bool | `true` | Makes sure that service SRV records are preserved while terminating pods, typically used with the spotfire haproxy deployment. |
| configuration.draining.timeoutSeconds | int | `180` | The draining timeout in seconds after which the service is forcibly shut down. |
| configuration.encryptionPassword | string | `""` | The password for encrypting passwords that are stored in the database. If you do not set this option, then a static password is used. See \-\-encryption-password for the [bootstrap](https://docs.tibco.com/pub/spotfire_server/latest/doc/html/TIB_sfire_server_tsas_admin_help/server/topics/bootstrap.html) command. |
| configuration.preConfigCommandScripts | list | `[]` | The same as `commandScripts` but these command will be run before the configuration is imported. On new installations the commands will be run before any spotfire servers are started, because spotfire server will not start before there is a configuration. |
| configuration.preferExistingConfig | bool | `false` | Run the configuration job steps starting from the currently active configuration or from the Spotfire default config (created with `config.sh create-default-config`). If no current active configuration exists, the default config is used. Note: When set to false, all configuration done with external tools other than helm will be overwritten on an upgrade. |
| configuration.properties | object | Default values for kubernetes, see values.yaml. | Configuration properties The key name is the name of the property to set. If the value is a scalar the configuration tool command `set-config-prop` is used. To set a list or map the value should have the keys `itemName` and `value`. If the value is a map or object the configuration tool command `set-config-map-prop` is used. If the value is a list the configuration tool command `set-config-list-prop` is used. |
| configuration.site | object | Spotfire Server joins the Default site. | Site settings. See [sites](https://docs.tibco.com/pub/spotfire_server/latest/doc/html/TIB_sfire_server_tsas_admin_help/server/topics/sites.html) for more information. |
| configuration.site.name | string | `"Default"` | The name of the site that the Spotfire Server should belong to. The site must be created beforehand. See [create-site](https://docs.tibco.com/pub/spotfire_server/latest/doc/html/TIB_sfire_server_tsas_admin_help/server/topics/create-site.html) for more information. |
| configuration.site.publicAddress | string | `""` | The address that clients use for connecting to the system. It is also used for generating absolute URLs. |
| configuration.spotfireAdmin.create | bool | `true` | Whether to create an admin user or not. |
| configuration.spotfireAdmin.password | string | `""` | The password to create for the Spotfire admin. If not provided, this password is automatically generated. Although possible, it is not recommended to change the user's password directly in the Spotfire administrative user interface because the password is reset to this value on every helm installation or upgrade. |
| configuration.spotfireAdmin.passwordExistingSecret | object | Not used unless .name is set | Read password from an existing secret instead of from values. If set, 'password' above is not used. |
| configuration.spotfireAdmin.username | string | `"admin"` | The user to create for the Spotfire admin. |
| database.bootstrap | object | - | For details related to bootstrap properties, visit the product documentation [here](https://docs.tibco.com/pub/spotfire_server/latest/doc/html/TIB_sfire_server_tsas_admin_help/server/topics/bootstrap.html). |
| database.bootstrap.databaseUrl | string | `"jdbc:postgresql://HOSTNAME/spotfire"` | The JDBC URL of the database to be used by Spotfire Server. Evaluated as a template. |
| database.bootstrap.password | string | `""` | Password to be created for the Spotfire Server database. If not provided, this password is automatically generated. |
| database.bootstrap.passwordExistingSecret | object | Not used unless .name is set | Read spotfire database password from an existing secret. If set, 'password' above is not used. |
| database.bootstrap.username | string | `"spotfire"` | Username to be created for the Spotfire Server database. If unset, the default value `spotfire` is used. |
| database.create-db | object | - | For details related to `create-db` cli properties, visit the product documentation [here](https://docs.tibco.com/pub/spotfire_server/latest/doc/html/TIB_sfire_server_tsas_admin_help/server/topics/create-db.html). create-db cli also uses properties from database.bootstrap section. |
| database.create-db.adminPassword | string | `""` | Admin password for the database server to be used as the Spotfire Server database. |
| database.create-db.adminPasswordExistingSecret | object | Not used unless .name is set | Read admin password from an existing secret. If set, 'password' above is not used. |
| database.create-db.adminUsername | string | `"postgres"` | Admin username for the database server to be used as the Spotfire Server database. |
| database.create-db.databaseUrl | string | `"jdbc:postgresql://HOSTNAME/"` | Like `database.bootstrap.databaseUrl` but is used for the connection when creating the spotfire database. Evaluated as a template. |
| database.create-db.doNotCreateUser | bool | `false` | Set this to true, in case supported databases (AWS Postgres, Aurora Postgres, Azure Postgres, Google Cloud Postgres) does not allow user creation |
| database.create-db.enabled | bool | `true` | if set to true, Spotfire server schema will also get deployed with other installation. |
| database.create-db.oracleRootfolder | string | `""` | Specify the value in case of Oracle database, otherwise keep it blank. |
| database.create-db.oracleTablespacePrefix | string | `""` | Specify the value in case of Oracle database, otherwise keep it blank. |
| database.create-db.spotfiredbDbname | string | `"spotfire"` | Database name to be created to hold the Spotfire Server database schemas. |
| database.create-db.variant | string | `""` | For connecting to MS SQL or Oracle on Amazon RDS, specify `rds`, for MS SQL on Azure, specify `azure`, otherwise omit the option. |
| database.upgrade | bool | `false` | Often new Spotfire server version requires an upgraded database. If true, the database will be upgrade to match the server version being deployed. |
| database.upgradeOptions | string | `""` | Additional arguments to pass to the Spotfire Server upgrade tool. See [Upgrading Spotfire](https://docs.tibco.com/pub/spotfire_server/latest/doc/html/TIB_sfire_server_tsas_admin_help/server/topics/upgrading_spotfire.html) and [Running the Spotfire Server upgrade tool silently](https://docs.tibco.com/pub/spotfire_server/latest/doc/html/TIB_sfire_server_tsas_admin_help/server/topics/running_the_spotfire_server_upgrade_tool_silently.html) for more information. |
| extraContainers | list | `[]` | Additional sidecar containers to add to the Spotfire server pod. More info: `kubectl explain deployment.spec.template.spec.containers` |
| extraEnvVars | list | `[]` | Additional environment variables that all spotfire-server pods use. |
| extraEnvVarsCM | string | `""` |  |
| extraEnvVarsSecret | string | `""` |  |
| extraInitContainers | list | `[]` | Additional init containers to add to Spotfire server pod. More info: `kubectl explain deployment.spec.template.spec.initContainers` |
| extraVolumeMounts | list | `[]` | Extra volumeMounts for the spotfire-server container. More info: `kubectl explain deployment.spec.template.spec.containers.volumeMounts` |
| extraVolumes | list | `[]` | Extra volumes for the spotfire-server container. More info: `kubectl explain deployment.spec.template.spec.volumes` |
| fluentBitSidecar.image.pullPolicy | string | `"IfNotPresent"` | The image pull policy for the fluent-bit logging sidecar image. |
| fluentBitSidecar.image.repository | string | `"fluent/fluent-bit"` | The image repository for fluent-bit logging sidecar. |
| fluentBitSidecar.image.tag | string | `"4.2.3"` | The image tag to use for fluent-bit logging sidecar. |
| fluentBitSidecar.resources | object | `{}` | The resources setting for fluent-bit sidecar container. |
| fluentBitSidecar.securityContext | object | `{}` | The securityContext setting for fluent-bit sidecar container. Overrides any securityContext setting on the Pod level. More info: `kubectl explain pod.spec.securityContext` |
| haproxy.config | string | The chart creates a configuration automatically. | The haproxy configuration file template. For implementation details see templates/haproxy-config.tpl. |
| haproxy.enabled | bool | `true` |  |
| haproxy.image | object | `{"tag":"3.2.19"}` | overrides haproxy chart default values. See [HAProxy Helm Chart](https://github.com/haproxytech/helm-charts/tree/main/haproxy) |
| haproxy.image.tag | string | `"3.2.19"` | overrides the image tag whose default is the haproxy chart appVersion. Use empty string to use the chart default or pick [a specific version](https://hub.docker.com/r/haproxytech/haproxy-alpine/tags?name=3.2). |
| haproxy.includes | object | `{}` |  |
| haproxy.includesMountPath | string | `"/etc/haproxy/includes"` |  |
| haproxy.kind | string | `"Deployment"` |  |
| haproxy.podAnnotations | object | `{"prometheus.io/path":"/metrics","prometheus.io/port":"1024","prometheus.io/scrape":"true"}` | Prometheus annotations. Should match the haproxy.config settings. |
| haproxy.podLabels."app.kubernetes.io/component" | string | `"haproxy"` |  |
| haproxy.podLabels."app.kubernetes.io/part-of" | string | `"spotfire"` |  |
| haproxy.podSecurityPolicy.create | bool | `false` |  |
| haproxy.service.type | string | `"ClusterIP"` | Sets the service haproxy service proxies traffic to the spotfire-server service. ClusterIP or LoadBalancer. |
| haproxy.spotfireConfig | object | Caching of static resource and debug response headers enabled. | Spotfire specific configuration related to haproxy. |
| haproxy.spotfireConfig.agent.port | int | `9081` | Spotfire Server haproxy agent-port. |
| haproxy.spotfireConfig.cache | object | enabled | Caching of static resources |
| haproxy.spotfireConfig.captures.forwardedForLength | int | `36` | The maximum number of characters captured from the X-Forwarded-For request header |
| haproxy.spotfireConfig.cleanup.sameSiteCookieAttributeForHttp | bool | `true` | If the SameSite cookie attribute should be removed for HTTP connections in Set-Cookie response headers, then it might be needed in cases where both HTTP and HTTPS are enabled, and upstream servers set this unconditionally. |
| haproxy.spotfireConfig.cleanup.secureCookieAttributeForHttp | bool | `true` | If incorrect, then the secure cookie attribute should be removed for HTTP connections in the Set-Cookie response headers. |
| haproxy.spotfireConfig.debug | bool | `false` | Specifies if debug response headers should be enabled. |
| haproxy.spotfireConfig.globals | object | haproxy globals in the Spotfire provided configuration. | Global configuration parameters in the Spotfire provided configuration. |
| haproxy.spotfireConfig.globals.log | string | `"stdout format raw local0"` | The haproxy log configuration. See [haproxy log formats](https://cbonte.github.io/haproxy-dconv/2.6/configuration.html#8.2) for more information. |
| haproxy.spotfireConfig.globals.maxconn | int | `1024` | Sets the maximum per-process number of concurrent connections. See [haproxy maxconn](https://cbonte.github.io/haproxy-dconv/2.6/configuration.html#maxconn) for more information. |
| haproxy.spotfireConfig.haproxy | object | additional settings | Additional settings for various settings in the default spotfire haproxy configuration. |
| haproxy.spotfireConfig.haproxy.defaults | string | `nil` | The haproxy defaults section. See [haproxy proxies](https://docs.haproxy.org/3.0/configuration.html#4). |
| haproxy.spotfireConfig.haproxy.frontend | string | `nil` | The haproxy spotfire frontend section. See [haproxy proxies](https://docs.haproxy.org/3.0/configuration.html#4). |
| haproxy.spotfireConfig.haproxy.global | string | `nil` | The haproxy global section. See [haproxy global](https://docs.haproxy.org/3.0/configuration.html#3). |
| haproxy.spotfireConfig.haproxy.stats | string | `nil` | The haproxy metrics and status frontend section. See [haproxy proxies](https://docs.haproxy.org/3.0/configuration.html#4). |
| haproxy.spotfireConfig.loadBalancingCookie | object | stateless load balancing | Cookie-related configuration. |
| haproxy.spotfireConfig.loadBalancingCookie.attributes | string | `"insert indirect nocache dynamic httponly secure attr \"SameSite=None\""` | Attributes for the cookie value in the haproxy config. See [haproxy cookie](https://cbonte.github.io/haproxy-dconv/2.6/configuration.html#4.2-cookie) for more information. |
| haproxy.spotfireConfig.loadBalancingCookie.dynamicCookieKey | string | the cookie key | dynamic-cookie-key value in the haproxy config. |
| haproxy.spotfireConfig.maintenance | object | disabled | Maintenance mode, can be used to temporarily block requests (but still allow some, see allowCookie below). |
| haproxy.spotfireConfig.maintenance.allowCookie | object | disabled | Allowed requests in maintenance mode by configuring a cookie for allowed requests. |
| haproxy.spotfireConfig.maintenance.allowCookie.enabled | bool | `false` | Specifies if a cookie can be used to access the environment while maintenance mode is enabled. |
| haproxy.spotfireConfig.maintenance.allowCookie.name | string | `""` | The name of the cookie, case sensitive |
| haproxy.spotfireConfig.maintenance.allowCookie.value | string | `""` | The value of the cookie, case sensitive |
| haproxy.spotfireConfig.maintenance.enabled | bool | `false` | Specifies if maintenance mode is enabled. |
| haproxy.spotfireConfig.maintenancePage | object | maintenance page related settings | A custom maintenance page that is displayed if maintenance mode is enabled or if no Spotfire Server instances are running |
| haproxy.spotfireConfig.maintenancePage.bufSize | int | `24576` | For larger files, haproxy tune.bufsize may need to be increased to accommodate the larger size. |
| haproxy.spotfireConfig.maintenancePage.responseString | string | `"<html><title>Maintenance - </title><body>Maintenance in progress</body></html>"` | The maintenance page response string. |
| haproxy.spotfireConfig.maintenancePage.useFile | bool | `false` | If a haproxy include file,  haproxy.includes.'maintenance\\.html'=<path to file>, should be used instead of haproxy.maintenancePage.responseString below. |
| haproxy.spotfireConfig.serverTemplate.additionalParams | string | `"on-marked-down shutdown-sessions"` | Additional parameters, see [haproxy server](https://cbonte.github.io/haproxy-dconv/2.6/snapshot/configuration.html#server%20%28Alphabetically%20sorted%20keywords%20reference%29) |
| haproxy.spotfireConfig.timeouts.client | string | `"30m"` | See [haproxy timeout client](https://cbonte.github.io/haproxy-dconv/2.6/configuration.html#4.2-timeout%20client). |
| haproxy.spotfireConfig.timeouts.connect | string | `"300ms"` | See [haproxy timeout connect](https://cbonte.github.io/haproxy-dconv/2.6/configuration.html#4.2-timeout%20connect). |
| haproxy.spotfireConfig.timeouts.httpRequest | string | `"3600s"` | See [haproxy timeout http-request](https://cbonte.github.io/haproxy-dconv/2.6/configuration.html#4.2-timeout%20http-request). |
| haproxy.spotfireConfig.timeouts.queue | string | `"60s"` | See [haproxy timeout queue](https://cbonte.github.io/haproxy-dconv/2.6/configuration.html#4-timeout%20queue). |
| haproxy.spotfireConfig.timeouts.server | string | `"30m"` | See [haproxy timeout server](https://cbonte.github.io/haproxy-dconv/2.6/configuration.html#4.2-timeout%20server). |
| haproxy.spotfireConfig.timeouts.tunnel | string | `"31m"` | See [haproxy timeout tunnel](https://cbonte.github.io/haproxy-dconv/2.6/configuration.html#4.2-timeout%20tunnel). |
| image.pullPolicy | string | `nil` | The spotfire-server image pull policy. Overrides `global.spotfire.image.pullPolicy`. |
| image.pullSecrets | list | `[]` | spotfire-deployment image pull secrets. |
| image.registry | string | `nil` | The image registry for spotfire-server. Overrides `global.spotfire.image.registry` value. |
| image.repository | string | `"spotfire/spotfire-server"` | The spotfire-server image repository. |
| image.tag | string | `"15.0.0-v7.0.0"` | The container image tag to use. |
| ingress.annotations | object | `{}` | Annotations for the ingress object. See documentation for your ingress controller for valid annotations. |
| ingress.enabled | bool | `false` | Enables configuration of ingress to expose Spotfire Server. Requires ingress support in the Kubernetes cluster. |
| ingress.hosts[0].host | string | `"spotfire.local"` |  |
| ingress.hosts[0].paths[0].path | string | `"/"` |  |
| ingress.hosts[0].paths[0].pathType | string | `"Prefix"` |  |
| ingress.ingressClassName | string | `""` | IngressClass that will be be used for the Ingress (Kubernetes 1.18+) ref: https://kubernetes.io/blog/2020/04/02/improvements-to-the-ingress-api-in-kubernetes-1.18/ |
| ingress.servicePort | int | `80` | The haproxy service port that the ingress will route traffic to. |
| ingress.tls | list | `[]` |  |
| kedaAutoscaling | object | Disabled | KEDA autoscaling configuration. See https://keda.sh/docs/latest/concepts/scaling-deployments for more details. |
| kedaAutoscaling.cooldownPeriod | int | `300` | The period to wait after the last trigger reported active before scaling the resource back to 0. |
| kedaAutoscaling.maxReplicas | int | `4` | This setting is passed to the HPA definition that KEDA creates for a given resource and holds the maximum number of replicas of the target resource. |
| kedaAutoscaling.minReplicas | int | `1` | The minimum number of replicas KEDA scales the resource down to. |
| kedaAutoscaling.pollingInterval | int | `30` | The interval to check each trigger on. |
| kedaAutoscaling.spotfireConfig | object | `{"prometheusServerAddress":"http://prometheus-server.monitor.svc.cluster.local"}` | Spotfire specific settings. |
| kedaAutoscaling.spotfireConfig.prometheusServerAddress | string | `"http://prometheus-server.monitor.svc.cluster.local"` | REQUIRED. The URL to the Prometheus server where metrics should be fetched from. |
| livenessProbe.enabled | bool | `true` |  |
| livenessProbe.failureThreshold | int | `3` |  |
| livenessProbe.httpGet.path | string | `"/spotfire/rest/status/getStatus"` |  |
| livenessProbe.httpGet.port | string | `"service"` |  |
| livenessProbe.periodSeconds | int | `3` |  |
| log-forwarder.config.filters | string | Example that drops specific events using [grep](https://docs.fluentbit.io/manual/pipeline/filters/grep) | Add custom fluent-bit [filters configuration](https://docs.fluentbit.io/manual/pipeline/filters). |
| log-forwarder.config.inputs | string | [tcp input](https://docs.fluentbit.io/manual/pipeline/inputs/tcp) on port 5170 and [forward input](https://docs.fluentbit.io/manual/pipeline/inputs/forward) on port 24224 | fluent-bit [input configuration](https://docs.fluentbit.io/manual/pipeline/inputs). |
| log-forwarder.config.outputs | string | Logs are written to stdout of the log-forwarder pod. | Override this value with an [output configuration](https://docs.fluentbit.io/manual/pipeline/outputs) to send logs to an external system. |
| log-forwarder.enabled | bool | `true` | enables or disables the fluent-bit log-forwarder pod. If enabled, it collects logs from the spotfire-server pods and can forward traffic to any output supported by fluent-bit. |
| log-forwarder.extraPorts[0].containerPort | int | `5170` |  |
| log-forwarder.extraPorts[0].name | string | `"json"` |  |
| log-forwarder.extraPorts[0].port | int | `5170` |  |
| log-forwarder.extraPorts[0].protocol | string | `"TCP"` |  |
| log-forwarder.extraPorts[1].containerPort | int | `24224` |  |
| log-forwarder.extraPorts[1].name | string | `"forward"` |  |
| log-forwarder.extraPorts[1].port | int | `24224` |  |
| log-forwarder.extraPorts[1].protocol | string | `"TCP"` |  |
| log-forwarder.image.pullPolicy | string | `"IfNotPresent"` |  |
| log-forwarder.kind | string | `"Deployment"` |  |
| log-forwarder.labels."app.kubernetes.io/component" | string | `"logging"` |  |
| log-forwarder.labels."app.kubernetes.io/part-of" | string | `"spotfire"` |  |
| log-forwarder.podAnnotations."prometheus.io/path" | string | `"/api/v1/metrics/prometheus"` |  |
| log-forwarder.podAnnotations."prometheus.io/port" | string | `"2020"` |  |
| log-forwarder.podAnnotations."prometheus.io/scrape" | string | `"true"` |  |
| log-forwarder.podLabels."app.kubernetes.io/component" | string | `"logging"` |  |
| log-forwarder.podLabels."app.kubernetes.io/part-of" | string | `"spotfire"` |  |
| log-forwarder.rbac.create | bool | `false` | Specifies whether to create an RBAC for the fluent-bit / log-forwarder. Setting this to `true` requires additional privileges in the Kubernetes cluster. |
| log-forwarder.service.labels."app.kubernetes.io/component" | string | `"logging"` |  |
| log-forwarder.service.labels."app.kubernetes.io/part-of" | string | `"spotfire"` |  |
| logging.logForwarderAddress | string | `""` | Specifies a logForwarderAddress. If left empty, then the default `log-forwarder` is used in the case where `log-forwarder.enabled=true`. Template. |
| logging.logLevel | string | `""` | The Spotfire Server log-level. Set to `debug`, `trace`, `minimal` or leave empty for info. |
| nodeSelector | object | `{}` |  |
| podAnnotations."prometheus.io/path" | string | `"/spotfire/metrics"` |  |
| podAnnotations."prometheus.io/port" | string | `"9080"` |  |
| podAnnotations."prometheus.io/scrape" | string | `"true"` |  |
| podDeletionCost | object | Default values for Pod Deletion Cost, see values.yaml. | Pod Deletion Cost update configuration. See https://kubernetes.io/docs/concepts/workloads/controllers/replicaset/#pod-deletion-cost for more details. |
| podDeletionCost.costFormula | string | `"-1000*spotfire_SpotfireServer_IsIdle + spotfire_InformationServices_InformationServicesMetrics_InformationServicesJobs + spotfire_SpotfireServer_ServerMetrics_UploadingAttachments"` | An awk formula using the Prometheus metric names to calculate deletion cost. Missing or not found metrics default to 0. |
| podDeletionCost.enabled | bool | `false` | Enable updating of pod deletion cost annotation. |
| podDeletionCost.image.pullPolicy | string | `"IfNotPresent"` | Image pull policy for the podDeletionCost. |
| podDeletionCost.image.pullSecrets | list | `[]` | Image pull secrets for the podDeletionCost. |
| podDeletionCost.image.registry | string | `nil` | Image registry for the podDeletionCost. |
| podDeletionCost.image.repository | string | `"spotfire/spotfire-config"` | Image repository for the podDeletionCost. |
| podDeletionCost.image.tag | string | `"15.0.0-v7.0.0"` | Image tag for the podDeletionCost. |
| podDeletionCost.minAbsDelta | string | `"5"` | Minimum numeric change to trigger a patch. |
| podDeletionCost.replicaCount | int | `1` | Number of replicas. |
| podDeletionCost.resources | object | `{}` | Specifies the standard Kubernetes resource requests and/or limits |
| podDeletionCost.sleepIntervalSeconds | string | `"120"` | How long to wait between checks (seconds). |
| podDeletionCost.thresholdPercent | string | `"10"` | Minimum % change to trigger a patch. |
| podSecurityContext | object | `{}` | The Pod securityContext setting applies to all the containers inside the Pod. More info: `kubectl explain deployment.spec.template.spec.securityContext` |
| readinessProbe.enabled | bool | `false` |  |
| replicaCount | int | `1` | The number of Spotfire Server containers. |
| resources | object | `{}` |  |
| securityContext | object | `{}` | The securityContext setting for spotfire-server container. Overrides any securityContext setting on the Pod level. More info: `kubectl explain deployment.spec.template.spec.containers.securityContext` |
| service.clusterIP | string | `"None"` |  |
| service.type | string | `"ClusterIP"` |  |
| serviceAccount.annotations | object | `{}` |  |
| serviceAccount.create | bool | `true` |  |
| serviceAccount.name | string | `""` |  |
| spotfireServerJava.extraJavaOpts | list | `[]` | Additional `JAVA_OPTS` for spotfire-server pods. |
| startupProbe.enabled | bool | `true` |  |
| startupProbe.failureThreshold | int | `30` |  |
| startupProbe.httpGet.path | string | `"/spotfire/rest/status/getStatus"` |  |
| startupProbe.httpGet.port | string | `"service"` |  |
| startupProbe.initialDelaySeconds | int | `60` |  |
| startupProbe.periodSeconds | int | `10` |  |
| tolerations | list | `[]` |  |
| toolPassword | string | `""` | The Spotfire config tool password to use for `bootstrap.xml`. If not provided, this password is automatically generated. The password is only used locally inside pods for use to together with the configuration and is not usable for anything outside the pod. |
| topologySpreadConstraints | list | `[]` |  |
| troubleshooting.jvm.heapDumpOnOutOfMemoryError.dumpPath | string | `"/opt/spotfire/troubleshooting/jvm-heap-dumps"` | Define a path where the generated dump is exported. By default, this gets mounted in EmptyDir: {} internally, which survives container restarts. In case you want to persist troubleshooting information to an external location, you can override the default behaviour by specifying PVC in `volumes.troubleshooting`. |
| troubleshooting.jvm.heapDumpOnOutOfMemoryError.enabled | bool | `true` | Enable or disable for a heap dump in case of OutOfMemoryError. |
| volumes.certificates.existingClaim | string | `""` |  |
| volumes.certificates.subPath | string | `""` | The subPath of the volume to be used for the volume mount |
| volumes.customExt.existingClaim | string | `""` | Defines an already-existing persistent volume claim. |
| volumes.customExt.subPath | string | `""` | The subPath of the volume to be used for the volume mount |
| volumes.customExtInformationservices.existingClaim | string | `""` | Defines an already-existing persistent volume claim. |
| volumes.customExtInformationservices.subPath | string | `""` | The subPath of the volume to be used for the volume mount |
| volumes.deployments.existingClaim | string | `""` | Defines an already-existing persistent volume claim. |
| volumes.deployments.subPath | string | `""` | The subPath of the volume to be used for the volume mount |
| volumes.libraryImportExport.existingClaim | string | `""` | When `persistentVolumeClaim.create` is `false`, then this value is used to define an already-existing PVC. |
| volumes.libraryImportExport.persistentVolumeClaim.create | bool | `false` | If `true`, then a `PersistentVolumeClaim` (PVC) is created. |
| volumes.libraryImportExport.persistentVolumeClaim.resources | object | `{"requests":{"storage":"1Gi"}}` | Specifies the standard Kubernetes resource requests and/or limits for the `volumes.libraryImportExport` PVC. |
| volumes.libraryImportExport.persistentVolumeClaim.storageClassName | string | `""` | Specifies the name of the `StorageClass` to use for the `volumes.libraryImportExport` PVC. |
| volumes.libraryImportExport.persistentVolumeClaim.volumeName | string | `nil` | Specifies the name of the persistent volume to use for the `volumes.libraryImportExport` PVC. |
| volumes.libraryImportExport.subPath | string | `""` | The subPath of the volume to be used for the volume mount |
| volumes.troubleshooting.existingClaim | string | `""` | When `persistentVolumeClaim.create` is `false`, then use this value to define an already-existing PVC. |
| volumes.troubleshooting.persistentVolumeClaim.create | bool | `false` | If `true`, then a `PersistentVolumeClaim` (PVC) is created. |
| volumes.troubleshooting.persistentVolumeClaim.resources | object | `{"requests":{"storage":"2Gi"}}` | Specifies the standard K8s resource requests and/or limits for the `volumes.troubleshooting` PVC. |
| volumes.troubleshooting.persistentVolumeClaim.storageClassName | string | `""` | Specifies the name of the `StorageClass` that to use for the `volumes.troubleshooting` PVC. |
| volumes.troubleshooting.persistentVolumeClaim.volumeName | string | `nil` | Specifies the name of the persistent volume to use for the `volumes.troubleshooting` PVC. |
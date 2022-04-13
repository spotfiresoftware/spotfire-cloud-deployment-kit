# spotfire-server

![Version: 0.1.0](https://img.shields.io/badge/Version-0.1.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 11.8.1](https://img.shields.io/badge/AppVersion-11.8.1-informational?style=flat-square)

A Helm chart for TIBCO Spotfire Server.

## Requirements

| Repository | Name | Version |
|------------|------|---------|
| file://../spotfire-common | spotfire-common | 0.1.0 |
| https://fluent.github.io/helm-charts | log-forwarder(fluent-bit) | 0.19.19 |
| https://haproxytech.github.io/helm-charts | haproxy | 1.10.0 |

## Overview

This chart deploys the [TIBCO Spotfire® Server](https://docs.tibco.com/pub/spotfire_server/latest/doc/html/TIB_sfire_server_tsas_admin_help/server/topics/introduction_to_the_tibco_spotfire_environment.html) on a [Kubernetes](http://kubernetes.io/) cluster using the [Helm](https://helm.sh/) package manager.

Using this chart, you can also deploy the following:
- The required Spotfire Server database schemas on a supported database server (e.g. Postgres).
- A reverse proxy ([HAProxy](https://www.haproxy.org/)) for accessing the Spotfire Server cluster service, with session affinity for external HTTP access.
- An ([Ingress](https://kubernetes.io/docs/concepts/services-networking/ingress/)) with routing rules for accessing the configured reverse proxy.
- Shared storage locations ([Persistent Volumes](https://kubernetes.io/docs/concepts/storage/persistent-volumes/)) for the Spotfire Library import and export, custom jars, deployment packages, etc.

The Spotfire Server pod includes:
- A [Fluent Bit](https://fluentbit.io/) sidecar container for log forwarding.
- Service annotations for [Prometheus](https://prometheus.io/) scrapers. The Prometheus server will discover the service endpoint using these specifications and will scrape metrics from the exporter.

This chart has been tested to work with [NGINX Ingress Controller](https://github.com/kubernetes/ingress-nginx), [Elasticsearch](www.elastic.co/products/elasticsearch) and [Prometheus](https://prometheus.io/).

## Prerequisites

- Kubernetes 1.23+
- Helm 3+
- Ingress controller (optional)
- PV (Persistent Volume) provisioner support in the underlying infrastructure (optional)
- A supported database server for usage as the Spotfire database

**Note**: For information on supported databases, see [Spotfire Server requirements](https://docs.tibco.com/pub/spotfire/general/sr/GUID-D72E1F55-7688-4941-B458-0C1217A84D9A.html).

**Note**: The database server can be installed within the same kubernetes cluster, on premises, or using a cloud database service.

**Note**: You are familiar with kubernetes, containers and helm concepts and usage.

## Usage

### Install

To install the chart with the release name `my-release` and the values from the file `my-values`:
```bash
helm install my-release -f my-values.yml .
```

**Note**: The Spotfire Server chart requires some variables to start (e.g.: database server connection details).
See examples and variables description below.

### Uninstall

To uninstall the `my-release` deployment:
```bash
helm uninstall my-release
```

#### Delete any remaining resources

**Note**: Normally all the services and pods will be deleted using `helm uninstall`.
But occasionally you may need to manually delete existing Spotfire Persistence Volume Claims or not completed Jobs due interrupted operation or wrong setup.

In order to delete the release related Jobs, you can run:
```bash
kubectl delete job.batch/my-release-spotfire-server-basic-config-job
```

In order to free up the storage you need to manually delete all the Persistent Volume Claims.
You can do this by running:
```bash
kubectl get pvc
```

And then delete the ones that you don’t want to keep:
```bash
kubectl delete pvc <PVC ids here>
```

As an alternative, you can delete the kubernetes namespace that contains these resources.

### Scaling

For scaling the `my-release` deployment, just do a helm upgrade providing the target number of pod instances in the `replicaCount` variable.
```bash
helm upgrade --install my-release . --reuse-values --set replicaCount=3
```

#### Autoscaling with KEDA

[KEDA](https://keda.sh/docs) can be used for autoscaling.
For that, KEDA must be installed in the k8s cluster, as well as a Prometheus instance that scrapes metrics from the Spotfire pods.

Example: A `values.yml` snippet configuration for enabling autoscaling with KEDA:
```
kedaAutoscaling:
  enabled: true
  spotfireConfig:
    prometheusServerAddress: http://prometheus-server.monitor.svc.cluster.local
  threshold: 60
  minReplicas: 1
  maxReplicas: 3
```

The threshold value determines what the value of the query has to be before the service is scaled.

For the `spotfire-server`, the default autoscaling metric used is the `spotfire_OS_OperatingSystem_ProcessCpuLoad`.
And the default query used is the sum of CPU usage (in percent) of all Spotfire Server instances.

This means that, if the total CPU usage for all instances is greater than the threshold, another instance will be scaled out. If under the threshold, it will be scaled in.

**Note**: For each multiple of the `kedaAutoscaling.threshold`, another instance will be scaled out.
With 1 replica, if the query value is at >60% cpu, another replica is created.
With 2 replicas, if the query value is at >120%, another replica is created. And so on.
See [HPA algorithm details](https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/#algorithm-details).

**Note**: You can tune `draining.minimumSeconds` and `draining.timeoutSeconds` to allow time for draining sessions when scaling in.

For more advanced scenarios, see [kedaAutoscaling.advanced](https://keda.sh/docs/latest/concepts/scaling-deployments/#advanced) and [kedaAutoscaling.fallback](https://keda.sh/docs/latest/concepts/scaling-deployments/#fallback).

### Upgrade

When installing or upgrading to a helm chart that uses a newer version of TIBCO Spotfire Server,
the spotfire database will be upgraded to the schema version required by the new server version.
The setting `database.upgrade` can be set to false to turn this off, in this case the database must be manually upgraded,
see [Run the Spotfire Server Upgrade Tool](https://docs.tibco.com/pub/spotfire_server/latest/doc/html/TIB_sfire_server_tsas_admin_help/server/topics/run_the_spotfire_server_upgrade_tool.html)

**Note** To be able to revert an upgrade and for safety reasons a backup of the database should always be performed before an upgrade.
If external library storage is used, a snapshot corresponding to the database backup should be made.

To check if the upgrade was successful check the logs for kubernetes job that performs the installation and upgrade (config-job).

## Examples

### Spotfire Database creation

#### Installation with new database

In this example we show how to deploy a Spotfire Server and a PostgreSQL database in a kubernetes cluster using helm charts.

**Note**: In this example we use a database deployed as container that, by default, creates its own PVC for storage.
Anyhow, you may use any of the supported databases as container, VM, bare metal server or as cloud database service.

Steps:

1. Add the bitnami charts repository and install a postgresql database using [Bitnami's PostgreSQL chart](https://artifacthub.io/packages/helm/bitnami/postgresql):
    ```bash
    helm repo add bitnami https://charts.bitnami.com/bitnami
    helm install my-spotfire-db-release bitnami/postgresql
    ```

2. Export postgresql autogenerated random password:
    ```bash
    export POSTGRES_PASSWORD=$(kubectl get secret --namespace default my-spotfire-db-release-postgresql -o jsonpath="{.data.postgres-password}" | base64 --decode)
    ```

3. Install Spotfire Server chart using the release name `my-release`:
    ```bash
    helm upgrade --install my-release . \
        --set global.spotfire.image.registry="127.0.0.1:32000" \
        --set global.spotfire.image.pullPolicy="Always" \
        --set database.admin.user=postgres \
        --set site.publicAddress=http://localhost/ \
        --set database.admin.password="$POSTGRES_PASSWORD" \
        --set database.admin.url="jdbc:postgresql://my-spotfire-db-release-postgresql.default.svc.cluster.local/" \
        --set database.url="jdbc:postgresql://my-spotfire-db-release-postgresql.default.svc.cluster.local/" \
        --set database.create=true
    ```

   **Note**: You need to provide your private registry address where the Spotfire containers are stored.

   **Note**: This example assumes that your spotfire container images are located in a configured registry at 127.0.0.1:32000.
   See the Kubernetes documentation for how to [Pull an Image from a Private Registry](https://kubernetes.io/docs/tasks/configure-pod-container/pull-image-private-registry/)
   or how to configure a local registry in your k8s distribution (e.g.: [microk8s built-in registry](https://microk8s.io/docs/registry-built-in)).

4. Export autogenerated Spotfire admin password:
    ```bash
    export SPOTFIREADMIN_PASSWORD=$(kubectl get secrets my-release-spotfire-server-spotfireadmin -o jsonpath="{.data.SPOTFIREADMIN_PASSWORD}" | base64 --decode)
    ```
5. Export autogenerated Spotfire database password for user spotfire:
    ```bash
    export SPOTFIREDB_PASSWORD=$(kubectl get secrets my-release-spotfire-server-database -o jsonpath="{.data.SPOTFIREDB_PASSWORD}" | base64 --decode)
    ```

6. Access the Spotfire Server web interface.

For more information on Spotfire, see [TIBCO Spotfire Server - Installation and Administration](https://docs.tibco.com/pub/spotfire_server/latest/doc/html/TIB_sfire_server_tsas_admin_help/server/topics/administration.html) documentation

For more information on PostgreSQL deployment using the chart in the example, please see [Bitnami's PostgreSQL chart](https://artifacthub.io/packages/helm/bitnami/postgresql) documentation.

#### Installation with existing database

Deploy Spotfire Server using an existing database:

```bash
helm install my-release . \
    --set database.admin.user="$DB_ADMIN" \
    --set database.admin.password="$DB_PASSWORD" \
    --set database.url="$DB_DRIVER_URL" \
    --set database.password="$SPOTFIREDB_PASSWORD"
```

**Note**: Set the proposed variables in your environment before running this command or replace them in the command with the corresponding values.

### Persistent Volumes

You can use kubernetes persistent volumes as shared storage location for the _Spotfire Library_ import and export location, custom jars, deployment packages, etc.

For more details, see on kubernetes documentation on [Volumes](https://kubernetes.io/docs/concepts/storage/volumes/)
and [Persistent Volumes](https://kubernetes.io/docs/concepts/storage/persistent-volumes/).

For more information how to use PersistentVolumes and PersistentVolumeClaims in a Pod, see [Configure a Pod to Use a PersistentVolume for Storage](https://kubernetes.io/docs/tasks/configure-pod-container/configure-persistent-volume-storage/)

#### Using persistent volumes for library import and export

When [importing to library](https://docs.tibco.com/pub/sfire-analyst/latest/doc/html/en-US/TIB_sfire-analyst_UsersGuide/index.htm#t=lib%2Flib_importing_to_library.htm&rhsearch=export&rhsyns=%20)
or [exporting from library](https://docs.tibco.com/pub/sfire-analyst/latest/doc/html/en-US/TIB_sfire-analyst_UsersGuide/index.htm#t=lib%2Flib_exporting_from_library.htm&rhsearch=export&rhsyns=%20)
you can use `volumes.libraryImportExport.persistentVolumeClaim` or `volumes.libraryImportExport.persistentVolumeClaim.customPersistentVolumeClaimName` to control which PersistentVolume or PersistentVolumeClaim to use.

**Note**: The `spotfire` user needs read and write permissions to the volume.

#### Using persistent volumes for custom jar files

To use custom jars files in the `spotfire-server` container, you can create a volume with the desired files that will be mounted on container start.

Use `volumes.customExt.persistentVolumeClaim.customPersistentVolumeClaimName` to control which PersistentVolumeClaim to use.

**Note**: The `spotfire` user needs read permissions to the volume.

For information on using additional Java library files for Spotfire Server, see:
 - [Installing database drivers for Information Designer
](https://docs.tibco.com/pub/spotfire_server/latest/doc/html/TIB_sfire_server_tsas_admin_help/server/topics/installing_database_drivers_for_information_designer.html)
 - [Authentication towards a custom JAAS module
](https://docs.tibco.com/pub/spotfire_server/latest/doc/html/TIB_sfire_server_tsas_admin_help/server/topics/authentication_towards_a_custom_jaas_module.html)
 - [Post-authentication filter](https://docs.tibco.com/pub/spotfire_server/latest/doc/html/TIB_sfire_server_tsas_admin_help/server/topics/post-authentication_filter.html)

#### Using persistent volumes for deploying SDNs/SPKs

To deploy SDNs/SPKs files in _Spotfire deployment area_, you can create a volume with the desired files that will be mounted on container start.

First you copy the desired SDNs/SPKs in a folder (e.g. `Test/`) in the volume.
Then, the helm configuration job will create a _Spotfire deployment area_ with the folder name (if it doesn't exist) and the packages will be deployed in that area.

Use `volumes.spotfireDeployments.persistentVolumeClaim.customPersistentVolumeClaimName` to control which PersistentVolumeClaim to use.

Example: The following volume file structure will create the deployment areas "Production" and "Test" and deploy the provided SDN files in these deployment areas:
```txt
Production/Spotfire.Dxp.sdn
Test/Spotfire.Dxp.sdn
Test/Spotfire.Dxp.PythonServiceLinux.sdn
```

**Note**: The Spotfire deployment area names are case insensitive and have a maximum length of 25 characters. These are the valid characters:
* [a-z]
* [0-9]
* The underline character `_`
* The dash character `-`

For more information, see [Spotfire Deployments and deployment areas](https://docs.tibco.com/pub/spotfire_server/latest/doc/html/TIB_sfire_server_tsas_admin_help/server/topics/deployments_and_deployment_areas.html)

#### Using persistent volumes for custom keystore files

If you use Self-signed or custom certificates for connecting to LDAPS (e.g.: `.jks` keystore files), you can create a volume with the desired files that will be mounted on container start.

Use `volumes.customCertsFolder.persistentVolumeClaim.customPersistentVolumeClaimName` to control which PersistentVolumeClaim to use.

**Note**: The `spotfire` user needs read permissions to the volume.

For more information on using Self-signed certificates for LDAPS with the Spotfire Server, see [Configuring LDAPS](https://docs.tibco.com/pub/spotfire_server/latest/doc/html/TIB_sfire_server_tsas_admin_help/server/topics/configuring_ldaps.html).

### Configuring the permissions, directories, files on a persistent volume

These tasks are typically handled by the kubernetes administrators. Check kubernetes documentation for best practices.

**Note**: It is possible to automate it for example by creating a pod running as the user `root` that uses the PersistentVolume or PersistentVolumeClaim to set the right permissions or pre-populates the volume with jar files or library import files.

#### Using mounts for extra files

It is possible to mount additional files to the spotfire-server container using `extraVolumeMounts` and `extraVolumes` config keys.

Example:
```yaml
extraVolumeMounts:
  - name: example
    mountPath: /opt/tibco/example.txt
    subPath: example.txt
extraVolumes:
  - name: example
    persistentVolumeClaim:
      claimName: exampleClaim
```

### Always-on Spotfire configuration CLI pod

When `cliPod.enabled` is set to `true`, an always-on Spotfire configuration CLI pod is deployed with the chart that can be used to manage and configure the Spotfire environment.

Example: Get the bash prompt into the configuration CLI pod:
```bash
$ kubectl exec -it $(kubectl get pods -l "app.kubernetes.io/component=cli, app.kubernetes.io/part-of=spotfire" -o jsonpath="{.items[0].metadata.name}" ) -- bash
my-release-cli-859fdc8cdf-d58rf $
```

For more information, see [Configuration using the command line](https://docs.tibco.com/pub/spotfire_server/latest/doc/html/TIB_sfire_server_tsas_admin_help/server/topics/configuration_using_the_command_line.html).

### Additional / custom environment variables

There are three ways to add additional environment variables to the pods, see values descriptions for `extraEnvVars`, `extraEnvVarsCM` and `extraEnvVarsSecret` below.
Reasons for doing this could be for variable consumption by custom initialization and configuration scripts or to the Spotfire Server's JVM and Tomcat options.

Example: Set JVM settings for Spotfire Server release:
```bash
helm install my-release -f my-values.yml .
```

my-values.yaml:
```yaml
extraEnvVars:
  - name: CATALINA_INITIAL_HEAPSIZE
    value: 1024m
  - name: CATALINA_MAXIMUM_HEAPSIZE
    value: 2048m
  - name: CATALINA_OPTS
    value: "-Djava.net.preferIPv4Stack=true"
```

### Running custom spotfire-config tool tasks during helm release upgrade / install

During helm release upgrade and install it is possible to run custom spotfire-config tool tasks to add custom configuration or to run custom tasks. There are two different types of config.sh scripts that can be run.

- `configuration.configurationScripts` - Scripts that modify server configuration (or configuration.xml)
- `configuration.commandScripts` - Scripts that do not modify the Spotfire configuration. Examples: creating users, assigning licenses

**Note**: If you want to deploy SDN files during helm release install or upgrade, see instead [Using persistent volumes for deploying SDNs/SPKs](#Using-persistent-volumes-for-deploying-SDNs/SPKs) instead.

Example yaml file that can be supplied to `helm upgrade` or `helm install`:
```yaml
configuration:
  configurationScripts:
    - name: my_custom_script
      script: |
        echo "This is an example custom configuration tasks. "
        set-config-prop --name=lifecycle.changes-monitoring.draining.timeout-seconds --value=180 --configuration="${CONFIGURATION_FILE}" --bootstrap-config="${BOOTSTRAP_FILE}"
    - name: my_second_script
      script: |
        echo "This script will be executed after the one above."
        echo "Scripts are executed in the order in which they appear the values file."

  commandScripts:
    - name: my_commands_script
      script: create-user --bootstrap-config=bootstrap.xml --tool-password="${TOOL_PASSWORD}" --username="my_new_user" --password="password" --ignore-existing=true
```

A few environment variables can be used in the scripts, these include but are not limited to `CONFIGURATION_FILE`, `BOOTSTRAP_FILE` and `TOOL_PASSWORD`.

For more information about config.sh run scripts see spotfire server documentation about [scripting a configuration](https://docs.tibco.com/pub/spotfire_server/latest/doc/html/TIB_sfire_server_tsas_admin_help/server/topics/scripting_a_configuration.html).

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | object | `{}` |  |
| cliPod.enabled | bool | `true` |  |
| cliPod.logLevel | string | `""` | Set to DEBUG or TRACE to increase log level. Defaults to INFO if unset. |
| configJob.logLevel | string | `""` | Set to DEBUG or TRACE to increase log level. Defaults to INFO if unset. |
| configJob.ttlSecondsAfterFinished | int | `3600` | Keep job and its logs for this long until the job is removed |
| configuration.applyKubernetesConfiguration | bool | `true` | Applies various spotfire application settings recommended for Kubernetes environments |
| configuration.commandScripts | list | `[]` | A list of commands script that will be run during helm install or upgrade. Each list item should have the keys 'name' and 'script'. See [config.sh run script](https://docs.tibco.com/pub/spotfire_server/latest/doc/html/TIB_sfire_server_tsas_admin_help/server/topics/scripting_a_configuration.html). Commands in these scripts should NOT operate on configuration.xml. Operations such as adding/removing users, assigning licenses are such typical administrative commands. |
| configuration.configurationScripts | list | `[]` | A list of configuration scripts that will be applied during helm install or upgrade. Each list item should have the keys 'name' and 'script'. See [config.sh run script](https://docs.tibco.com/pub/spotfire_server/latest/doc/html/TIB_sfire_server_tsas_admin_help/server/topics/scripting_a_configuration.html). Commands in these scripts should only operate on a local configuration.xml. configuration.xml will be automatically imported after all configuration steps have been run in the order which they are defined below. |
| configuration.useExisting | bool | `true` | Export existing Spotfire configuration before applying any additional configuration. If false, a default configuration will be created with `config.sh create-default-config`. |
| database.admin.password | string | `""` | Admin password for the database server to be used as the Spotfire Server database |
| database.admin.url | string | `""` | Like database.url but for used for the connection made when creating the spotfire database. |
| database.admin.user | string | `"postgres"` | Admin username for the database server to be used as the Spotfire Server database |
| database.create | bool | `true` | Creates a spotfire database instance if one does not already exist. Requires database.admin.url, database.admin.user, database.create.admin.password to be set. If unset, no database instance will be created during helm install. |
| database.driverClass | string | `"org.postgresql.Driver"` | The Java class name of the JDBC driver to be used, e.g. org.postgresql.Driver |
| database.name | string | `"spotfire"` | Database name to be created to hold the Spotfire Server database schemas |
| database.password | string | `""` | Password to be created for the Spotfire Server database If not provided, this password is automatically generated. |
| database.upgrade | bool | `true` |  |
| database.url | string | `"jdbc:postgresql://HOSTNAME/"` | The JDBC URL of the database to be used by Spotfire Server, e.g. jdbc:postgresql://host:port/database |
| database.user | string | `""` | Username to be created for the Spotfire Server database. If unset, default value spotfire would be used. |
| draining | object | `{"enabled":true,"minimumSeconds":30,"timeoutSeconds":60}` | Configuration of the Spotfire Server container lifecycle PreStop hook |
| draining.enabled | bool | `true` | enables or disables the container lifecycle PreStop hook |
| draining.minimumSeconds | int | `30` | The minimum time in seconds that the server should be draining even if it is considered idle |
| draining.timeoutSeconds | int | `60` | The draining timeout in seconds which after the service is forcefully shutdown |
| extraEnvVars | list | `[]` | Additional environment variables to be used by all spotfire-server pods |
| extraEnvVarsCM | string | `""` |  |
| extraEnvVarsSecret | string | `""` |  |
| extraInitContainers.configJob | list | `[]` |  |
| extraInitContainers.spotfireServerDeployment | list | `[]` |  |
| extraVolumeMounts | list | `[]` | Extra volumeMounts for the spotfire-server container. More info: `kubectl explain deployment.spec.template.spec.containers.volumeMounts` |
| extraVolumes | list | `[]` | Extra volumes for the spotfire-server container. More info: `kubectl explain deployment.spec.template.spec.volumes` |
| fluentBit.image.pullPolicy | string | `"IfNotPresent"` | image pull policy for the fluent-bit logging sidecar image. |
| fluentBit.image.repository | string | `"fluent/fluent-bit"` | image repository for fluent-bit logging sidecar. |
| fluentBit.image.tag | string | `"1.8.12"` | image tag to be used for fluent-bit logging sidecar |
| global.spotfire.image.pullPolicy | string | `"IfNotPresent"` | Global container image pull policy |
| global.spotfire.image.pullSecrets | list | `[]` | Global container image pull secrets |
| global.spotfire.image.registry | string | `nil` | Global container image registry, this will be used for tibco/spotfire container images unless overridden. |
| haproxy.config | string | The chart will create a configuration automatically | haproxy configuration file template |
| haproxy.enabled | bool | `true` |  |
| haproxy.extraVolumeMounts[0].mountPath | string | `"/tmp/chart/fix"` |  |
| haproxy.extraVolumeMounts[0].name | string | `"chart-fix"` |  |
| haproxy.extraVolumes[0].emptyDir | object | `{}` |  |
| haproxy.extraVolumes[0].name | string | `"chart-fix"` |  |
| haproxy.kind | string | `"Deployment"` |  |
| haproxy.podAnnotations | object | `{"prometheus.io/path":"/metrics","prometheus.io/port":"1024","prometheus.io/scrape":"true"}` | Prometheus annotations should match the haproxy.config settings |
| haproxy.podLabels."app.kubernetes.io/component" | string | `"haproxy"` |  |
| haproxy.podLabels."app.kubernetes.io/part-of" | string | `"spotfire"` |  |
| haproxy.podSecurityPolicy.create | bool | `false` |  |
| haproxy.service.type | string | `"ClusterIP"` | Set the service haproxy service proxies traffic to the spotfire-server service. ClusterIP or LoadBalancer. |
| haproxy.spotfireConfig | object | Caching of static resource and debug response headers enabled | Spotfire specific configuration related to haproxy |
| haproxy.spotfireConfig.agent.port | int | `9081` | Spotfire Server haproxy agent-port |
| haproxy.spotfireConfig.cache | object | enabled  | Caching of static resources |
| haproxy.spotfireConfig.cleanup.sameSiteCookieAttributeForHttp | bool | `true` | If SameSite cookie attribute should be removed for http connections in Set-Cookie response headers, might be needed in cases where both http and https is enabled and upstream servers sets this unconditionally |
| haproxy.spotfireConfig.cleanup.secureCookieAttributeForHttp | bool | `true` | If incorrect Secure cookie attribute should be removed for http connections in Set-Cookie response headers |
| haproxy.spotfireConfig.debug | bool | `true` | If debug response headers should be enabled |
| haproxy.spotfireConfig.loadBalancingCookie | object | stateless load balancing | Cookie related configuration |
| haproxy.spotfireConfig.loadBalancingCookie.attributes | string | `"prefix dynamic"` | Attributes for cookie value in the haproxy config, see https://cbonte.github.io/haproxy-dconv/2.4/configuration.html#4.2-cookie for more information |
| haproxy.spotfireConfig.loadBalancingCookie.dynamicCookieKey | string | the cookie key | dynamic-cookie-key value in the haproxy config |
| image.pullPolicy | string | `nil` | spotfire-server image pull policy, It overrides global.spotfire.image.pullPolicy |
| image.pullSecrets | list | `[]` | spotfire-server image pull secrets |
| image.registry | string | `nil` | image registry for spotfire-server, it overrides global.spotfire.image.registry value. |
| image.repository | string | `"tibco/spotfire-server"` | spotfire-server image repository |
| image.tag | string | `"11.8.1-v0.1.0"` | The container image tag to be used. |
| ingress.enabled | bool | `false` | Enables configuration of ingress to expose Spotfire Server. Requires ingress support in the k8s cluster |
| ingress.hosts[0].host | string | `"spotfire.local"` |  |
| ingress.hosts[0].paths[0].path | string | `"/"` |  |
| ingress.hosts[0].paths[0].pathType | string | `"Prefix"` |  |
| ingress.tls | list | `[]` |  |
| kedaAutoscaling | object | Disabled | KEDA autoscaling configuration, see https://keda.sh/docs/2.6/concepts/scaling-deployment for more details. |
| kedaAutoscaling.cooldownPeriod | int | `300` | The period to wait after the last trigger reported active before scaling the resource back to 0. |
| kedaAutoscaling.maxReplicas | int | `4` | This setting is passed to the HPA definition that KEDA will create for a given resource and holds the maximum number of replicas of the target resource. |
| kedaAutoscaling.minReplicas | int | `1` | Minimum number of replicas KEDA will scale the resource down to. |
| kedaAutoscaling.pollingInterval | int | `30` | This is the interval to check each trigger on. |
| kedaAutoscaling.spotfireConfig | object | `{"prometheusServerAddress":"http://prometheus-server.monitor.svc.cluster.local"}` | Spotfire specific settings |
| kedaAutoscaling.spotfireConfig.prometheusServerAddress | string | `"http://prometheus-server.monitor.svc.cluster.local"` | REQUIRED The url to the Prometheus server where metrics should be fetched from |
| livenessProbe.enabled | bool | `true` |  |
| livenessProbe.failureThreshold | int | `3` |  |
| livenessProbe.httpGet.path | string | `"/spotfire/rest/status/getStatus"` |  |
| livenessProbe.httpGet.port | string | `"http"` |  |
| livenessProbe.initialDelaySeconds | int | `30` |  |
| livenessProbe.periodSeconds | int | `3` |  |
| log-forwarder.config.filters | string | Example that drops specific events using [grep](https://docs.fluentbit.io/manual/pipeline/filters/grep) | Add custom fluent-bit [filters configuration](https://docs.fluen tbit.io/manual/pipeline/filters) |
| log-forwarder.config.inputs | string | [tcp input](https://docs.fluentbit.io/manual/pipeline/inputs/tcp) on port 5170 and [forward input](https://docs.fluentbit.io/manual/pipeline/inputs/forward) on port 24224 | fluent-bit [input configuration](https://docs.fluentbit.io/manual/pipeline/inputs) |
| log-forwarder.config.outputs | string | Logs will be written to stdout of the log-forwarder pod. | Override this values with a [output configuration](https://docs.fluentbit.io/manual/pipeline/outputs) to send logs to an external system. |
| log-forwarder.enabled | bool | `true` | enables or disables the fluent-bit log-forwarder pod. If enabled it collects logs from the spotfire-server pods and sends can forward traffic to any output supported by fluent-bit. |
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
| log-forwarder.rbac.create | bool | `false` | Whether to create and rbac for the fluent-bit / log-forwarder. Setting this to `true` will require additional privileges in the kubernetes cluster |
| log-forwarder.service.labels."app.kubernetes.io/component" | string | `"logging"` |  |
| log-forwarder.service.labels."app.kubernetes.io/part-of" | string | `"spotfire"` |  |
| logging.logForwarderAddress | string | `""` | Specify logForwarderAddress, if left empty, default log-forwarder will be used in case log-forwarder.enabled=true. Template. |
| logging.logLevel | string | `""` | Spotfire server log-level. Set to `debug`, `trace`, `minimal` or leave empty for info |
| nodeSelector | object | `{}` |  |
| podAnnotations."prometheus.io/path" | string | `"/spotfire/metrics"` |  |
| podAnnotations."prometheus.io/port" | string | `"9080"` |  |
| podAnnotations."prometheus.io/scrape" | string | `"true"` |  |
| podSecurityContext | object | `{}` |  |
| readinessProbe.enabled | bool | `false` |  |
| replicaCount | int | `1` | The number of spotfire server containers |
| resources | object | `{}` |  |
| securityContext | object | `{}` |  |
| service.type | string | `"ClusterIP"` |  |
| serviceAccount.annotations | object | `{}` |  |
| serviceAccount.create | bool | `true` |  |
| serviceAccount.name | string | `""` |  |
| site | object | Spotfire Server will join the Default site | Site settings, see https://docs.tibco.com/pub/spotfire_server/latest/doc/html/TIB_sfire_server_tsas_admin_help/server/topics/sites.html for more information. |
| site.name | string | `"Default"` | The name of the site that the spotfire server should belong to. N.B the site needs to be created beforehand, see https://docs.tibco.com/pub/spotfire_server/latest/doc/html/TIB_sfire_server_tsas_admin_help/server/topics/create-site.html for more information. |
| site.publicAddress | string | `""` | The address clients use for connecting to the system and also used for generating absolute URLs. |
| spotfireAdminPassword | string | `""` | Password to be created for the Spotfire admin. If not provided, this password is automatically generated. |
| spotfireAdminUsername | string | `"admin"` | User to be created for the Spotfire admin |
| spotfireConfig.image.pullPolicy | string | `nil` | spotfireConfig image pull policy, It overrides global.spotfire.image.pullPolicy |
| spotfireConfig.image.pullSecrets | list | `[]` |  |
| spotfireConfig.image.registry | string | `nil` | image registry for spotfireConfig, it overrides global.spotfire.image.registry value. |
| spotfireConfig.image.repository | string | `"tibco/spotfire-config"` | spotfireConfig image repository |
| spotfireConfig.image.tag | string | `"11.8.1-v0.1.0"` | The spotfireConfig container image tag to be used. |
| spotfireServerJava.extraJavaOpts | list | `[]` | Additional JAVA_OPTS for spotfire-server pods |
| startupProbe.enabled | bool | `true` |  |
| startupProbe.failureThreshold | int | `30` |  |
| startupProbe.httpGet.path | string | `"/spotfire/rest/status/getStatus"` |  |
| startupProbe.httpGet.port | string | `"http"` |  |
| startupProbe.initialDelaySeconds | int | `60` |  |
| startupProbe.periodSeconds | int | `10` |  |
| tolerations | list | `[]` |  |
| toolPassword | string | `"toolpassword"` | Spotfire config tool password to be used for bootstrap.xml. If not provided, this password is automatically generated. |
| troubleshooting.jvm.heapDumpOnOutOfMemoryError.dumpPath | string | `"/opt/tibco/troubleshooting/jvm-heap-dumps"` | Define a path where generated dump is exported. By default this gets mounted in EmptyDir: {} internally, which survives container restarts. In case user wants to persist troubleshooting information to some external location, user can override the default behaviour by specifying PVC in .Values.volumes.troubleshooting.  |
| troubleshooting.jvm.heapDumpOnOutOfMemoryError.enabled | bool | `true` | Enable or disable for heap dump in case of OutOfMemoryError  |
| volumes.customCertsFolder.customPersistentVolumeClaimName | string | `""` |  |
| volumes.customCertsFolder.mountPath | string | `"/opt/tibco/tss/tomcat/certs"` |  |
| volumes.customCertsFolder.name | string | `"custom-certificate-storage"` |  |
| volumes.customExt.customPersistentVolumeClaimName | string | `""` |  |
| volumes.customExt.mountPath | string | `"/opt/tibco/tss/tomcat/custom-ext"` |  |
| volumes.customExt.name | string | `"custom-ext"` |  |
| volumes.libraryImportExport.customPersistentVolumeClaimName | string | `""` |  |
| volumes.libraryImportExport.mountPath | string | `"/opt/tibco/tss/tomcat/application-data/library"` |  |
| volumes.libraryImportExport.name | string | `"library-import-export"` |  |
| volumes.libraryImportExport.persistentVolumeClaim.create | bool | `false` | If 'true', then a 'PersistentVolumeClaim' will be created. |
| volumes.libraryImportExport.persistentVolumeClaim.resources | object | `{"requests":{"storage":"1Gi"}}` | Specifies the standard K8s resource requests and/or limits for the libraryImportExport volume claims. |
| volumes.libraryImportExport.persistentVolumeClaim.storageClassName | string | `""` | Specify the name of the 'StorageClass' that should be used for the libraryImportExport volume-claim. |
| volumes.libraryImportExport.persistentVolumeClaim.volumeName | string | `nil` | Specify the name of the persistent volume that should be used for the libraryImportExport volume-claim. |
| volumes.spotfireDeployments.customPersistentVolumeClaimName | string | `""` |  |
| volumes.spotfireDeployments.name | string | `"spotfire-deployments"` |  |
| volumes.troubleshooting.customPersistentVolumeClaimName | string | `""` | When 'persistentVolumeClaim.create' is 'false', then this value can be used to define already existing persistent volume claim |
| volumes.troubleshooting.name | string | `"troubleshooting"` | volumes.troubleshooting name |
| volumes.troubleshooting.persistentVolumeClaim.create | bool | `false` | If 'true', then a 'PersistentVolumeClaim' will be created. |
| volumes.troubleshooting.persistentVolumeClaim.resources | object | `{"requests":{"storage":"2Gi"}}` | Specifies the standard K8s resource requests and/or limits for the volumes.troubleshooting claims. |
| volumes.troubleshooting.persistentVolumeClaim.storageClassName | string | `""` | Specify the name of the 'StorageClass' that should be used for the volumes.troubleshooting-claim. |
| volumes.troubleshooting.persistentVolumeClaim.volumeName | string | `nil` | Specify the name of the persistent volume that should be used for the volumes.troubleshooting-claim. |

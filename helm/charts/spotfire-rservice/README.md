# spotfire-rservice

![Version: 5.0.1](https://img.shields.io/badge/Version-5.0.1-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 15.0.0](https://img.shields.io/badge/AppVersion-15.0.0-informational?style=flat-square)

A Helm chart for Spotfire® Service for R

**Homepage:** <https://github.com/spotfiresoftware/spotfire-cloud-deployment-kit>

## Source Code

* <https://github.com/spotfiresoftware/spotfire-cloud-deployment-kit>

## Requirements

Kubernetes: `>=1.24.0-0`

| Repository | Name | Version |
|------------|------|---------|
| file://../spotfire-common | spotfire-common | 5.0.1 |

## Overview

This chart deploys the [Spotfire® Service for R](https://docs.tibco.com/pub/sf-rsrv/latest/doc/html/TIB_sf-rsrv_install/rinstall/topics/the_tibco_spotfire_service_for_r.html) service on a [Kubernetes](http://kubernetes.io/) cluster using the [Helm](https://helm.sh/) package manager.

The R service pod includes:
- A [Fluent Bit](https://fluentbit.io/) sidecar container for log forwarding.
- Service annotations for [Prometheus](https://prometheus.io/) scrapers. The Prometheus server discovers the service endpoint using these specifications and scrapes metrics from the exporter.
- Predefined configuration for horizontal pod autoscaling with [KEDA](https://keda.sh/docs) and Prometheus.

This chart is tested to work with [Elasticsearch](https://www.elastic.co/elasticsearch/), [Prometheus](https://prometheus.io/) and [KEDA](https://keda.sh/).

## Prerequisites

- A deployed Spotfire Server release using the [Spotfire Server](https://github.com/spotfiresoftware/spotfire-cloud-deployment-kit/blob/main/helm/charts/spotfire-server/README.md) chart.

## Usage

Replace all placeholders (shown in angle brackets like `<NAMESPACE>`) with your actual values before running the commands.

### Step 1: Create namespace

```bash
kubectl create namespace "<NAMESPACE>"
```

### Step 2: Prepare Spotfire Server service addresses

The R service needs the Spotfire Server backend service name, and optionally the log-forwarder service name if you want application logs sent to the Spotfire log-forwarder.

If the Spotfire Server chart was installed in the same namespace with the release name `<SPOTFIRE_SERVER_RELEASE>`, typical values are:

- `nodemanagerConfig.serverBackendAddress="<SPOTFIRE_SERVER_RELEASE>-spotfire-server"`
- `logging.logForwarderAddress="<SPOTFIRE_SERVER_RELEASE>-log-forwarder"` when the Spotfire Server chart log-forwarder is enabled

### Step 3: Deploy the Spotfire Service for R chart

Create a `values.yaml` file (for example, `spotfire-rservice-values.yaml`). See the [Values table](#values) for details of the values.

```yaml
# spotfire-rservice-values.yaml
acceptEUA: true

global:
  spotfire:
    image:
      registry: "<REGISTRY>"
      pullPolicy: Always

nodemanagerConfig:
  serverBackendAddress: "<SPOTFIRE_SERVER_SERVICE>"

logging:
  logForwarderAddress: "<LOG_FORWARDER_SERVICE>"
```

Install the chart:

```bash
helm install "<SPOTFIRE_RSERVICE_RELEASE>" . \
  --namespace="<NAMESPACE>" \
  --create-namespace \
  --values spotfire-rservice-values.yaml
```

**Note**:
- Setting `acceptEUA: true` means you agree that your use of the Spotfire software is governed by the terms of the [Cloud Software Group, Inc. End User Agreement](https://www.cloud.com/legal/terms).
- Replace `<REGISTRY>` with your private registry address where the Spotfire container images are stored.
- Replace `<SPOTFIRE_SERVER_SERVICE>` with the Spotfire Server service name that the R service should connect to.
- Replace `<LOG_FORWARDER_SERVICE>` with the log-forwarder service name if you want to forward logs to the Spotfire log-forwarder. If you do not want to use a log-forwarder service, omit `logging.logForwarderAddress`.

Check pod status:

```bash
kubectl get pods --namespace "<NAMESPACE>" \
  -l "app.kubernetes.io/name=spotfire-rservice,app.kubernetes.io/instance=<SPOTFIRE_RSERVICE_RELEASE>"
```

## Configuration

### Custom configuration properties

To set [Custom configuration properties](https://docs.tibco.com/pub/sf-rsrv/latest/doc/html/TIB_sf-rsrv_install/_shared/install/topics/custom_configuration_properties.html), add the property names as keys under the `configuration` section in your values file.

Example:

```yaml
configuration:
  # The maximum number of R engine sessions that are allowed to run concurrently in the R service.
  engine.session.max: "5"

  # The number of R engines preallocated and available for new sessions in the R service queue.
  engine.queue.size: "10"
```

## Scaling

To change the number of replicas managed by Helm, update `replicaCount` in your values file and run `helm upgrade`.

Example:

```yaml
replicaCount: 3
```

```bash
helm upgrade "<SPOTFIRE_RSERVICE_RELEASE>" . \
  --namespace="<NAMESPACE>" \
  --values spotfire-rservice-values.yaml
```

### Autoscaling with KEDA

To use [KEDA](https://keda.sh/docs) for autoscaling, first install KEDA in the Kubernetes cluster. You must also install a Prometheus instance that scrapes metrics from the Spotfire pods.

Example: A `values.yaml` snippet configuration for enabling autoscaling with KEDA:
```yaml
resources:
  limits:
    cpu: 5
kedaAutoscaling:
  enabled: true
  spotfireConfig:
    prometheusServerAddress: http://prometheus-server.monitor.svc.cluster.local
  threshold: 3
  minReplicas: 1
  maxReplicas: 3
```

The `spotfire-rservice` has the following autoscaling defaults:
- metric: `spotfire_service_queue_engines_inUse` (_serviceQueueEnginesInUse_ R service counter).
- query: the sum of `spotfire_service_queue_engines_inUse` of the R service instances for the release name.

The counter _serviceQueueEnginesInUse_ provides the total number of engines currently executing.
By default, the R service has `number of cores - 1` available slots, which means that `kedaAutoscaling.threshold` should be synchronized with `resources.limits.cpu`.
Typically, you want to scale out before all the available capacity is taken.
Therefore, the `kedaAutoscaling.threshold` should be lower than `resources.limits.cpu`.
Note that clients requesting a slot typically wait until a slot is available.

For more information, see [Monitoring Spotfire Service for R using JMX](https://docs.tibco.com/pub/sf-rsrv/latest/doc/html/TIB_sf-rsrv_install/_shared/install/topics/monitoring_the_service_using_jmx.html).

**Note**: You can tune `nodemanagerConfig.preStopDrainingTimeoutSeconds` and other timeouts (for example, `engine.execution.timeout` and `engine.session.maxtime`) so that long-running jobs are not aborted prematurely when an instance is stopped to scale in.
See [Engine Timeout](https://docs.tibco.com/pub/sf-rsrv/latest/doc/html/TIB_sf-rsrv_install/_shared/install/topics/engine_timeout.html) for more details.

For more advanced scenarios, see [kedaAutoscaling.advanced](https://keda.sh/docs/latest/concepts/scaling-deployments/#advanced) and [kedaAutoscaling.fallback](https://keda.sh/docs/latest/concepts/scaling-deployments/#fallback).

Additionally, you can define your own [custom scaling triggers](https://keda.sh/docs/latest/concepts/scaling-deployments/#triggers). Helm template functionality is available:
```yaml
kedaAutoscaling:
  triggers: {} # list of triggers to activate scaling of the target resource
```

**Note**: For more details on the autoscaling defaults, see `templates/keda-autoscaling.yaml` in the chart.

#### Update the Pod Deletion Cost annotation automatically

The [controller.kubernetes.io/pod-deletion-cost](https://kubernetes.io/docs/concepts/workloads/controllers/replicaset/#pod-deletion-cost) pod annotation influences in which order Kubernetes selects the pod to delete, for example, during scale-in.

Note that pod annotations should not be updated 'too' often (minutes rather than seconds), depending on the size of the cluster. The reason for this is that the Kubernetes API server is highly optimized for reads. `sleepIntervalSeconds` controls how often the updater should run, `thresholdPercent` and `minAbsDelta` controls how large the change must be for the annotation to be updated, that is, it specifies the size of a meaningful change.

```yaml
podDeletionCost:
  enabled: true
```

The `spotfire-rservice` has the following defaults:
- cost formula: `spotfire_service_queue_engines_inUse`.
- sleepIntervalSeconds: `120`.
- `thresholdPercent`: `10`
- `minAbsDelta`: `1`

## Performance and Storage

### Improved performance and concurrency for temporary folder

To optimize data reuse, the R service uses its temporary folder (default: `/tmp`) to store temporary files and intermediate data. In scenarios where large data sets or concurrent computations are involved, the default temporary folder might become a bottleneck, impacting performance and throughput. It is recommended to use a more performant and larger Kubernetes volume.

Example: A `values.yaml` snippet for optimizing the R service temp disk performance.
```yaml
extraVolumeMounts:
  - mountPath: /tmp
    name: rservice-temp-dir-volume
extraVolumes:
  - name: rservice-temp-dir-volume
    ephemeral: # See Kubernetes documentation for ephemeral volumes: https://kubernetes.io/docs/concepts/storage/ephemeral-volumes/
      volumeClaimTemplate:
        metadata:
          labels:
            type: rservice-ephemeral-volume
        spec:
          accessModes: ["ReadWriteOnce"]
          storageClassName: <STORAGE_CLASS_NAME> # Replace with your storage class name.
          resources:
            requests:
              storage: 10Gi # Specify the desired storage size.
```

**Note**: For Azure AKS clusters, see also: [Use Azure Container Storage with local NVMe](https://learn.microsoft.com/en-us/azure/storage/container-storage/use-container-storage-with-local-disk).

## Uninstalling

To uninstall the `<SPOTFIRE_RSERVICE_RELEASE>` release:

```bash
helm --namespace "<NAMESPACE>" uninstall "<SPOTFIRE_RSERVICE_RELEASE>"
```

## Upgrading

See [helm upgrade](https://helm.sh/docs/helm/helm_upgrade/) for command documentation.

### Upgrading Spotfire Server and Spotfire services

When you upgrade to a newer Spotfire Server version and newer Spotfire services versions, upgrade the Spotfire Server first, and then upgrade the Spotfire services.

### Upgrading helm chart version

Please review the [release notes](https://github.com/spotfiresoftware/spotfire-cloud-deployment-kit/releases) for any changed, moved, or renamed parameters before upgrading the release.

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| global.spotfire.acceptEUA | bool | `nil` | Accept the [Cloud Software Group, Inc. End User Agreement](https://www.cloud.com/legal/terms) by setting the value to `true`. |
| global.spotfire.image.pullPolicy | string | `"IfNotPresent"` | The global container image pull policy. |
| global.spotfire.image.pullSecrets | list | `[]` | The global container image pull secrets. |
| global.spotfire.image.registry | string | `nil` | The global container image registry. Used for spotfire/ container images, unless it is overridden. |
| acceptEUA | bool | `nil` | Accept the [Cloud Software Group, Inc. End User Agreement](https://www.cloud.com/legal/terms) by setting the value to `true`. |
| affinity | object | `{}` |  |
| configuration | object | `{}` | Add [Custom configuration properties](https://docs.tibco.com/pub/sf-rsrv/latest/doc/html/TIB_sf-rsrv_install/_shared/install/topics/custom_configuration_properties.html). Keys under configuration should be named the same as the configuration property, for example 'engine.execution.timeout'. |
| extraContainers | list | `[]` | Additional sidecar containers to add to the service pod. |
| extraEnvVars | list | `[]` | Additional environment variables. |
| extraEnvVarsCM | string | `""` | The name of the ConfigMap containing additional environment variables. |
| extraEnvVarsSecret | string | `""` | The name of the Secret containing extra additional environment variables. |
| extraInitContainers | list | `[]` | Additional init containers to add to the service pod. |
| extraVolumeMounts | list | `[]` | Extra volumeMounts for the service container. More info: `kubectl explain deployment.spec.template.spec.containers.volumeMounts`. |
| extraVolumes | list | `[]` | Extra volumes for the service container. More info: `kubectl explain deployment.spec.template.spec.volumes`. |
| fluentBitSidecar.image.pullPolicy | string | `"IfNotPresent"` | The image pull policy for the fluent-bit logging sidecar image. |
| fluentBitSidecar.image.repository | string | `"fluent/fluent-bit"` | The image repository for fluent-bit logging sidecar. |
| fluentBitSidecar.image.tag | string | `"4.2.3"` | The image tag to use for fluent-bit logging sidecar. |
| fluentBitSidecar.resources | object | `{}` | The resources setting for fluent-bit sidecar container. |
| fluentBitSidecar.securityContext | object | `{}` | The securityContext setting for fluent-bit sidecar container. Overrides any securityContext setting on the Pod level. |
| fullnameOverride | string | `""` |  |
| image.pullPolicy | string | `nil` | The spotfire-server image pull policy. Overrides global.spotfire.image.pullPolicy. |
| image.pullSecrets | list | `[]` | Image pull secrets. |
| image.registry | string | `nil` | The image registry for spotfire-server. Overrides the global.spotfire.image.registry value. |
| image.repository | string | `"spotfire/spotfire-rservice"` | The spotfire-server image repository. |
| image.tag | string | `"15.0.0-v7.0.1"` | The container image tag to use. |
| kedaAutoscaling | object | `{"advanced":{},"cooldownPeriod":300,"enabled":false,"fallback":{},"maxReplicas":4,"minReplicas":1,"pollingInterval":30,"spotfireConfig":{"prometheusServerAddress":"http://prometheus-server.monitor.svc.cluster.local"},"threshold":null,"triggers":[]}` | KEDA autoscaling configuration. See https://keda.sh/docs/latest/concepts/scaling-deployments/ for more details. |
| kedaAutoscaling.cooldownPeriod | int | `300` | The period to wait after the last trigger reported active before scaling the resource back to 0. |
| kedaAutoscaling.maxReplicas | int | `4` | This setting is passed to the HPA definition that KEDA creates for a given resource and holds the maximum number of replicas of the target resource. |
| kedaAutoscaling.minReplicas | int | `1` | The minimum number of replicas KEDA scales the resource down to. |
| kedaAutoscaling.pollingInterval | int | `30` | The interval to check each trigger on. |
| kedaAutoscaling.spotfireConfig | object | `{"prometheusServerAddress":"http://prometheus-server.monitor.svc.cluster.local"}` | Spotfire specific settings. |
| kedaAutoscaling.spotfireConfig.prometheusServerAddress | string | `"http://prometheus-server.monitor.svc.cluster.local"` | REQUIRED. The URL for the Prometheus server from where metrics are fetched. |
| livenessProbe.enabled | bool | `true` |  |
| livenessProbe.failureThreshold | int | `10` |  |
| livenessProbe.httpGet.path | string | `"/spotfire/liveness"` |  |
| livenessProbe.httpGet.port | string | `"registration"` |  |
| livenessProbe.initialDelaySeconds | int | `60` |  |
| livenessProbe.periodSeconds | int | `3` |  |
| logging.logForwarderAddress | string | `""` | The spotfire-server log-forwarder name. Template. |
| logging.logLevel | string | `"debug"` | Set to `debug`, `trace`, `minimal`, or leave empty for info. This applies for both node manager and the service. |
| nameOverride | string | `""` |  |
| nodeSelector | object | `{}` |  |
| nodemanagerConfig.preStopDrainingTimeoutSeconds | int | `610` | The draining timeout after which the service is forcefully shut down. |
| nodemanagerConfig.serverBackendAddress | string | `""` | The spotfire-server service name. This value is evaluated as a helm template. |
| podAnnotations."prometheus.io/path" | string | `"/spotfire/metrics"` |  |
| podAnnotations."prometheus.io/port" | string | `"9080"` |  |
| podAnnotations."prometheus.io/scrape" | string | `"true"` |  |
| podDeletionCost | object | Default values for Pod Deletion Cost, see values.yaml. | Pod Deletion Cost update configuration. See https://kubernetes.io/docs/concepts/workloads/controllers/replicaset/#pod-deletion-cost for more details. |
| podDeletionCost.costFormula | string | `"spotfire_service_queue_engines_inUse"` | An awk formula using the Prometheus metric names to calculate deletion cost. Missing or not found metrics default to 0. |
| podDeletionCost.enabled | bool | `false` | Enable updating of pod deletion cost annotation. |
| podDeletionCost.image.pullPolicy | string | `"IfNotPresent"` | Image pull policy for the podDeletionCost. |
| podDeletionCost.image.pullSecrets | list | `[]` | Image pull secrets for the podDeletionCost. |
| podDeletionCost.image.registry | string | `nil` | Image registry for the podDeletionCost. |
| podDeletionCost.image.repository | string | `"spotfire/spotfire-config"` | Image repository for the podDeletionCost. |
| podDeletionCost.image.tag | string | `"15.0.0-v7.0.1"` | Image tag for the podDeletionCost. |
| podDeletionCost.minAbsDelta | string | `"1"` | Minimum numeric change to trigger a patch. |
| podDeletionCost.replicaCount | int | `1` | Number of replicas. |
| podDeletionCost.resources | object | `{}` | Specifies the standard Kubernetes resource requests and/or limits |
| podDeletionCost.sleepIntervalSeconds | string | `"120"` | How long to wait between checks (seconds). |
| podDeletionCost.thresholdPercent | string | `"10"` | Minimum % change to trigger a patch. |
| podSecurityContext | object | `{}` | The Pod securityContext setting applies to all of the containers inside the Pod. |
| readinessProbe.enabled | bool | `false` |  |
| readinessProbe.failureThreshold | int | `10` |  |
| readinessProbe.httpGet.path | string | `"/spotfire/readiness"` |  |
| readinessProbe.httpGet.port | string | `"registration"` |  |
| readinessProbe.initialDelaySeconds | int | `60` |  |
| readinessProbe.periodSeconds | int | `3` |  |
| replicaCount | int | `1` |  |
| resources | object | `{}` |  |
| securityContext | object | `{}` | The securityContext setting for the service container. Overrides any securityContext setting on the Pod level. |
| service.port | int | `9501` |  |
| service.type | string | `"ClusterIP"` |  |
| serviceAccount.annotations | object | `{}` |  |
| serviceAccount.create | bool | `false` |  |
| serviceAccount.name | string | `""` |  |
| startupProbe.enabled | bool | `true` |  |
| startupProbe.failureThreshold | int | `20` |  |
| startupProbe.httpGet.path | string | `"/spotfire/started"` |  |
| startupProbe.httpGet.port | string | `"registration"` |  |
| startupProbe.initialDelaySeconds | int | `60` |  |
| startupProbe.periodSeconds | int | `3` |  |
| tolerations | list | `[]` |  |
| topologySpreadConstraints | list | `[]` |  |
| volumes.certificates.existingClaim | string | `""` | Defines an already-existing persistent volume claim. |
| volumes.certificates.subPath | string | `""` | The subPath of the volume to be used for the volume mount |
| volumes.packages.existingClaim | string | `""` | If 'persistentVolumeClaim.create' is 'false' (the default), then use this value to define an already existing persistent volume claim. |
| volumes.packages.persistentVolumeClaim.create | bool | `false` | If 'true', then a 'PersistentVolumeClaim' is created. |
| volumes.packages.persistentVolumeClaim.resources | object | `{"requests":{"storage":"1Gi"}}` | Specifies the standard Kubernetes resource requests and/or limits for the customExt volume claims. |
| volumes.packages.persistentVolumeClaim.storageClassName | string | `""` | Specifies the name of the 'StorageClass' to use for the customExt volume-claim. |
| volumes.packages.persistentVolumeClaim.volumeName | string | `nil` | Specifies the name of the persistent volume to use for the customExt volume-claim. |
| volumes.packages.subPath | string | `""` | The subPath of the volume to use for the volume mount. |
| volumes.troubleshooting.existingClaim | string | `""` | If 'persistentVolumeClaim.create' is 'false' (the default), then use this value to define an already existing persistent volume claim. |
| volumes.troubleshooting.persistentVolumeClaim.create | bool | `false` | If 'true', then a 'PersistentVolumeClaim' is created. |
| volumes.troubleshooting.persistentVolumeClaim.resources | object | `{"requests":{"storage":"2Gi"}}` | Specifies the standard Kubernetes resource requests and/or limits for the volumes.troubleshooting claims. |
| volumes.troubleshooting.persistentVolumeClaim.storageClassName | string | `""` | Specifies the name of the 'StorageClass' to use for the volumes.troubleshooting-claim. |
| volumes.troubleshooting.persistentVolumeClaim.volumeName | string | `nil` | Specifies the name of the persistent volume to use for the volumes.troubleshooting-claim. |

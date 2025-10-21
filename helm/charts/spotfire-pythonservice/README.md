# spotfire-pythonservice

![Version: 2.0.0](https://img.shields.io/badge/Version-2.0.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 1.23.0](https://img.shields.io/badge/AppVersion-1.23.0-informational?style=flat-square)

A Helm chart for Spotfire® Service for Python

**Homepage:** <https://github.com/spotfiresoftware/spotfire-cloud-deployment-kit>

## Source Code

* <https://github.com/spotfiresoftware/spotfire-cloud-deployment-kit>

## Requirements

Kubernetes: `>=1.24.0-0`

| Repository | Name | Version |
|------------|------|---------|
| file://../spotfire-common | spotfire-common | 2.0.0 |

## Overview

This chart deploys the [Spotfire® Service for Python](https://docs.tibco.com/pub/sf-pysrv/latest/doc/html/TIB_sf-pysrv_install/pyinstall/topics/the_tibco_spotfire_service_for_python.html) service (Python service) on a [Kubernetes](http://kubernetes.io/) cluster using the [Helm](https://helm.sh/) package manager.

The Python service pod includes:
- A [Fluent Bit](https://fluentbit.io/) sidecar container for log forwarding.
- Service annotations for [Prometheus](https://prometheus.io/) scrapers. The Prometheus server discovers the service endpoint using these specifications and scrapes metrics from the exporter.
- Predefined configuration for horizontal pod autoscaling with [KEDA](https://keda.sh/docs) and Prometheus.

This chart is tested to work with [Elasticsearch](https://www.elastic.co/elasticsearch/), [Prometheus](https://prometheus.io/), and [KEDA](https://keda.sh/).

## Prerequisites

- A deployed Spotfire Server release using the [Spotfire Server](../spotfire-server/README.md) chart.

## Usage

### Installing

1. Export the `SPOTFIRE_SERVER` value to connect to the `spotfire-server` service:
    ```bash
    export SPOTFIRE_SERVER=$(kubectl get services --selector=app.kubernetes.io/part-of=spotfire,app.kubernetes.io/name=spotfire-server --output=jsonpath={.items..metadata.name})
    ```
2.  Forward the logs to the `log-forwarder` service:
    ```bash
    export LOG_FORWARDER=$(kubectl get services --selector=app.kubernetes.io/part-of=spotfire,app.kubernetes.io/name=log-forwarder --output=jsonpath={.items..metadata.name})
    ```
3. Install this chart with the release name `my-release` and custom values from `my-values.yaml`:
    ```bash
    helm install my-release . \
        --set acceptEUA=true \
        --set global.spotfire.image.registry="127.0.0.1:32000" \
        --set global.spotfire.image.pullPolicy="Always" \
        --set nodemanagerConfig.serverBackendAddress="$SPOTFIRE_SERVER" \
        --set logging.logForwarderAddress="$LOG_FORWARDER" \
        -f my-values.yaml
    ```

**Note**: This Spotfire Helm chart requires setting the parameter `acceptEUA` or the parameter `global.spotfire.acceptEUA` to the value `true`.
By doing so, you agree that your use of the Spotfire software running in the managed containers will be governed by the terms of the [Cloud Software Group, Inc. End User Agreement](https://www.cloud.com/legal/terms).

**Note**: You must provide your private registry address where the Spotfire container images are stored.

See [helm install](https://helm.sh/docs/helm/helm_install/) for command documentation.

### How to add additional Python packages

Configure `volumes.packages` to mount a persistent volume, which can contain additional Python packages for the Python service to use. See the **Values** section for more information on mounting the volume for the packages.

#### How to install packages using pip to a target folder

You can populate a packages folder by following the instructions in [Installing Python Packages Manually](https://docs.tibco.com/pub/sf-pysrv/latest/doc/html/TIB_sf-pysrv_install/pyinstall/topics/installing_python_packages_manually.html). Here is an example of how to create a packages folder from a requirements.txt file:

```bash
python -m pip install --target=/local/path/to/packages -r requirements.txt
```

**Note:** For spotfire-pythonservice to use the packages, the packages must be copied to a PersistentVolume that you create and then provide to the helm chart during installation.

#### Configuration

To set [Custom configuration properties](https://docs.tibco.com/pub/sf-pysrv/latest/doc/html/TIB_sf-pysrv_install/_shared/install/topics/custom_configuration_properties.html), add the name of the property as a key under the `configuration` section in your Helm values.

Example:
```ini
# The maximum number of Python engine sessions that are allowed to run concurrently in the Python service.
engine.session.max: 5

# The number of Python engines preallocated and available for new sessions in the Python service queue.
engine.queue.size: 10
```

### Uninstalling

To uninstall/delete the `my-release` deployment:
```bash
helm uninstall my-release
```

See [helm uninstall](https://helm.sh/docs/helm/helm_uninstall/) for command documentation.

### Scaling

For scaling the `my-release` deployment, do a helm upgrade, providing the target number of pod instances in the `replicaCount` variable.
```bash
helm upgrade --install my-release . --reuse-values --set replicaCount=3
```

#### Autoscaling with KEDA

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

The `spotfire-pythonservice` has the following autoscaling defaults:
- metric: `spotfire_service_queue_engines_inUse` (_serviceQueueEnginesInUse_ Python service counter).
- query: the sum of `spotfire_service_queue_engines_inUse` of the Python service instances for the release name.

The counter _serviceQueueEnginesInUse_ provides the total number of engines currently executing.
By default, the Python service has `number of cores - 1` available slots, which means that `kedaAutoscaling.threshold` should be synchronized with `resources.limits.cpu`.
Typically, you want to scale out before all the available capacity is taken.
Therefore, the `kedaAutoscaling.threshold` should be lower than `resources.limits.cpu`.
Note that clients requesting a slot typically wait until a slot is available.

For more information, see [Monitoring Spotfire Service for Python using JMX](https://docs.tibco.com/pub/sf-pysrv/latest/doc/html/TIB_sf-pysrv_install/_shared/install/topics/monitoring_the_service_using_jmx.html).

**Note**: You can tune `nodemanagerConfig.preStopDrainingTimeoutSeconds` and other timeouts (for example, `engine.execution.timeout` and `engine.session.maxtime`) so that long-running jobs are not aborted prematurely when an instance is stopped to scale in.
See [Engine Timeout](https://docs.tibco.com/pub/sf-pysrv/latest/doc/html/TIB_sf-pysrv_install/_shared/install/topics/engine_timeout.html) for more details.

For more advanced scenarios, see [kedaAutoscaling.advanced](https://keda.sh/docs/latest/concepts/scaling-deployments/#advanced) and [kedaAutoscaling.fallback](https://keda.sh/docs/latest/concepts/scaling-deployments/#fallback).

Additionally, you can define your own [custom scaling triggers](https://keda.sh/docs/latest/concepts/scaling-deployments/#triggers). Helm template functionality is available:
```yaml
kedaAutoscaling:
  triggers: {} # list of triggers to activate scaling of the target resource
```

**Note**: For more details on the autoscaling defaults, refer to the file templates/keda-autoscaling.yaml inside the chart.

#### Improved performance and concurrency for temporary folder

To store intermediate results during analysis and optimize data reuse, the Spotfire Service for Python uses its temporary folder (default: `/tmp`). In scenarios where large data sets or concurrent computations are involved, the default temporary folder might become a bottleneck, impacting performance and throughput. To address this, it is recommended to use a more performant and larger Kubernetes volume for the temporary folder. For more details, see [Improved performance and concurrency for temporary folder](../spotfire-server/README.md#improved-performance-and-concurrency-for-temporary-folder) in the Spotfire Server documentation.

### Upgrading

When you upgrade to a newer Spotfire Server version and newer Spotfire services versions, upgrade the Spotfire Server first, and then upgrade the Spotfire services. See [helm upgrade](https://helm.sh/docs/helm/helm_upgrade/) for helm command documentation.

#### Upgrading helm chart version

Please review the [release notes](https://github.com/spotfiresoftware/spotfire-cloud-deployment-kit/releases) for any changes, moved, or renamed parameters before upgrading the release.

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| global.spotfire.acceptEUA | bool | `nil` | Accept the [Cloud Software Group, Inc. End User Agreement](https://www.cloud.com/legal/terms) by setting the value to `true`. |
| global.spotfire.image.pullPolicy | string | `"IfNotPresent"` | The global container image pull policy. |
| global.spotfire.image.pullSecrets | list | `[]` | The global container image pull secrets. |
| global.spotfire.image.registry | string | `nil` | The global container image registry. Used for spotfire/ container images, unless it is overridden. |
| acceptEUA | bool | `nil` | Accept the [Cloud Software Group, Inc. End User Agreement](https://www.cloud.com/legal/terms) by setting the value to `true`. |
| affinity | object | `{}` |  |
| configuration | object | `{}` | Add [Custom configuration properties](https://docs.tibco.com/pub/sf-pysrv/latest/doc/html/TIB_sf-pysrv_install/_shared/install/topics/custom_configuration_properties.html). Keys under configuration should be named the same as the configuration property, for example 'engine.execution.timeout'. |
| extraContainers | list | `[]` | Additional sidecar containers to add to the service pod. |
| extraEnvVars | list | `[]` | Additional environment variables. |
| extraEnvVarsCM | string | `""` | The name of the ConfigMap containing additional environment variables. |
| extraEnvVarsSecret | string | `""` | The name of the Secret containing extra additional environment variables. |
| extraInitContainers | list | `[]` | Additional init containers to add to the service pod. |
| extraVolumeMounts | list | `[]` | Extra volumeMounts for the service container. More info: `kubectl explain deployment.spec.template.spec.containers.volumeMounts`. |
| extraVolumes | list | `[]` | Extra volumes for the service container. More info: `kubectl explain deployment.spec.template.spec.volumes`. |
| fluentBitSidecar.image.pullPolicy | string | `"IfNotPresent"` | The image pull policy for the fluent-bit logging sidecar image. |
| fluentBitSidecar.image.repository | string | `"fluent/fluent-bit"` | The image repository for fluent-bit logging sidecar. |
| fluentBitSidecar.image.tag | string | `"4.0.7"` | The image tag to use for fluent-bit logging sidecar. |
| fluentBitSidecar.resources | object | `{}` | The resources setting for fluent-bit sidecar container. |
| fluentBitSidecar.securityContext | object | `{}` | The securityContext setting for fluent-bit sidecar container. Overrides any securityContext setting on the Pod level. |
| fullnameOverride | string | `""` |  |
| image.pullPolicy | string | `nil` | The spotfire-server image pull policy. Overrides global.spotfire.image.pullPolicy. |
| image.pullSecrets | list | `[]` | Image pull secrets. |
| image.registry | string | `nil` | The image registry for spotfire-server. Overrides global.spotfire.image.registry value. |
| image.repository | string | `"spotfire/spotfire-pythonservice"` | The spotfire-server image repository. |
| image.tag | string | `"1.23.0-v4.0.0"` | The container image tag to use. |
| kedaAutoscaling | object | `{"advanced":{},"cooldownPeriod":300,"enabled":false,"fallback":{},"maxReplicas":4,"minReplicas":1,"pollingInterval":30,"spotfireConfig":{"prometheusServerAddress":"http://prometheus-server.monitor.svc.cluster.local"},"threshold":null,"triggers":[]}` | KEDA autoscaling configuration. See https://keda.sh/docs/latest/concepts/scaling-deployments for more details. |
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
| volumes.certificates.existingClaim | string | `""` | Defines an already-existing persistent volume claim. |
| volumes.certificates.subPath | string | `""` | The subPath of the volume to be used for the volume mount |
| volumes.packages.existingClaim | string | `""` | When 'persistentVolumeClaim.create' is 'false', then use this value to define an already existing persistent volume claim. |
| volumes.packages.persistentVolumeClaim.create | bool | `false` | If 'true', then a 'PersistentVolumeClaim' is created. |
| volumes.packages.persistentVolumeClaim.resources | object | `{"requests":{"storage":"1Gi"}}` | Specifies the standard Kubernetes resource requests and/or limits for the customExt volume claims. |
| volumes.packages.persistentVolumeClaim.storageClassName | string | `""` | Specifies the name of the 'StorageClass' to use for the customExt volume-claim. |
| volumes.packages.persistentVolumeClaim.volumeName | string | `nil` | Specifies the name of the persistent volume that should be used for the customExt volume-claim. |
| volumes.packages.subPath | string | `""` | The subPath of the volume to be used for the volume mount |
| volumes.troubleshooting.existingClaim | string | `""` | When 'persistentVolumeClaim.create' is 'false', then use this value to define an already existing persistent volume claim. |
| volumes.troubleshooting.persistentVolumeClaim.create | bool | `false` | If 'true', then a 'PersistentVolumeClaim' will be created. |
| volumes.troubleshooting.persistentVolumeClaim.resources | object | `{"requests":{"storage":"2Gi"}}` | Specifies the standard Kubernetes resource requests and/or limits for the volumes.troubleshooting claims. |
| volumes.troubleshooting.persistentVolumeClaim.storageClassName | string | `""` | Specifies the name of the 'StorageClass' to use for the volumes.troubleshooting-claim. |
| volumes.troubleshooting.persistentVolumeClaim.volumeName | string | `nil` | Specifies the name of the persistent volume to use for the volumes.troubleshooting-claim. |

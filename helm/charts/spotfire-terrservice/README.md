# spotfire-terrservice

![Version: 0.1.4](https://img.shields.io/badge/Version-0.1.4-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 1.14.0](https://img.shields.io/badge/AppVersion-1.14.0-informational?style=flat-square)

A Helm chart for TIBCO® Enterprise Runtime for R - Server Edition

**Homepage:** <https://github.com/TIBCO/Spotfire-cloud-deployment-kit>

## Source Code

* <https://github.com/TIBCO/Spotfire-cloud-deployment-kit>

## Requirements

Kubernetes: `>=1.23.0-0`

| Repository | Name | Version |
|------------|------|---------|
| file://../spotfire-common | spotfire-common | 0.1.4 |

## Overview

This chart deploys the [TIBCO® Enterprise Runtime for R - Server Edition](https://docs.tibco.com/pub/terrsrv/latest/doc/html/TIB_terrsrv_install/terrinstall-homepage.html) service on a [Kubernetes](http://kubernetes.io/) cluster using the [Helm](https://helm.sh/) package manager.

The TERR service pod includes:
- A [Fluent Bit](https://fluentbit.io/) sidecar container for log forwarding.
- Service annotations for [Prometheus](https://prometheus.io/) scrapers. The Prometheus server discovers the service endpoint using these specifications and scrapes metrics from the exporter.
- Predefined configuration for horizontal pod autoscaling with [KEDA](https://keda.sh/docs) and Prometheus.

This chart is tested to work with [Elasticsearch](https://www.elastic.co/elasticsearch/), [Prometheus](https://prometheus.io/) and [KEDA](https://keda.sh/).

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
        --set global.spotfire.image.registry="127.0.0.1:32000" \
        --set global.spotfire.image.pullPolicy="Always" \
        --set nodemanagerConfig.serverBackendAddress="$SPOTFIRE_SERVER" \
        --set logging.logForwarderAddress="$LOG_FORWARDER" \
        -f my-values.yaml
    ```

**Note**: You must provide your private registry address where the Spotfire containers are stored.

See [helm install](https://helm.sh/docs/helm/helm_install/) for command documentation.

#### Configuration

You can override the default configuration settings by setting environment variables with `extraEnvVars`.
See [containers README](../../../containers/spotfire-terrservice/README.md#environment-variables) for the complete list.

Example:
```
extraEnvVars:
- name: TERR_RESTRICTED_EXECUTION_MODE
  value: "FALSE"
```

Additionally, you can override the default configuration settings by providing a custom configuration file.

The following configuration keys are available in the chart:
- config."custom.properties"

**Note**: If a configuration file key is non-empty, it overrides the default service configuration file built in the image.

For the TERR™ service configuration, see [Custom configuration properties](https://docs.tibco.com/pub/terrsrv/latest/doc/html/TIB_terrsrv_install/terrinstall/topics/custom_configuration_properties.html).

Example: Using `my-custom.properties` instead of the default `custom.properties`:
```bash
helm install my-release . \
    --set nodemanagerConfig.serverBackendAddress="$SPOTFIRE_SERVER" \
    --set logging.logForwarderAddress="$LOG_FORWARDER" \
    --set-file config.'custom\.properties'=my-custom.properties
```

**Note**: The keys are quoted because they contain periods. When you set them from the command line, you must escape the periods with a '\'.

#### Getting the container default configuration files

You can copy the default configuration files from the container image to use them as templates for your custom configuration.

**Note**: The configuration files content can be version dependent.

Example: Use the following command to get a copy of the original configuration file `custom.properties`.
You can replace the file name to get a copy any of the other container configuration files.
```bash
docker cp $(docker run --detach --rm --entrypoint=sleep tibco/spotfire-terrservice:<imagetag> 5):/opt/tibco/tsnm/nm/services/TERR/conf/custom.properties .
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

To use [KEDA](https://keda.sh/docs) for autoscaling, first install it in the Kubernetes cluster. You must also install a Prometheus instance that scrapes metrics from the Spotfire pods.

Example: A `values.yml` snippet configuration for enabling autoscaling with KEDA:
```
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

The `spotfire-terrservice` has the following autoscaling defaults:
- The default metric is the `spotfire_service_queue_engines_inUse`.
- The default query is the sum of _service_queue_engines_inUse_ of the TERR service instances.

The counter _serviceQueueEnginesInUse_ provides the total number of engines currently executing.
By default, the TERR service has `number of cores - 1` available slots, which means that `kedaAutoscaling.threshold` should be synchronized with `resources.limits.cpu`.
Typically, you want to scale out before all the available capacity is taken. Therefore, the `kedaAutoscaling.threshold` should be lower than `resources.limits.cpu`.

**Note**:  Clients requesting a slot typically wait until a slot is available.

For more information, see [Monitoring the TERR service](https://docs.tibco.com/pub/terrsrv/latest/doc/html/TIB_terrsrv_install/terrinstall/topics/monitoring_the_terr_service_using_jmx.html).

**Note**: You can tune `nodemanagerConfig.preStopDrainingTimeoutSeconds` and other timeouts (for example, `engine.execution.timeout` and `engine.session.maxtime`) so that long-running jobs are not aborted prematurely when an instance is stopped to scale in.
See [Engine Timeout](https://docs.tibco.com/pub/terrsrv/latest/doc/html/TIB_terrsrv_install/terrinstall/topics/engine_timeout.html) for more details.

For more advanced scenarios, see [kedaAutoscaling.advanced](https://keda.sh/docs/latest/concepts/scaling-deployments/#advanced) and [kedaAutoscaling.fallback](https://keda.sh/docs/latest/concepts/scaling-deployments/#fallback).

Additionally, you can define your own [custom scaling triggers](https://keda.sh/docs/latest/concepts/scaling-deployments/#triggers). Helm template functionality is available:
```
kedaAutoscaling:
  triggers:
  # {list of triggers to activate scaling of the target resource}
```

### Upgrade

To upgrade the `my-release` deployment:
```bash
helm upgrade --install my-release .
```

See [helm upgrade](https://helm.sh/docs/helm/helm_upgrade/) for command documentation.

**Note**: When you upgrade to a newer Spotfire Server version and newer Spotfire services versions, upgrade the Spotfire Server first, and then upgrade the Spotfire services.

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | object | `{}` |  |
| config."conf/custom.properties" | string | `""` | If set, it will override the default [custom.properties](https://docs.tibco.com/pub/terrsrv/latest/doc/html/TIB_terrsrv_install/terrinstall/topics/custom_configuration_properties.html) file. |
| config."log4j2.xml" | string | `""` |  |
| extraEnvVars | list | `[]` | Additional environment variables. |
| extraEnvVarsCM | string | `""` |  |
| extraEnvVarsSecret | string | `""` |  |
| extraInitContainers | list | `[]` | Additional init containers to add to the terrservice pod. |
| extraVolumeMounts | list | `[]` | Extra volumeMounts for the spotfire-terrservice container. More info: `kubectl explain deployment.spec.template.spec.containers.volumeMounts` |
| extraVolumes | list | `[]` | Extra volumes for the spotfire-terrservice container. More info: `kubectl explain deployment.spec.template.spec.volumes` |
| fluentBitSidecar.image.pullPolicy | string | `"IfNotPresent"` | The image pull policy for the fluent-bit logging sidecar image. |
| fluentBitSidecar.image.repository | string | `"fluent/fluent-bit"` | The image repository for fluent-bit logging sidecar. |
| fluentBitSidecar.image.tag | string | `"2.0.5"` | The image tag to use for fluent-bit logging sidecar. |
| fluentBitSidecar.securityContext | object | `{}` | The securityContext setting for fluent-bit sidecar container. Overrides any securityContext setting on the Pod level. |
| fullnameOverride | string | `""` |  |
| global.serviceName | string | `"terrservice"` |  |
| global.spotfire.image.pullPolicy | string | `"IfNotPresent"` | The global container image pull policy. |
| global.spotfire.image.pullSecrets | list | `[]` | The global container image pull secrets. |
| global.spotfire.image.registry | string | `nil` | The global container image registry. Used for tibco/spotfire container images, unless it is overridden. |
| image.pullPolicy | string | `nil` | The spotfire-server image pull policy. Overrides global.spotfire.image.pullPolicy. |
| image.pullSecrets | list | `[]` | spotfire-server image pull secrets. |
| image.registry | string | `nil` | The image registry for spotfire-server. Overrides global.spotfire.image.registry value. |
| image.repository | string | `"tibco/spotfire-terrservice"` | The spotfire-server image repository. |
| image.tag | string | `"1.14.0-1.2.0"` | The container image tag to use. |
| kedaAutoscaling | object | Disabled | KEDA autoscaling configuration. See https://keda.sh/docs/latest/concepts/scaling-deployment for more details. |
| kedaAutoscaling.cooldownPeriod | int | `300` | The period to wait after the last trigger reported active before scaling the resource back to 0. |
| kedaAutoscaling.maxReplicas | int | `4` | This setting is passed to the HPA definition that KEDA creates for a given resource and holds the maximum number of replicas of the target resource. |
| kedaAutoscaling.minReplicas | int | `1` | The minimum number of replicas KEDA scales the resource down to. |
| kedaAutoscaling.pollingInterval | int | `30` | The interval to check each trigger on. |
| kedaAutoscaling.spotfireConfig | object | `{"prometheusServerAddress":"http://prometheus-server.monitor.svc.cluster.local"}` | Spotfire specific settings. |
| kedaAutoscaling.spotfireConfig.prometheusServerAddress | string | `"http://prometheus-server.monitor.svc.cluster.local"` | REQUIRED. The URL to the Prometheus server where metrics are fetched from. |
| livenessProbe.enabled | bool | `true` |  |
| livenessProbe.failureThreshold | int | `10` |  |
| livenessProbe.httpGet.path | string | `"/spotfire/liveness"` |  |
| livenessProbe.httpGet.port | string | `"registration"` |  |
| livenessProbe.initialDelaySeconds | int | `60` |  |
| livenessProbe.periodSeconds | int | `3` |  |
| logging.logForwarderAddress | string | `""` | The spotfire-server log-forwarder name. Template. |
| logging.logLevel | string | `"debug"` |  |
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
| securityContext | object | `{}` | The securityContext setting for the spotfire-terrservice container. Overrides any securityContext setting on the Pod level. |
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
| volumes.packages.existingClaim | string | `""` |  |
| volumes.packages.mountPath | string | `"/opt/packages"` |  |
| volumes.packages.persistentVolumeClaim.create | bool | `false` | If 'true', then a 'PersistentVolumeClaim' is created. |
| volumes.packages.persistentVolumeClaim.resources | object | `{"requests":{"storage":"1Gi"}}` | Specifies the standard Kubernetes resource requests and/or the limits for the customExt volume claims. |
| volumes.packages.persistentVolumeClaim.storageClassName | string | `""` | Specifies the name of the 'StorageClass' to use for the customExt volume-claim. |
| volumes.packages.persistentVolumeClaim.volumeName | string | `nil` | Specify the name of the persistent volume that should be used for the customExt volume-claim. |
| volumes.troubleshooting.existingClaim | string | `""` | When 'persistentVolumeClaim.create' is 'false', then use this value to define an already-existing persistent volume claim. |
| volumes.troubleshooting.persistentVolumeClaim.create | bool | `false` | If 'true', then a 'PersistentVolumeClaim' will be created. |
| volumes.troubleshooting.persistentVolumeClaim.resources | object | `{"requests":{"storage":"2Gi"}}` | Specifies the standard K8s resource requests and/or limits for the volumes.troubleshooting claims. |
| volumes.troubleshooting.persistentVolumeClaim.storageClassName | string | `""` | Specify the name of the 'StorageClass' that should be used for the volumes.troubleshooting-claim. |
| volumes.troubleshooting.persistentVolumeClaim.volumeName | string | `nil` | Specifies the name of the persistent volume to use for the volumes.troubleshooting-claim. |

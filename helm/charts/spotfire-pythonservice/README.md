# spotfire-pythonservice

![Version: 0.1.0](https://img.shields.io/badge/Version-0.1.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 1.11.1](https://img.shields.io/badge/AppVersion-1.11.1-informational?style=flat-square)

A Helm chart for TIBCO Spotfire® Service for Python

## Requirements

| Repository | Name | Version |
|------------|------|---------|
| file://../spotfire-common | spotfire-common | 0.1.0 |
| file://../spotfire-fluentbit-configuration | spotfire-fluentbit-configuration | 0.1.0 |

## Overview

This chart deploys the [TIBCO Spotfire® Service for Python](https://docs.tibco.com/pub/spotfire_server/latest/doc/html/TIB_sfire_server_tsas_admin_help/server/topics/introduction_to_the_tibco_spotfire_environment.html) service on a [Kubernetes](http://kubernetes.io/) cluster using the [Helm](https://helm.sh/) package manager.

- The Python Service pod includes a [Fluent Bit](https://fluentbit.io/) sidecar container for log forwarding.
- The chart includes service annotations for [Prometheus](https://prometheus.io/) scrapers.
The Prometheus server will discover the service endpoint using these specifications and will scrape metrics from the exporter.

This chart has been tested to work with [Elasticsearch](www.elastic.co/products/elasticsearch) and [Prometheus](https://prometheus.io/).

## Prerequisites

- A deployed Spotfire Server release, using the [Spotfire Server](../spotfire-server/README.md) chart.

## Usage

### Install

1. Export the `SPOTFIRE_SERVER` value to connect to the `spotfire-server` service:
    ```bash
    export SPOTFIRE_SERVER=$(kubectl get services --selector=app.kubernetes.io/part-of=spotfire,app.kubernetes.io/name=spotfire-server --output=jsonpath={.items..metadata.name})
    ```
2.  To forward the logs to the `log-forwarder` service:
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

**Note**: You need to provide your private registry address where the Spotfire containers are stored.

#### Configuration

You can override the default configuration settings by setting environment variables with `extraEnvVars`.
See [docker README](../../../docker/spotfire-pythonservice/README.md#environment-variables) for the complete list.

Example:
```
extraEnvVars:
- name: ENGINE_SESSION_MAXTIME_SECONDS
  value: "3600"
```

You can also override the default configuration settings by providing a custom configuration file.

The following configuration keys are available in the chart:
- config."custom.properties"

**Note**: If a configuration file key is non-emtpy it will override the default service configuration file built in the image.

For Spotfire Service for Python configuration, see [Custom configuration properties](https://docs.tibco.com/pub/sf-pysrv/latest/doc/html/TIB_sf-pysrv_install/pyinstall/topics/custom_configuration_properties.html).

Example: Using `my-custom.properties` instead of the default `custom.properties`:
```bash
helm install my-release . \
    --set nodemanagerConfig.serverBackendAddress="$SPOTFIRE_SERVER" \
    --set logging.logForwarderAddress="$LOG_FORWARDER" \
    --set-file config.'custom\.properties'=my-custom.properties
```

**Note**: The keys are quoted because they contain periods. When setting them from the command line the periods should be escaped with a `\`.

#### Get container original configuration files

It can be useful to get a copy of the default configuration files used in the container image to use them as templates for your custom configuration.

**Note**: The configuration files content can be version dependent.

Example: Use the following command to get a copy of the original configuration file `custom.properties`.
You can replace the filename to get a copy any of the other container configuration files.
```bash
docker cp $(docker run --detach --rm --entrypoint=sleep tibco/spotfire-pythonservice:<imagetag> 5):/opt/tibco/tsnm/nm/services/PYTHON/conf/custom.properties .
```

**Note**: The previous command can only copy the contents from a running container instance.

### Uninstall

To uninstall/delete the `my-release` deployment:
```bash
helm delete my-release
```

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

For the `spotfire-terrservice`, the default autoscaling metric used is the `spotfire_service_queue_engines_inUse`.
And the default query used is the sum of _service_queue_engines_inUse_ of the Python service instances.

The counter _serviceQueueEnginesInUse_ provides the total number of engines currently executing.
By default, the Python service has `number of cores - 1` available slots, which means that `kedaAutoscaling.threshold` should be synchronized with `resources.limits.cpu`.
Typically, you want to scale out before all of the available capacity is taken, so the `kedaAutoscaling.threshold` should be lower than `resources.limits.cpu`.
Note that clients requesting a slot will typically wait until a slot is available.

For more information, see [Monitoring the Python service](https://docs.tibco.com/pub/sf-pysrv/latest/doc/html/TIB_sf-pysrv_install/pyinstall/topics/monitoring_spotfire_service_for_python_using_jmx.html).

**Note**: You can tune `nodemanagerConfig.preStopDrainingTimeoutSeconds` and other timeouts (e.g., `engine.execution.timeout` and `engine.session.maxtime`, so that long running jobs are not aborted prematurely when scaling in.
See [Engine Timeout](https://docs.tibco.com/pub/sf-pysrv/latest/doc/html/TIB_sf-pysrv_install/pyinstall/topics/engine_timeout.html) for more details).

For more advanced scenarios, see [kedaAutoscaling.advanced](https://keda.sh/docs/latest/concepts/scaling-deployments/#advanced) and [kedaAutoscaling.fallback](https://keda.sh/docs/latest/concepts/scaling-deployments/#fallback).

### Upgrade

_TODO: Provide details on how to upgrade Spotfire using this chart_

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | object | `{}` |  |
| config."conf/custom.properties" | string | `""` | A custom [Spotfire.Dxp.Worker.Automation.config](https://docs.tibco.com/pub/spotfire_server/latest/doc/html/TIB_sfire_server_tsas_admin_help/server/topics/spotfire.dxp.worker.automation.config_file.html) |
| config."log4j2.xml" | string | `""` | A custom Spotfire.Dxp.Worker.Host.dll.config. See [Spotfire.Dxp.Worker.Host.exe.config](https://docs.tibco.com/pub/spotfire_server/latest/doc/html/TIB_sfire_server_tsas_admin_help/server/topics/spotfire.dxp.worker.host.exe.config_file.html) |
| extraEnvVars | list | `[]` | Additional environment variables |
| extraEnvVarsCM | string | `""` |  |
| extraEnvVarsSecret | string | `""` |  |
| extraVolumeMounts | list | `[]` | Extra volumeMounts for the spotfire-pythonservice container. More info: `kubectl explain deployment.spec.template.spec.containers.volumeMounts` |
| extraVolumes | list | `[]` | Extra volumes for the spotfire-pythonservice container. More info: `kubectl explain deployment.spec.template.spec.volumes` |
| fluentBit.image.pullPolicy | string | `"IfNotPresent"` | image pull policy for the fluent-bit logging sidecar image. |
| fluentBit.image.repository | string | `"fluent/fluent-bit"` | image repository for fluent-bit logging sidecar. |
| fluentBit.image.tag | string | `"1.8.12"` | image tag to be used for fluent-bit logging sidecar |
| fullnameOverride | string | `""` |  |
| global.serviceName | string | `"pythonservice"` |  |
| global.spotfire.image.pullPolicy | string | `"IfNotPresent"` | Global container image pull policy |
| global.spotfire.image.pullSecrets | list | `[]` | Global container image pull secrets |
| global.spotfire.image.registry | string | `nil` | Global container image registry, this will be used for tibco/spotfire container images unless overridden. |
| image.pullPolicy | string | `nil` | spotfire-server image pull policy, It overrides global.spotfire.image.pullPolicy |
| image.pullSecrets | list | `[]` | spotfire-server image pull secrets |
| image.registry | string | `nil` | image registry for spotfire-server, it overrides global.spotfire.image.registry value. |
| image.repository | string | `"tibco/spotfire-pythonservice"` | spotfire-server image repository |
| image.tag | string | `"1.11.1-v0.1.0"` | The container image tag to be used. |
| kedaAutoscaling | object | Disabled | KEDA autoscaling configuration, see https://keda.sh/docs/2.6/concepts/scaling-deployment for more details. |
| kedaAutoscaling.cooldownPeriod | int | `300` | The period to wait after the last trigger reported active before scaling the resource back to 0. |
| kedaAutoscaling.maxReplicas | int | `4` | This setting is passed to the HPA definition that KEDA will create for a given resource and holds the maximum number of replicas of the target resource. |
| kedaAutoscaling.minReplicas | int | `1` | Minimum number of replicas KEDA will scale the resource down to. |
| kedaAutoscaling.pollingInterval | int | `30` | This is the interval to check each trigger on. |
| kedaAutoscaling.spotfireConfig | object | `{"prometheusServerAddress":"http://prometheus-server.monitor.svc.cluster.local"}` | Spotfire specific settings |
| kedaAutoscaling.spotfireConfig.prometheusServerAddress | string | `"http://prometheus-server.monitor.svc.cluster.local"` | REQUIRED The url to the Prometheus server where metrics should be fetched from |
| livenessProbe.enabled | bool | `true` |  |
| livenessProbe.failureThreshold | int | `3` |  |
| livenessProbe.httpGet.path | string | `"/spotfire/liveness"` |  |
| livenessProbe.httpGet.port | string | `"registration"` |  |
| livenessProbe.initialDelaySeconds | int | `60` |  |
| livenessProbe.periodSeconds | int | `3` |  |
| logging.logForwarderAddress | string | `""` | This should be the spotfire-server log-forwarder name. Template. |
| logging.logLevel | string | `"debug"` |  |
| nameOverride | string | `""` |  |
| nodeSelector | object | `{}` |  |
| nodemanagerConfig.preStopDrainingTimeoutSeconds | int | `610` | The draining timeout which after the service is forcefully shutdown |
| nodemanagerConfig.serverBackendAddress | string | `""` | This should be the spotfire-server service name. This value will be evaluated as a helm template. |
| podAnnotations."prometheus.io/path" | string | `"/spotfire/metrics"` |  |
| podAnnotations."prometheus.io/port" | string | `"9080"` |  |
| podAnnotations."prometheus.io/scrape" | string | `"true"` |  |
| podSecurityContext | object | `{}` |  |
| readinessProbe.enabled | bool | `false` |  |
| readinessProbe.failureThreshold | int | `3` |  |
| readinessProbe.httpGet.path | string | `"/spotfire/readiness"` |  |
| readinessProbe.httpGet.port | string | `"registration"` |  |
| readinessProbe.initialDelaySeconds | int | `60` |  |
| readinessProbe.periodSeconds | int | `3` |  |
| replicaCount | int | `1` |  |
| resources | object | `{}` |  |
| securityContext | object | `{}` |  |
| service.port | int | `9501` |  |
| service.type | string | `"ClusterIP"` |  |
| serviceAccount.annotations | object | `{}` |  |
| serviceAccount.create | bool | `false` |  |
| serviceAccount.name | string | `""` |  |
| startupProbe.enabled | bool | `true` |  |
| startupProbe.failureThreshold | int | `30` |  |
| startupProbe.httpGet.path | string | `"/spotfire/started"` |  |
| startupProbe.httpGet.port | string | `"registration"` |  |
| startupProbe.initialDelaySeconds | int | `10` |  |
| startupProbe.periodSeconds | int | `3` |  |
| tolerations | list | `[]` |  |
| volumes.packages.customPersistentVolumeClaimName | string | `""` |  |
| volumes.packages.mountPath | string | `"/opt/packages"` |  |
| volumes.packages.name | string | `"packages"` |  |
| volumes.packages.persistentVolumeClaim.create | bool | `false` | If 'true', then a 'PersistentVolumeClaim' will be created. |
| volumes.packages.persistentVolumeClaim.resources | object | `{"requests":{"storage":"1Gi"}}` | Specifies the standard K8s resource requests and/or limits for the customExt volume claims. |
| volumes.packages.persistentVolumeClaim.storageClassName | string | `""` | Specify the name of the 'StorageClass' that should be used for the customExt volume-claim. |
| volumes.packages.persistentVolumeClaim.volumeName | string | `nil` | Specify the name of the persistent volume that should be used for the customExt volume-claim. |

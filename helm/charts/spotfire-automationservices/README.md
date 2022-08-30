# spotfire-automationservices

![Version: 0.1.2](https://img.shields.io/badge/Version-0.1.2-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 12.0.0](https://img.shields.io/badge/AppVersion-12.0.0-informational?style=flat-square)

A Helm chart for TIBCO Spotfire Automation Services.

**Homepage:** <https://github.com/TIBCO/Spotfire-cloud-deployment-kit>

## Source Code

* <https://github.com/TIBCO/Spotfire-cloud-deployment-kit>

## Requirements

| Repository | Name | Version |
|------------|------|---------|
| file://../spotfire-common | spotfire-common | 0.1.2 |

## Overview

This chart deploys the [TIBCO Spotfire® Automation Services](https://docs.tibco.com/pub/spotfire_server/latest/doc/html/TIB_sfire_server_tsas_admin_help/server/topics/introduction_to_the_tibco_spotfire_environment.html) service on a [Kubernetes](http://kubernetes.io/) cluster using the [Helm](https://helm.sh/) package manager.

- The Automation Services pod includes a [Fluent Bit](https://fluentbit.io/) sidecar container for log forwarding.
- The chart includes service annotations for [Prometheus](https://prometheus.io/) scrapers.
The Prometheus server discovers the service endpoint using these specifications and scrapes metrics from the exporter.

This chart is tested to work with [Elasticsearch](https://www.elastic.co/elasticsearch/) and [Prometheus](https://prometheus.io/).

## Prerequisites

- A deployed Spotfire Server release using the [Spotfire Server](../spotfire-server/README.md) chart.
- A Spotfire distribution file (`Spotfire.Dxp.sdn` or `Spotfire.Dxp.netcore-linux.sdn`) with client packages deployed to a deployment area (so that the required licenses are in place for the Spotfire Automation Services to start).

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

#### Configuring

Override the default configuration settings by providing a custom configuration file.

The following example configuration keys are available in the chart:
- config."Spotfire.Dxp.Worker.Automation.config"
- config."Spotfire.Dxp.Worker.Core.config"
- config."Spotfire.Dxp.Worker.Web.config"
- config."Spotfire.Dxp.Worker.Host.dll.config"
- config."log4net.config"

**Note**: If a configuration file key is non-empty, it overrides the default service configuration file built in the image.

See [Service configuration files](https://docs.tibco.com/pub/spotfire_server/latest/doc/html/TIB_sfire_server_tsas_admin_help/server/topics/service_configuration_files.html)
 and [Service logs configuration](https://docs.tibco.com/pub/spotfire_server/latest/doc/html/TIB_sfire_server_tsas_admin_help/server/topics/service_logs.html).

Example: Use `my-Spotfire.Dxp.Worker.Automation.config` instead of the default `Spotfire.Dxp.Worker.Automation.config`:
```bash
helm install my-release . \
    --set nodemanagerConfig.serverBackendAddress="$SPOTFIRE_SERVER" \
    --set logging.logForwarderAddress="$LOG_FORWARDER" \
    --set-file config.'Spotfire\.Dxp\.Worker\.Automation\.config'=my-Spotfire.Dxp.Worker.Automation.config
```

**Note**: The keys are quoted because they contain periods. When you set them from the command line, you must escape the periods with a `\`.

#### Getting the original container configuration files

Copy the default configuration files used in the container image and use them as templates for your custom configuration.

**Note**: The configuration files content can be version dependent.

Example: Use the following command to get a copy of the original configuration file `Spotfire.Dxp.Worker.Automation.config`.
You can replace the file name to get a copy any of the other container configuration files.
```bash
docker cp $(docker run --detach --rm --entrypoint=sleep tibco/spotfire-automationservices:<imagetag> 5):/opt/tibco/tsnm/nm/services/AUTOMATION_SERVICES/Spotfire.Dxp.Worker.Automation.config .
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
kedaAutoscaling:
  enabled: true
  spotfireConfig:
    prometheusServerAddress: http://prometheus-server.monitor.svc.cluster.local
  threshold: 6
  minReplicas: 0
  maxReplicas: 3
```

The `spotfire-automationservices` has the following defaults:
- The default autoscaling metric is the `spotfire_Jobs_QueueSize`.
- The default query is the max _Jobs Queue Size_ of the Automation Services instances.

With these settings, if the queue reaches capacity, another instance is scaled out; if the queue falls below the capacity threshold, the instance is scaled in.

**Note**: You can tune `nodemanagerConfig.preStopDrainingTimeoutSeconds` and other timeouts for long running tasks, so that jobs are not aborted prematurely when the instance is scaled in.

**Note**: The metric used for autoscaling is scraped from the Spotfire Servers, so if there are more than one Spotfire Server helm releases in the same namespace, `kedaAutoscaling.spotfireConfig.spotfireServerHelmRelease` must also be set.

For more advanced scenarios, see [kedaAutoscaling.advanced](https://keda.sh/docs/latest/concepts/scaling-deployments/#advanced) and [kedaAutoscaling.fallback](https://keda.sh/docs/latest/concepts/scaling-deployments/#fallback).

Additionally, you can define your own [custom scaling triggers](https://keda.sh/docs/latest/concepts/scaling-deployments/#triggers). Helm template functionality is available:
```
kedaAutoscaling:
  triggers:
  # {list of triggers to activate scaling of the target resource}
```

### Upgrading

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
| config."Spotfire.Dxp.Worker.Automation.config" | string | `""` | A custom [Spotfire.Dxp.Worker.Automation.config](https://docs.tibco.com/pub/spotfire_server/latest/doc/html/TIB_sfire_server_tsas_admin_help/server/topics/spotfire.dxp.worker.automation.config_file.html). |
| config."Spotfire.Dxp.Worker.Core.config" | string | `""` | A custom [Spotfire.Dxp.Worker.Core.config](https://docs.tibco.com/pub/spotfire_server/latest/doc/html/TIB_sfire_server_tsas_admin_help/server/topics/spotfire.dxp.worker.core.config_file.html). |
| config."Spotfire.Dxp.Worker.Host.dll.config" | string | `""` | A custom Spotfire.Dxp.Worker.Host.dll.config. See [Spotfire.Dxp.Worker.Host.exe.config](https://docs.tibco.com/pub/spotfire_server/latest/doc/html/TIB_sfire_server_tsas_admin_help/server/topics/spotfire.dxp.worker.host.exe.config_file.html). |
| config."Spotfire.Dxp.Worker.Web.config" | string | `""` | A custom [Spotfire.Dxp.Worker.Web.config](https://docs.tibco.com/pub/spotfire_server/latest/doc/html/TIB_sfire_server_tsas_admin_help/server/topics/spotfire.dxp.worker.web.config_file.html). |
| extraEnvVars | list | `[]` | Additional environment variables. |
| extraEnvVarsCM | string | `""` |  |
| extraEnvVarsSecret | string | `""` |  |
| extraInitContainers | list | `[]` | Additional init containers to add to the automationservices pod. |
| extraVolumeMounts | list | `[]` | Extra volumeMounts for the spotfire-automationservices container. More info: `kubectl explain deployment.spec.template.spec.containers.volumeMounts`. |
| extraVolumes | list | `[]` | Extra volumes for the spotfire-automationservices container. More info: `kubectl explain deployment.spec.template.spec.volumes`. |
| fluentBitSidecar.image.pullPolicy | string | `"IfNotPresent"` | image pull policy for the fluent-bit logging sidecar image. |
| fluentBitSidecar.image.repository | string | `"fluent/fluent-bit"` | image repository for fluent-bit logging sidecar. |
| fluentBitSidecar.image.tag | string | `"1.9.7"` | image tag to use for fluent-bit logging sidecar |
| fluentBitSidecar.securityContext | object | `{}` | securityContext setting for fluent-bit sidecar container. Overrides any securityContext setting on the Pod level. |
| fullnameOverride | string | `""` |  |
| global.serviceName | string | `"automationservices"` |  |
| global.spotfire.image.pullPolicy | string | `"IfNotPresent"` | Global container image pull policy. |
| global.spotfire.image.pullSecrets | list | `[]` | Global container image pull secrets. |
| global.spotfire.image.registry | string | `nil` | Global container image registry. Used for tibco/spotfire container images unless it is overridden. |
| image.pullPolicy | string | `nil` | spotfire-server image pull policy. Overrides global.spotfire.image.pullPolicy. |
| image.pullSecrets | list | `[]` | The spotfire-server image pull secrets. |
| image.registry | string | `nil` | The image registry for spotfire-server. Overrides global.spotfire.image.registry value. |
| image.repository | string | `"tibco/spotfire-automationservices"` | The spotfire-server image repository. |
| image.tag | string | `"12.0.0-1.0.0"` | The container image tag to use. |
| kedaAutoscaling | object | Disabled. | KEDA autoscaling configuration. See https://keda.sh/docs/latest/concepts/scaling-deployment for more details. |
| kedaAutoscaling.cooldownPeriod | int | `300` | The period to wait after the last trigger reported active before scaling the resource back to 0. |
| kedaAutoscaling.maxReplicas | int | `4` | This setting is passed to the HPA definition that KEDA creates for a given resource and holds the maximum number of replicas of the target resource. |
| kedaAutoscaling.minReplicas | int | `0` | The minimum number of replicas KEDA scales the resource down to. |
| kedaAutoscaling.pollingInterval | int | `30` | The interval to check each trigger on. |
| kedaAutoscaling.spotfireConfig | object | `{"prometheusServerAddress":"http://prometheus-server.monitor.svc.cluster.local","spotfireServerHelmRelease":null}` | Spotfire specific settings |
| kedaAutoscaling.spotfireConfig.prometheusServerAddress | string | `"http://prometheus-server.monitor.svc.cluster.local"` | REQUIRED. The URL for the Prometheus server where metrics are fetched from. |
| kedaAutoscaling.spotfireConfig.spotfireServerHelmRelease | string | `nil` | If more than one Spotfire Server release is installed in the same namespace, specify the release to get the correct metrics. |
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
| nodemanagerConfig.preStopDrainingTimeoutSeconds | int | `610` | The draining timeout after which the service is forcefully shutdown |
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
| securityContext | object | `{}` | The securityContext setting for the spotfire-automationservices container. Overrides any securityContext setting on the Pod level. |
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
| volumes.troubleshooting.existingClaim | string | `""` | When 'persistentVolumeClaim.create' is 'false', then use this value to define an already-existing persistent volume claim. |
| volumes.troubleshooting.persistentVolumeClaim.create | bool | `false` | If 'true', then a 'PersistentVolumeClaim' is created. |
| volumes.troubleshooting.persistentVolumeClaim.resources | object | `{"requests":{"storage":"2Gi"}}` | Specifies the standard Kubernetes resource requests and/or the limits for the volumes.troubleshooting claims. |
| volumes.troubleshooting.persistentVolumeClaim.storageClassName | string | `""` | Specifies the name of the 'StorageClass' to use for the volumes.troubleshooting-claim. |
| volumes.troubleshooting.persistentVolumeClaim.volumeName | string | `nil` | Specifies the name of the persistent volume to use for the volumes.troubleshooting-claim. |

# spotfire-webplayer

![Version: 0.4.0](https://img.shields.io/badge/Version-0.4.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 14.4.2](https://img.shields.io/badge/AppVersion-14.4.2-informational?style=flat-square)

A Helm chart for Spotfire Web Player.

**Homepage:** <https://github.com/spotfiresoftware/spotfire-cloud-deployment-kit>

## Requirements

Kubernetes: `>=1.24.0-0`

| Repository | Name | Version |
|------------|------|---------|
| file://../spotfire-common | spotfire-common | 0.4.0 |

## Overview

This chart deploys the [Spotfire® Web Player](https://docs.tibco.com/pub/spotfire_server/latest/doc/html/TIB_sfire_server_tsas_admin_help/server/topics/introduction_to_the_spotfire_environment.html) service on a [Kubernetes](http://kubernetes.io/) cluster using the [Helm](https://helm.sh/) package manager.

The Spotfire Web Player pod includes:
- A [Fluent Bit](https://fluentbit.io/) sidecar container for log forwarding.
- Service annotations for [Prometheus](https://prometheus.io/) scrapers. The Prometheus server discovers the service endpoint using these specifications and scrapes metrics from the exporter.
- Predefined configuration for horizontal pod autoscaling with [KEDA](https://keda.sh/docs) and Prometheus.

This chart is tested to work with [Elasticsearch](https://www.elastic.co/elasticsearch/), [Prometheus](https://prometheus.io/) and [KEDA](https://keda.sh/).

## Prerequisites

- A deployed Spotfire Server release using the [Spotfire Server](../spotfire-server/README.md) chart.
- A Spotfire distribution file (`Spotfire.Dxp.sdn`) with client packages deployed to a deployment area (so that the required licenses are in place for the service to start).

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

#### Configuring

You can override the default configuration settings by providing a custom configuration file.

The following example configuration keys are available in the chart:
- config."Spotfire.Dxp.Worker.Core.config"
- config."Spotfire.Dxp.Worker.Web.config"
- config."Spotfire.Dxp.Worker.Host.dll.config"
- config."log4net.config"

**Note**: If a configuration file key is non-empty, it overrides the default service configuration file built in the container image.

See [Service configuration files](https://docs.tibco.com/pub/spotfire_server/latest/doc/html/TIB_sfire_server_tsas_admin_help/server/topics/service_configuration_files.html)
 and [Service logs configuration](https://docs.tibco.com/pub/spotfire_server/latest/doc/html/TIB_sfire_server_tsas_admin_help/server/topics/service_logs.html).

Example: Use `my-Spotfire.Dxp.Worker.Web.config` instead of the default `Spotfire.Dxp.Worker.Web.config`:
```bash
helm install my-release . \
    --set acceptEUA=true \
    --set nodemanagerConfig.serverBackendAddress="$SPOTFIRE_SERVER" \
    --set logging.logForwarderAddress="$LOG_FORWARDER" \
    --set-file config.'Spotfire\.Dxp\.Worker\.Web\.config'=my-Spotfire.Dxp.Worker.Web.config
```

**Note**: The keys are quoted because they contain periods. When you set them from the command line, you must escape the periods with a '\'.

#### Getting the container default configuration files

You can copy the default configuration files from the container image to use them as templates for your custom configuration.

**Note**: The configuration files content can be version dependent.

Example: Use the following command to get a copy of the original configuration file `Spotfire.Dxp.Worker.Web.config`.
You can replace the filename to get a copy any of the other container configuration files.
```bash
docker run --rm spotfire/spotfire-webplayer:<imagetag> cat /opt/spotfire/nodemanager/nm/services/WEB_PLAYER/Spotfire.Dxp.Worker.Web.config > Spotfire.Dxp.Worker.Web.config
```

#### Adding a credentials profile for connectors to services as a file

A credentials profile is a method for storing data source credentials to log in automatically when you use data connections in web clients, Automation Services, and scheduled updates.

1. Get a copy of the service configuration `Spotfire.Dxp.Worker.Host.dll.config`. (See how in the previous example.
2. Update the connector's authentication mode to `WebConfig`.
3. Create a credentials profile in the following format, renaming the file with credentials_profile_name without extension.
    ```
    <entry profile="credentials_profile_name">
      <allowed-usages>
          <entry server-regex="database\.example\.com" />
          <entry connector-id="Spotfire.GoogleAnalyticsAdapter" />
      </allowed-usages>
      <username>my_username</username>
      <password>my_password</password>
    </entry>
    ```
4. Using _extraVolumeMounts_, mount the file to the location `/secrets/credentials` (overriding using the service configuration).
5. See the [configuration section](#configuring) to upgrade the deployment.

For more information, see [Credentials profiles for connectors](https://docs.tibco.com/pub/spotfire_server/latest/doc/html/TIB_sfire_server_tsas_admin_help/server/topics/credentials_profiles.html)

#### Custom modules

The image uses the modules that are built into the image and does not download images from or use a [Spotfire deployment area](https://docs.tibco.com/pub/spotfire_server/latest/doc/html/TIB_sfire_server_tsas_admin_help/server/topics/deployments_and_deployment_areas.html). To use your own custom deployment files (or modules) you can use the argument `volumes.customModules` to set a Volume that will be used for loading extra custom modules. See *helm/examples/webplayer-custom-modules/README.md* in the Spotfire Cloud Deployment Kit repository for an example of how to use this feature.

### Adding additional ODBC drivers for Spotfire Connectors

If you want to use certain Spotfire connectors that are not available in the default image, you will need to install the required ODBC driver for the connector in the image. Please refer to the [README.md file for the spotfire-webplayer container image](../../../containers/images/spotfire-webplayer/README.md) for detailed instructions on how to extend the image and add additional ODBC drivers.

Once you have extended the image and included the necessary ODBC drivers, you must push the modified image to a registry that can be accessed by the Kubernetes cluster. Finally, update the `spotfire.image.*` values in your configuration to point to the new image.

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
  threshold: 4
  minReplicas: 1
  maxReplicas: 3
```

The `spotfire-webplayer` has the following autoscaling defaults:
- metric name: `spotfire_Spotfire_Webplayer_Web_Player_health_status` (_Health status_ Web Player service performance counter).
- query: the sum of `spotfire_Spotfire_Webplayer_Web_Player_health_status` counters of the Web Player instances for the release name.

For any Web Player instance, _Health status_ can present one of the following values:
- 0: OK. Indicates that the instance is under no pressure.
- 5: Strained. Indicates that the instance is under pressure but is not a problem.
- 8: Exhausted. Indicates that the instance is under a higher load, so avoid routing new users to this instance, but current users can keep working in this instance.

_Health status_ is a composite metric consisting of a few things. For most common scenarios, it is mainly affected by CPU and memory consumption.

With these default settings (threshold `4`), if one Web Player instance is strained or exhausted, then another instance is started to scale out the service. If most of them are OK, then the service scales in.

For more information, see [Web Player service performance counters](https://docs.tibco.com/pub/spotfire_server/latest/doc/html/TIB_sfire_server_tsas_admin_help/server/topics/web_player_service_performance_counters.html).

**Note**: You can tune `nodemanagerConfig.preStopDrainingTimeoutSeconds` to allow time for draining sessions when scaling in.

To mitigate toggling scenarios, you can control the KEDA scale down policy.
For example, to scale down only one pod per hour:
```
kedaAutoscaling:
  advanced:
    horizontalPodAutoscalerConfig:
      behavior:
        scaleDown:
          policies:
          - type: Pods
            value: 1
            periodSeconds: 3600
```

For more advanced scenarios, see [kedaAutoscaling.advanced](https://keda.sh/docs/latest/concepts/scaling-deployments/#advanced) and [kedaAutoscaling.fallback](https://keda.sh/docs/latest/concepts/scaling-deployments/#fallback).

Additionally, you can define your own [custom scaling triggers](https://keda.sh/docs/latest/concepts/scaling-deployments/#triggers). Helm template functionality is available:
```
kedaAutoscaling:
  triggers:
  # {list of triggers to activate scaling of the target resource}
```

**Note**: For more details on the autoscaling defaults, see the [keda-autoscaling.yaml template](./templates/keda-autoscaling.yaml).

### Upgrading

See [helm upgrade](https://helm.sh/docs/helm/helm_upgrade/) for command documentation.

**Note**: When you upgrade to a newer Spotfire Server version and newer Spotfire services versions, upgrade the Spotfire Server first, and then upgrade the Spotfire services.

#### Upgrading helm chart version

Some parameters might have been changed, moved or renamed and must be taken into consideration when upgrading the release. See [release notes](https://github.com/spotfiresoftware/spotfire-cloud-deployment-kit/releases) for more information.

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| global.spotfire.acceptEUA | bool | `nil` | Accept the [Cloud Software Group, Inc. End User Agreement](https://www.cloud.com/legal/terms) by setting the value to `true`. |
| global.spotfire.image.pullPolicy | string | `"IfNotPresent"` | The global container image pull policy. |
| global.spotfire.image.pullSecrets | list | `[]` | The global container image pull secrets. |
| global.spotfire.image.registry | string | `nil` | The global container image registry. Used for spotfire/ container images, unless it is overridden. |
| acceptEUA | bool | `nil` | Accept the [Cloud Software Group, Inc. End User Agreement](https://www.cloud.com/legal/terms) by setting the value to `true`. |
| affinity | object | `{}` |  |
| config."Spotfire.Dxp.Worker.Core.config" | string | `""` | A custom [Spotfire.Dxp.Worker.Core.config](https://docs.tibco.com/pub/spotfire_server/latest/doc/html/TIB_sfire_server_tsas_admin_help/server/topics/spotfire.dxp.worker.core.config_file.html). |
| config."Spotfire.Dxp.Worker.Host.dll.config" | string | `""` | A custom Spotfire.Dxp.Worker.Host.dll.config. See [Spotfire.Dxp.Worker.Host.exe.config](https://docs.tibco.com/pub/spotfire_server/latest/doc/html/TIB_sfire_server_tsas_admin_help/server/topics/spotfire.dxp.worker.host.exe.config_file.html). |
| config."Spotfire.Dxp.Worker.Web.config" | string | `""` | A custom [Spotfire.Dxp.Worker.Web.config](https://docs.tibco.com/pub/spotfire_server/latest/doc/html/TIB_sfire_server_tsas_admin_help/server/topics/spotfire.dxp.worker.web.config_file.html). |
| extraContainers | list | `[]` | Additional sidecar containers to add to the service pod. |
| extraEnvVars | list | `[]` | Additional environment variables. |
| extraEnvVarsCM | string | `""` | The name of the ConfigMap containing additional environment variables. |
| extraEnvVarsSecret | string | `""` | The name of the Secret containing extra additional environment variables. |
| extraInitContainers | list | `[]` | Additional init containers to add to the service pod. |
| extraVolumeMounts | list | `[]` | Extra volumeMounts for the service container. More info: `kubectl explain deployment.spec.template.spec.containers.volumeMounts`. |
| extraVolumes | list | `[]` | Extra volumes for the service container. More info: `kubectl explain deployment.spec.template.spec.volumes`. |
| fluentBitSidecar.image.pullPolicy | string | `"IfNotPresent"` | The image pull policy for the fluent-bit logging sidecar image. |
| fluentBitSidecar.image.repository | string | `"fluent/fluent-bit"` | The image repository for fluent-bit logging sidecar. |
| fluentBitSidecar.image.tag | string | `"3.2.4"` | The image tag to use for fluent-bit logging sidecar. |
| fluentBitSidecar.securityContext | object | `{}` | The securityContext setting for fluent-bit sidecar container. Overrides any securityContext setting on the Pod level. |
| fullnameOverride | string | `""` |  |
| image.pullPolicy | string | `nil` | The spotfire-server image pull policy. Overrides global.spotfire.image.pullPolicy. |
| image.pullSecrets | list | `[]` | Image pull secrets. |
| image.registry | string | `nil` | The image registry for spotfire-server. Overrides global.spotfire.image.registry value. |
| image.repository | string | `"spotfire/spotfire-webplayer"` | The spotfire-server image repository. |
| image.tag | string | `"14.4.2-v2.6.0"` | The container image tag to use. |
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
| volumes.customModules.existingClaim | string | `""` | When 'persistentVolumeClaim.create' is 'false', then use this value to define an already existing persistent volume claim. |
| volumes.customModules.persistentVolumeClaim.create | bool | `false` | If 'true', then a 'PersistentVolumeClaim' is created. |
| volumes.customModules.persistentVolumeClaim.resources | object | `{"requests":{"storage":"2Gi"}}` | Specifies the standard Kubernetes resource requests and/or limits for the volumes.customModules claims. |
| volumes.customModules.persistentVolumeClaim.storageClassName | string | `""` | Specifies the name of the 'StorageClass' to use for the volumes.customModules-claim. |
| volumes.customModules.persistentVolumeClaim.volumeName | string | `nil` | Specifies the name of the persistent volume to use for the volumes.customModules-claim. |
| volumes.customModules.subPath | string | `""` | The subPath of the volume to be used for the volume mount |
| volumes.troubleshooting.existingClaim | string | `""` | When 'persistentVolumeClaim.create' is 'false', then use this value to define an already existing persistent volume claim. |
| volumes.troubleshooting.persistentVolumeClaim.create | bool | `false` | If 'true', then a 'PersistentVolumeClaim' will be created. |
| volumes.troubleshooting.persistentVolumeClaim.resources | object | `{"requests":{"storage":"2Gi"}}` | Specifies the standard Kubernetes resource requests and/or limits for the volumes.troubleshooting claims. |
| volumes.troubleshooting.persistentVolumeClaim.storageClassName | string | `""` | Specifies the name of the 'StorageClass' to use for the volumes.troubleshooting-claim. |
| volumes.troubleshooting.persistentVolumeClaim.volumeName | string | `nil` | Specifies the name of the persistent volume to use for the volumes.troubleshooting-claim. |
| webplayerConfig.resourcePool | string | `""` | The web player resource pool. |

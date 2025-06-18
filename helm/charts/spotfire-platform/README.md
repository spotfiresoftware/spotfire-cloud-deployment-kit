# spotfire-platform

![Version: 1.0.0](https://img.shields.io/badge/Version-1.0.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 14.5-v3.0.0](https://img.shields.io/badge/AppVersion-14.5--v3.0.0-informational?style=flat-square)

This is an umbrella chart for Spotfire, a chart that groups several Spotfire services together. It allows you to deploy, upgrade, and manage a Spotfire environment with optional Spotfire services.

## Requirements

Kubernetes: `>=1.24.0-0`

| Repository | Name | Version |
|------------|------|---------|
| file://../spotfire-automationservices/ | spotfire-automationservices | 1.0.0 |
| file://../spotfire-pythonservice/ | spotfire-pythonservice | 1.0.0 |
| file://../spotfire-rservice/ | spotfire-rservice | 1.0.0 |
| file://../spotfire-server/ | spotfire-server | 1.0.0 |
| file://../spotfire-terrservice/ | spotfire-terrservice | 1.0.0 |
| file://../spotfire-webplayer/ | spotfire-webplayer | 1.0.0 |
| https://charts.bitnami.com/bitnami | postgresql | 14.3.* |

## Overview

The Spotfire Helm chart is an umbrella chart that includes multiple components for deploying a Spotfire analytics platform. It consists of the following components:

- [spotfire-server](../spotfire-server/README.md)
- [spotfire-webplayer](../spotfire-webplayer/README.md)
- [spotfire-automationservices](../spotfire-automationservices/README.md)
- [spotfire-terrservice](../spotfire-terrservice/README.md)
- [spotfire-rservice](../spotfire-rservice/README.md)
- [spotfire-pythonservice](../spotfire-pythonservice/README.md)
- [PostgreSQL database](https://github.com/bitnami/charts/tree/main/bitnami/postgresql) ⚠️ 

Warning: The PostgreSQL chart is included as an example and is intended for demo and testing purposes only. It is important to note that the spotfire Helm chart does not take responsibility for data persistence in the Spotfire database. It is your responsibility to ensure that you have a proper data persistence strategy in place. Failure to do so may result in data loss. Please make sure you are familiar with the documentation of your chosen database (e.g., PostgreSQL, Oracle, SQL Server) and take appropriate measures to ensure data persistence.

Note: For more advanced configurations, where you need multiple instances of a single chart, such as two web players with different configurations, you can either deploy the chart directly to add another instance or create new umbrella that suits your needs.  The 'publicAddress' field is required.

## Installation

```bash
helm install my-release . --render-subchart-notes --set global.spotfire.acceptEUA=true \
    --set postgresql.enabled=true \
    --set spotfire-webplayer.enabled=true \
    --set spotfire-automationservices.enabled=true \
    --set spotfire-terrservice.enabled=true \
    --set spotfire-rservice.enabled=true \
    --set spotfire-pythonservice.enabled=true \
    --set spotfire-server.configuration.site.publicAddress=http://localhost/
```

This will deploy the Spotfire platform with all components enabled using the embedded PostgreSQL database.

### Using an external Spotfire database

To use an external database, you need to provide the database connection details to the database. We will use a PostgreSQL database for this example but you can use any other database supported by Spotfire.

First, install the PostgreSQL chart using Helm:

```bash
helm repo add bitnami https://charts.bitnami.com/bitnami
helm install spotfiredatabase bitnami/postgresql --set global.postgresql.auth.postgresPassword=PostgresAdminPassword
```

It will create a new PostgreSQL database with the password `PostgresAdminPassword` and the service name `spotfiredatabase-postgresql`.

Create a file named `spotfire-database.yaml` with the following content:

```yaml
spotfire-server:
  database:
    bootstrap:
      databaseUrl: "jdbc:postgresql://spotfiredatabase-postgresql/"
      driverClass: "org.postgresql.Driver"
      username: "spotfire"
      password: "SpotfireDatabasePassword"
    create-db:
      enabled: true
      adminUsername: "postgres"
      adminPassword: "PostgresAdminPassword"
      databaseUrl: "jdbc:postgresql://spotfiredatabase-postgresql/"
      adminPasswordExistingSecret:
        name: ""
        key: ""
```

If needed, adjust the values in the file to match your database configuration.

Then install the chart with the release name `my-release` using the database configuration:

```bash
helm install my-release . --render-subchart-notes --set postgresql.enabled=false --set global.spotfire.acceptEUA=true --values spotfire-database.yaml
```

Note that the `postgresql.enabled` parameter is set to `false` to disable the embedded PostgreSQL database.

## Usage

For detailed usage instructions, please refer to the README.md files of the individual components.

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| global.spotfire.acceptEUA | string | `nil` | Set to `true` to accept the [Cloud Software Group, Inc. End User Agreement](https://www.cloud.com/legal/terms). |
| global.spotfire.image.pullPolicy | string | `"IfNotPresent"` | The global container image pull policy. |
| global.spotfire.image.pullSecrets | list | `[]` | The global container image pull secrets. |
| global.spotfire.image.registry | string | `nil` | The global container image registry. Used for spotfire/ container images, unless it is overridden. |
| postgresql | object | - | See [PostgreSQL Helm Chart](https://github.com/bitnami/charts/tree/main/bitnami/postgresql) documentation. <br> <br> ⚠️ Warning: The PostgreSQL chart is included as an example and is intended for demo and testing purposes only. It is important to note that the spotfire Helm chart does not take responsibility for data persistence in the Spotfire database. It is your responsibility to ensure that you have a proper data persistence strategy in place. Failure to do so may result in data loss. Please make sure you are familiar with the documentation of your chosen database (e.g., PostgreSQL, Oracle, SQL Server) and take appropriate measures to ensure data persistence. |
| postgresql.enabled | bool | `false` | Enable or disable the PostgreSQL database component |
| spotfire-automationservices | object | - | See [spotfire-automationservices README.md](../spotfire-automationservices/README.md) for configuration options |
| spotfire-automationservices.enabled | bool | `false` | Enable or disable the Spotfire Automation Services component |
| spotfire-pythonservice | object | - | See [spotfire-pythonservice README.md](../spotfire-pythonservice/README.md) for configuration options |
| spotfire-pythonservice.enabled | bool | `false` | Enable or disable the Spotfire Python Service component |
| spotfire-rservice | object | - | See [spotfire-rservice README.md](../spotfire-rservice/README.md) for configuration options |
| spotfire-rservice.enabled | bool | `false` | Enable or disable the Spotfire R Service component |
| spotfire-server | object | - | See [spotfire-server README.md](../spotfire-server/README.md) for configuration options |
| spotfire-server.configuration.site.publicAddress | string | `""` | - |
| spotfire-server.database | object | The default database values are intended for use with the included PostgreSQL chart, postgresql.enabled=true.  | - |
| spotfire-terrservice | object | - | See [spotfire-terrservice README.md](../spotfire-terrservice/README.md) for configuration options |
| spotfire-terrservice.enabled | bool | `false` | Enable or disable the Spotfire TERR Service component |
| spotfire-webplayer | object | - | See [spotfire-webplayer README.md](../spotfire-webplayer/README.md) for configuration options |
| spotfire-webplayer.enabled | bool | `false` | Enable or disable the Spotfire Web Player component |
| spotfire-automationservices.acceptEUA | bool | `nil` | Accept the [Cloud Software Group, Inc. End User Agreement](https://www.cloud.com/legal/terms) by setting the value to `true`. |
| spotfire-automationservices.affinity | object | `{}` |  |
| spotfire-automationservices.config."Spotfire.Dxp.Worker.Automation.config" | string | `""` | A custom [Spotfire.Dxp.Worker.Automation.config](https://docs.tibco.com/pub/spotfire_server/latest/doc/html/TIB_sfire_server_tsas_admin_help/server/topics/spotfire.dxp.worker.automation.config_file.html). |
| spotfire-automationservices.config."Spotfire.Dxp.Worker.Core.config" | string | `""` | A custom [Spotfire.Dxp.Worker.Core.config](https://docs.tibco.com/pub/spotfire_server/latest/doc/html/TIB_sfire_server_tsas_admin_help/server/topics/spotfire.dxp.worker.core.config_file.html). |
| spotfire-automationservices.config."Spotfire.Dxp.Worker.Host.dll.config" | string | `""` | A custom Spotfire.Dxp.Worker.Host.dll.config. See [Spotfire.Dxp.Worker.Host.exe.config](https://docs.tibco.com/pub/spotfire_server/latest/doc/html/TIB_sfire_server_tsas_admin_help/server/topics/spotfire.dxp.worker.host.exe.config_file.html). |
| spotfire-automationservices.config."Spotfire.Dxp.Worker.Web.config" | string | `""` | A custom [Spotfire.Dxp.Worker.Web.config](https://docs.tibco.com/pub/spotfire_server/latest/doc/html/TIB_sfire_server_tsas_admin_help/server/topics/spotfire.dxp.worker.web.config_file.html). |
| spotfire-automationservices.extraContainers | list | `[]` | Additional sidecar containers to add to the service pod. |
| spotfire-automationservices.extraEnvVars | list | `[]` | Additional environment variables. |
| spotfire-automationservices.extraEnvVarsCM | string | `""` | The name of the ConfigMap containing additional environment variables. |
| spotfire-automationservices.extraEnvVarsSecret | string | `""` | The name of the Secret containing extra additional environment variables. |
| spotfire-automationservices.extraInitContainers | list | `[]` | Additional init containers to add to the service pod. |
| spotfire-automationservices.extraVolumeMounts | list | `[]` | Extra volumeMounts for the service container. More info: `kubectl explain deployment.spec.template.spec.containers.volumeMounts`. |
| spotfire-automationservices.extraVolumes | list | `[]` | Extra volumes for the service container. More info: `kubectl explain deployment.spec.template.spec.volumes`. |
| spotfire-automationservices.fluentBitSidecar.image.pullPolicy | string | `"IfNotPresent"` | The image pull policy for the fluent-bit logging sidecar image. |
| spotfire-automationservices.fluentBitSidecar.image.repository | string | `"fluent/fluent-bit"` | The image repository for fluent-bit logging sidecar. |
| spotfire-automationservices.fluentBitSidecar.image.tag | string | `"3.2.8"` | The image tag to use for fluent-bit logging sidecar. |
| spotfire-automationservices.fluentBitSidecar.securityContext | object | `{}` | The securityContext setting for fluent-bit sidecar container. Overrides any securityContext setting on the Pod level. |
| spotfire-automationservices.fullnameOverride | string | `""` |  |
| spotfire-automationservices.image.pullPolicy | string | `nil` | The spotfire-server image pull policy. Overrides global.spotfire.image.pullPolicy. |
| spotfire-automationservices.image.pullSecrets | list | `[]` | Image pull secrets. |
| spotfire-automationservices.image.registry | string | `nil` | The image registry for spotfire-server. Overrides global.spotfire.image.registry value. |
| spotfire-automationservices.image.repository | string | `"spotfire/spotfire-automationservices"` | The spotfire-server image repository. |
| spotfire-automationservices.image.tag | string | `"14.5.0-v3.0.0"` | The container image tag to use. |
| spotfire-automationservices.kedaAutoscaling | object | `{"advanced":{},"cooldownPeriod":300,"enabled":false,"fallback":{},"maxReplicas":4,"minReplicas":0,"pollingInterval":30,"spotfireConfig":{"prometheusServerAddress":"http://prometheus-server.monitor.svc.cluster.local","spotfireServerHelmRelease":null},"threshold":8,"triggers":[]}` | KEDA autoscaling configuration. See https://keda.sh/docs/latest/concepts/scaling-deployments for more details. |
| spotfire-automationservices.kedaAutoscaling.cooldownPeriod | int | `300` | The period to wait after the last trigger reported active before scaling the resource back to 0. |
| spotfire-automationservices.kedaAutoscaling.maxReplicas | int | `4` | This setting is passed to the HPA definition that KEDA creates for a given resource and holds the maximum number of replicas of the target resource. |
| spotfire-automationservices.kedaAutoscaling.minReplicas | int | `0` | The minimum number of replicas KEDA scales the resource down to. |
| spotfire-automationservices.kedaAutoscaling.pollingInterval | int | `30` | The interval to check each trigger on. |
| spotfire-automationservices.kedaAutoscaling.spotfireConfig | object | `{"prometheusServerAddress":"http://prometheus-server.monitor.svc.cluster.local","spotfireServerHelmRelease":null}` | Spotfire specific settings. |
| spotfire-automationservices.kedaAutoscaling.spotfireConfig.prometheusServerAddress | string | `"http://prometheus-server.monitor.svc.cluster.local"` | REQUIRED. The URL for the Prometheus server from where metrics are fetched. |
| spotfire-automationservices.kedaAutoscaling.spotfireConfig.spotfireServerHelmRelease | string | `nil` | If more than one Spotfire Server release is installed in the same namespace, specify the release to get the correct metrics. |
| spotfire-automationservices.livenessProbe.enabled | bool | `true` |  |
| spotfire-automationservices.livenessProbe.failureThreshold | int | `10` |  |
| spotfire-automationservices.livenessProbe.httpGet.path | string | `"/spotfire/liveness"` |  |
| spotfire-automationservices.livenessProbe.httpGet.port | string | `"registration"` |  |
| spotfire-automationservices.livenessProbe.initialDelaySeconds | int | `60` |  |
| spotfire-automationservices.livenessProbe.periodSeconds | int | `3` |  |
| spotfire-automationservices.logging.logForwarderAddress | string | `""` | The spotfire-server log-forwarder name. Template. |
| spotfire-automationservices.logging.logLevel | string | `"debug"` | Set to `debug`, `trace`, `minimal`, or leave empty for info. This applies to node manager and not the service. |
| spotfire-automationservices.logging.workerhost.logConfiguration | string | `"standard"` | Log configuration for the service. Currently available configs are: `standard`, `minimum`, `info`, `debug`, `monitoring`, `fullmonitoring`, `trace`. |
| spotfire-automationservices.nameOverride | string | `""` |  |
| spotfire-automationservices.nodeSelector | object | `{}` |  |
| spotfire-automationservices.nodemanagerConfig.preStopDrainingTimeoutSeconds | int | `610` | The draining timeout after which the service is forcefully shut down. |
| spotfire-automationservices.nodemanagerConfig.serverBackendAddress | string | `""` | The spotfire-server service name. This value is evaluated as a helm template. |
| spotfire-automationservices.podAnnotations."prometheus.io/path" | string | `"/spotfire/metrics"` |  |
| spotfire-automationservices.podAnnotations."prometheus.io/port" | string | `"9080"` |  |
| spotfire-automationservices.podAnnotations."prometheus.io/scrape" | string | `"true"` |  |
| spotfire-automationservices.podSecurityContext | object | `{}` | The Pod securityContext setting applies to all of the containers inside the Pod. |
| spotfire-automationservices.readinessProbe.enabled | bool | `false` |  |
| spotfire-automationservices.readinessProbe.failureThreshold | int | `10` |  |
| spotfire-automationservices.readinessProbe.httpGet.path | string | `"/spotfire/readiness"` |  |
| spotfire-automationservices.readinessProbe.httpGet.port | string | `"registration"` |  |
| spotfire-automationservices.readinessProbe.initialDelaySeconds | int | `60` |  |
| spotfire-automationservices.readinessProbe.periodSeconds | int | `3` |  |
| spotfire-automationservices.replicaCount | int | `1` |  |
| spotfire-automationservices.resources | object | `{}` |  |
| spotfire-automationservices.securityContext | object | `{}` | The securityContext setting for the service container. Overrides any securityContext setting on the Pod level. |
| spotfire-automationservices.service.port | int | `9501` |  |
| spotfire-automationservices.service.type | string | `"ClusterIP"` |  |
| spotfire-automationservices.serviceAccount.annotations | object | `{}` |  |
| spotfire-automationservices.serviceAccount.create | bool | `false` |  |
| spotfire-automationservices.serviceAccount.name | string | `""` |  |
| spotfire-automationservices.startupProbe.enabled | bool | `true` |  |
| spotfire-automationservices.startupProbe.failureThreshold | int | `20` |  |
| spotfire-automationservices.startupProbe.httpGet.path | string | `"/spotfire/started"` |  |
| spotfire-automationservices.startupProbe.httpGet.port | string | `"registration"` |  |
| spotfire-automationservices.startupProbe.initialDelaySeconds | int | `60` |  |
| spotfire-automationservices.startupProbe.periodSeconds | int | `3` |  |
| spotfire-automationservices.tolerations | list | `[]` |  |
| spotfire-automationservices.volumes.customModules.existingClaim | string | `""` | When 'persistentVolumeClaim.create' is 'false', then use this value to define an already existing persistent volume claim. |
| spotfire-automationservices.volumes.customModules.persistentVolumeClaim.create | bool | `false` | If 'true', then a 'PersistentVolumeClaim' is created. |
| spotfire-automationservices.volumes.customModules.persistentVolumeClaim.resources | object | `{"requests":{"storage":"2Gi"}}` | Specifies the standard Kubernetes resource requests and/or limits for the volumes.customModules claims. |
| spotfire-automationservices.volumes.customModules.persistentVolumeClaim.storageClassName | string | `""` | Specifies the name of the 'StorageClass' to use for the volumes.customModules-claim. |
| spotfire-automationservices.volumes.customModules.persistentVolumeClaim.volumeName | string | `nil` | Specifies the name of the persistent volume to use for the volumes.customModules-claim. |
| spotfire-automationservices.volumes.customModules.subPath | string | `""` | The subPath of the volume to be used for the volume mount |
| spotfire-automationservices.volumes.troubleshooting.existingClaim | string | `""` | When 'persistentVolumeClaim.create' is 'false', then use this value to define an already existing persistent volume claim. |
| spotfire-automationservices.volumes.troubleshooting.persistentVolumeClaim.create | bool | `false` | If 'true', then a 'PersistentVolumeClaim' will be created. |
| spotfire-automationservices.volumes.troubleshooting.persistentVolumeClaim.resources | object | `{"requests":{"storage":"2Gi"}}` | Specifies the standard Kubernetes resource requests and/or limits for the volumes.troubleshooting claims. |
| spotfire-automationservices.volumes.troubleshooting.persistentVolumeClaim.storageClassName | string | `""` | Specifies the name of the 'StorageClass' to use for the volumes.troubleshooting-claim. |
| spotfire-automationservices.volumes.troubleshooting.persistentVolumeClaim.volumeName | string | `nil` | Specifies the name of the persistent volume to use for the volumes.troubleshooting-claim. |
| spotfire-pythonservice.acceptEUA | bool | `nil` | Accept the [Cloud Software Group, Inc. End User Agreement](https://www.cloud.com/legal/terms) by setting the value to `true`. |
| spotfire-pythonservice.affinity | object | `{}` |  |
| spotfire-pythonservice.configuration | object | `{}` | Add [Custom configuration properties](https://docs.tibco.com/pub/sf-pysrv/latest/doc/html/TIB_sf-pysrv_install/_shared/install/topics/custom_configuration_properties.html). Keys under configuration should be named the same as the configuration property, for example 'engine.execution.timeout'. |
| spotfire-pythonservice.extraContainers | list | `[]` | Additional sidecar containers to add to the service pod. |
| spotfire-pythonservice.extraEnvVars | list | `[]` | Additional environment variables. |
| spotfire-pythonservice.extraEnvVarsCM | string | `""` | The name of the ConfigMap containing additional environment variables. |
| spotfire-pythonservice.extraEnvVarsSecret | string | `""` | The name of the Secret containing extra additional environment variables. |
| spotfire-pythonservice.extraInitContainers | list | `[]` | Additional init containers to add to the service pod. |
| spotfire-pythonservice.extraVolumeMounts | list | `[]` | Extra volumeMounts for the service container. More info: `kubectl explain deployment.spec.template.spec.containers.volumeMounts`. |
| spotfire-pythonservice.extraVolumes | list | `[]` | Extra volumes for the service container. More info: `kubectl explain deployment.spec.template.spec.volumes`. |
| spotfire-pythonservice.fluentBitSidecar.image.pullPolicy | string | `"IfNotPresent"` | The image pull policy for the fluent-bit logging sidecar image. |
| spotfire-pythonservice.fluentBitSidecar.image.repository | string | `"fluent/fluent-bit"` | The image repository for fluent-bit logging sidecar. |
| spotfire-pythonservice.fluentBitSidecar.image.tag | string | `"3.2.8"` | The image tag to use for fluent-bit logging sidecar. |
| spotfire-pythonservice.fluentBitSidecar.securityContext | object | `{}` | The securityContext setting for fluent-bit sidecar container. Overrides any securityContext setting on the Pod level. |
| spotfire-pythonservice.fullnameOverride | string | `""` |  |
| spotfire-pythonservice.image.pullPolicy | string | `nil` | The spotfire-server image pull policy. Overrides global.spotfire.image.pullPolicy. |
| spotfire-pythonservice.image.pullSecrets | list | `[]` | Image pull secrets. |
| spotfire-pythonservice.image.registry | string | `nil` | The image registry for spotfire-server. Overrides global.spotfire.image.registry value. |
| spotfire-pythonservice.image.repository | string | `"spotfire/spotfire-pythonservice"` | The spotfire-server image repository. |
| spotfire-pythonservice.image.tag | string | `"1.22.0-v3.0.0"` | The container image tag to use. |
| spotfire-pythonservice.kedaAutoscaling | object | `{"advanced":{},"cooldownPeriod":300,"enabled":false,"fallback":{},"maxReplicas":4,"minReplicas":1,"pollingInterval":30,"spotfireConfig":{"prometheusServerAddress":"http://prometheus-server.monitor.svc.cluster.local"},"threshold":null,"triggers":[]}` | KEDA autoscaling configuration. See https://keda.sh/docs/latest/concepts/scaling-deployments for more details. |
| spotfire-pythonservice.kedaAutoscaling.cooldownPeriod | int | `300` | The period to wait after the last trigger reported active before scaling the resource back to 0. |
| spotfire-pythonservice.kedaAutoscaling.maxReplicas | int | `4` | This setting is passed to the HPA definition that KEDA creates for a given resource and holds the maximum number of replicas of the target resource. |
| spotfire-pythonservice.kedaAutoscaling.minReplicas | int | `1` | The minimum number of replicas KEDA scales the resource down to. |
| spotfire-pythonservice.kedaAutoscaling.pollingInterval | int | `30` | The interval to check each trigger on. |
| spotfire-pythonservice.kedaAutoscaling.spotfireConfig | object | `{"prometheusServerAddress":"http://prometheus-server.monitor.svc.cluster.local"}` | Spotfire specific settings. |
| spotfire-pythonservice.kedaAutoscaling.spotfireConfig.prometheusServerAddress | string | `"http://prometheus-server.monitor.svc.cluster.local"` | REQUIRED. The URL for the Prometheus server from where metrics are fetched. |
| spotfire-pythonservice.livenessProbe.enabled | bool | `true` |  |
| spotfire-pythonservice.livenessProbe.failureThreshold | int | `10` |  |
| spotfire-pythonservice.livenessProbe.httpGet.path | string | `"/spotfire/liveness"` |  |
| spotfire-pythonservice.livenessProbe.httpGet.port | string | `"registration"` |  |
| spotfire-pythonservice.livenessProbe.initialDelaySeconds | int | `60` |  |
| spotfire-pythonservice.livenessProbe.periodSeconds | int | `3` |  |
| spotfire-pythonservice.logging.logForwarderAddress | string | `""` | The spotfire-server log-forwarder name. Template. |
| spotfire-pythonservice.logging.logLevel | string | `"debug"` | Set to `debug`, `trace`, `minimal`, or leave empty for info. This applies for both node manager and the service. |
| spotfire-pythonservice.nameOverride | string | `""` |  |
| spotfire-pythonservice.nodeSelector | object | `{}` |  |
| spotfire-pythonservice.nodemanagerConfig.preStopDrainingTimeoutSeconds | int | `610` | The draining timeout after which the service is forcefully shut down. |
| spotfire-pythonservice.nodemanagerConfig.serverBackendAddress | string | `""` | The spotfire-server service name. This value is evaluated as a helm template. |
| spotfire-pythonservice.podAnnotations."prometheus.io/path" | string | `"/spotfire/metrics"` |  |
| spotfire-pythonservice.podAnnotations."prometheus.io/port" | string | `"9080"` |  |
| spotfire-pythonservice.podAnnotations."prometheus.io/scrape" | string | `"true"` |  |
| spotfire-pythonservice.podSecurityContext | object | `{}` | The Pod securityContext setting applies to all of the containers inside the Pod. |
| spotfire-pythonservice.readinessProbe.enabled | bool | `false` |  |
| spotfire-pythonservice.readinessProbe.failureThreshold | int | `10` |  |
| spotfire-pythonservice.readinessProbe.httpGet.path | string | `"/spotfire/readiness"` |  |
| spotfire-pythonservice.readinessProbe.httpGet.port | string | `"registration"` |  |
| spotfire-pythonservice.readinessProbe.initialDelaySeconds | int | `60` |  |
| spotfire-pythonservice.readinessProbe.periodSeconds | int | `3` |  |
| spotfire-pythonservice.replicaCount | int | `1` |  |
| spotfire-pythonservice.resources | object | `{}` |  |
| spotfire-pythonservice.securityContext | object | `{}` | The securityContext setting for the service container. Overrides any securityContext setting on the Pod level. |
| spotfire-pythonservice.service.port | int | `9501` |  |
| spotfire-pythonservice.service.type | string | `"ClusterIP"` |  |
| spotfire-pythonservice.serviceAccount.annotations | object | `{}` |  |
| spotfire-pythonservice.serviceAccount.create | bool | `false` |  |
| spotfire-pythonservice.serviceAccount.name | string | `""` |  |
| spotfire-pythonservice.startupProbe.enabled | bool | `true` |  |
| spotfire-pythonservice.startupProbe.failureThreshold | int | `20` |  |
| spotfire-pythonservice.startupProbe.httpGet.path | string | `"/spotfire/started"` |  |
| spotfire-pythonservice.startupProbe.httpGet.port | string | `"registration"` |  |
| spotfire-pythonservice.startupProbe.initialDelaySeconds | int | `60` |  |
| spotfire-pythonservice.startupProbe.periodSeconds | int | `3` |  |
| spotfire-pythonservice.tolerations | list | `[]` |  |
| spotfire-pythonservice.volumes.packages.existingClaim | string | `""` | When 'persistentVolumeClaim.create' is 'false', then use this value to define an already existing persistent volume claim. |
| spotfire-pythonservice.volumes.packages.persistentVolumeClaim.create | bool | `false` | If 'true', then a 'PersistentVolumeClaim' is created. |
| spotfire-pythonservice.volumes.packages.persistentVolumeClaim.resources | object | `{"requests":{"storage":"1Gi"}}` | Specifies the standard Kubernetes resource requests and/or limits for the customExt volume claims. |
| spotfire-pythonservice.volumes.packages.persistentVolumeClaim.storageClassName | string | `""` | Specifies the name of the 'StorageClass' to use for the customExt volume-claim. |
| spotfire-pythonservice.volumes.packages.persistentVolumeClaim.volumeName | string | `nil` | Specifies the name of the persistent volume that should be used for the customExt volume-claim. |
| spotfire-pythonservice.volumes.packages.subPath | string | `""` | The subPath of the volume to be used for the volume mount |
| spotfire-pythonservice.volumes.troubleshooting.existingClaim | string | `""` | When 'persistentVolumeClaim.create' is 'false', then use this value to define an already existing persistent volume claim. |
| spotfire-pythonservice.volumes.troubleshooting.persistentVolumeClaim.create | bool | `false` | If 'true', then a 'PersistentVolumeClaim' will be created. |
| spotfire-pythonservice.volumes.troubleshooting.persistentVolumeClaim.resources | object | `{"requests":{"storage":"2Gi"}}` | Specifies the standard Kubernetes resource requests and/or limits for the volumes.troubleshooting claims. |
| spotfire-pythonservice.volumes.troubleshooting.persistentVolumeClaim.storageClassName | string | `""` | Specifies the name of the 'StorageClass' to use for the volumes.troubleshooting-claim. |
| spotfire-pythonservice.volumes.troubleshooting.persistentVolumeClaim.volumeName | string | `nil` | Specifies the name of the persistent volume to use for the volumes.troubleshooting-claim. |
| spotfire-rservice.acceptEUA | bool | `nil` | Accept the [Cloud Software Group, Inc. End User Agreement](https://www.cloud.com/legal/terms) by setting the value to `true`. |
| spotfire-rservice.affinity | object | `{}` |  |
| spotfire-rservice.configuration | object | `{}` | Add [Custom configuration properties](https://docs.tibco.com/pub/sf-rsrv/latest/doc/html/TIB_sf-rsrv_install/_shared/install/topics/custom_configuration_properties.html). Keys under configuration should be named the same as the configuration property, for example 'engine.execution.timeout'. |
| spotfire-rservice.extraContainers | list | `[]` | Additional sidecar containers to add to the service pod. |
| spotfire-rservice.extraEnvVars | list | `[]` | Additional environment variables. |
| spotfire-rservice.extraEnvVarsCM | string | `""` | The name of the ConfigMap containing additional environment variables. |
| spotfire-rservice.extraEnvVarsSecret | string | `""` | The name of the Secret containing extra additional environment variables. |
| spotfire-rservice.extraInitContainers | list | `[]` | Additional init containers to add to the service pod. |
| spotfire-rservice.extraVolumeMounts | list | `[]` | Extra volumeMounts for the service container. More info: `kubectl explain deployment.spec.template.spec.containers.volumeMounts`. |
| spotfire-rservice.extraVolumes | list | `[]` | Extra volumes for the service container. More info: `kubectl explain deployment.spec.template.spec.volumes`. |
| spotfire-rservice.fluentBitSidecar.image.pullPolicy | string | `"IfNotPresent"` | The image pull policy for the fluent-bit logging sidecar image. |
| spotfire-rservice.fluentBitSidecar.image.repository | string | `"fluent/fluent-bit"` | The image repository for fluent-bit logging sidecar. |
| spotfire-rservice.fluentBitSidecar.image.tag | string | `"3.2.8"` | The image tag to use for fluent-bit logging sidecar. |
| spotfire-rservice.fluentBitSidecar.securityContext | object | `{}` | The securityContext setting for fluent-bit sidecar container. Overrides any securityContext setting on the Pod level. |
| spotfire-rservice.fullnameOverride | string | `""` |  |
| spotfire-rservice.image.pullPolicy | string | `nil` | The spotfire-server image pull policy. Overrides global.spotfire.image.pullPolicy. |
| spotfire-rservice.image.pullSecrets | list | `[]` | Image pull secrets. |
| spotfire-rservice.image.registry | string | `nil` | The image registry for spotfire-server. Overrides the global.spotfire.image.registry value. |
| spotfire-rservice.image.repository | string | `"spotfire/spotfire-rservice"` | The spotfire-server image repository. |
| spotfire-rservice.image.tag | string | `"1.22.0-v3.0.0"` | The container image tag to use. |
| spotfire-rservice.kedaAutoscaling | object | `{"advanced":{},"cooldownPeriod":300,"enabled":false,"fallback":{},"maxReplicas":4,"minReplicas":1,"pollingInterval":30,"spotfireConfig":{"prometheusServerAddress":"http://prometheus-server.monitor.svc.cluster.local"},"threshold":null,"triggers":[]}` | KEDA autoscaling configuration. See https://keda.sh/docs/latest/concepts/scaling-deployments/ for more details. |
| spotfire-rservice.kedaAutoscaling.cooldownPeriod | int | `300` | The period to wait after the last trigger reported active before scaling the resource back to 0. |
| spotfire-rservice.kedaAutoscaling.maxReplicas | int | `4` | This setting is passed to the HPA definition that KEDA creates for a given resource and holds the maximum number of replicas of the target resource. |
| spotfire-rservice.kedaAutoscaling.minReplicas | int | `1` | The minimum number of replicas KEDA scales the resource down to. |
| spotfire-rservice.kedaAutoscaling.pollingInterval | int | `30` | The interval to check each trigger on. |
| spotfire-rservice.kedaAutoscaling.spotfireConfig | object | `{"prometheusServerAddress":"http://prometheus-server.monitor.svc.cluster.local"}` | Spotfire specific settings. |
| spotfire-rservice.kedaAutoscaling.spotfireConfig.prometheusServerAddress | string | `"http://prometheus-server.monitor.svc.cluster.local"` | REQUIRED. The URL for the Prometheus server from where metrics are fetched. |
| spotfire-rservice.livenessProbe.enabled | bool | `true` |  |
| spotfire-rservice.livenessProbe.failureThreshold | int | `10` |  |
| spotfire-rservice.livenessProbe.httpGet.path | string | `"/spotfire/liveness"` |  |
| spotfire-rservice.livenessProbe.httpGet.port | string | `"registration"` |  |
| spotfire-rservice.livenessProbe.initialDelaySeconds | int | `60` |  |
| spotfire-rservice.livenessProbe.periodSeconds | int | `3` |  |
| spotfire-rservice.logging.logForwarderAddress | string | `""` | The spotfire-server log-forwarder name. Template. |
| spotfire-rservice.logging.logLevel | string | `"debug"` | Set to `debug`, `trace`, `minimal`, or leave empty for info. This applies for both node manager and the service. |
| spotfire-rservice.nameOverride | string | `""` |  |
| spotfire-rservice.nodeSelector | object | `{}` |  |
| spotfire-rservice.nodemanagerConfig.preStopDrainingTimeoutSeconds | int | `610` | The draining timeout after which the service is forcefully shut down. |
| spotfire-rservice.nodemanagerConfig.serverBackendAddress | string | `""` | The spotfire-server service name. This value is evaluated as a helm template. |
| spotfire-rservice.podAnnotations."prometheus.io/path" | string | `"/spotfire/metrics"` |  |
| spotfire-rservice.podAnnotations."prometheus.io/port" | string | `"9080"` |  |
| spotfire-rservice.podAnnotations."prometheus.io/scrape" | string | `"true"` |  |
| spotfire-rservice.podSecurityContext | object | `{}` | The Pod securityContext setting applies to all of the containers inside the Pod. |
| spotfire-rservice.readinessProbe.enabled | bool | `false` |  |
| spotfire-rservice.readinessProbe.failureThreshold | int | `10` |  |
| spotfire-rservice.readinessProbe.httpGet.path | string | `"/spotfire/readiness"` |  |
| spotfire-rservice.readinessProbe.httpGet.port | string | `"registration"` |  |
| spotfire-rservice.readinessProbe.initialDelaySeconds | int | `60` |  |
| spotfire-rservice.readinessProbe.periodSeconds | int | `3` |  |
| spotfire-rservice.replicaCount | int | `1` |  |
| spotfire-rservice.resources | object | `{}` |  |
| spotfire-rservice.securityContext | object | `{}` | The securityContext setting for the service container. Overrides any securityContext setting on the Pod level. |
| spotfire-rservice.service.port | int | `9501` |  |
| spotfire-rservice.service.type | string | `"ClusterIP"` |  |
| spotfire-rservice.serviceAccount.annotations | object | `{}` |  |
| spotfire-rservice.serviceAccount.create | bool | `false` |  |
| spotfire-rservice.serviceAccount.name | string | `""` |  |
| spotfire-rservice.startupProbe.enabled | bool | `true` |  |
| spotfire-rservice.startupProbe.failureThreshold | int | `20` |  |
| spotfire-rservice.startupProbe.httpGet.path | string | `"/spotfire/started"` |  |
| spotfire-rservice.startupProbe.httpGet.port | string | `"registration"` |  |
| spotfire-rservice.startupProbe.initialDelaySeconds | int | `60` |  |
| spotfire-rservice.startupProbe.periodSeconds | int | `3` |  |
| spotfire-rservice.tolerations | list | `[]` |  |
| spotfire-rservice.volumes.packages.existingClaim | string | `""` | If 'persistentVolumeClaim.create' is 'false' (the default), then use this value to define an already existing persistent volume claim. |
| spotfire-rservice.volumes.packages.persistentVolumeClaim.create | bool | `false` | If 'true', then a 'PersistentVolumeClaim' is created. |
| spotfire-rservice.volumes.packages.persistentVolumeClaim.resources | object | `{"requests":{"storage":"1Gi"}}` | Specifies the standard Kubernetes resource requests and/or limits for the customExt volume claims. |
| spotfire-rservice.volumes.packages.persistentVolumeClaim.storageClassName | string | `""` | Specifies the name of the 'StorageClass' to use for the customExt volume-claim. |
| spotfire-rservice.volumes.packages.persistentVolumeClaim.volumeName | string | `nil` | Specifies the name of the persistent volume to use for the customExt volume-claim. |
| spotfire-rservice.volumes.packages.subPath | string | `""` | The subPath of the volume to use for the volume mount. |
| spotfire-rservice.volumes.troubleshooting.existingClaim | string | `""` | If 'persistentVolumeClaim.create' is 'false' (the default), then use this value to define an already existing persistent volume claim. |
| spotfire-rservice.volumes.troubleshooting.persistentVolumeClaim.create | bool | `false` | If 'true', then a 'PersistentVolumeClaim' is created. |
| spotfire-rservice.volumes.troubleshooting.persistentVolumeClaim.resources | object | `{"requests":{"storage":"2Gi"}}` | Specifies the standard Kubernetes resource requests and/or limits for the volumes.troubleshooting claims. |
| spotfire-rservice.volumes.troubleshooting.persistentVolumeClaim.storageClassName | string | `""` | Specifies the name of the 'StorageClass' to use for the volumes.troubleshooting-claim. |
| spotfire-rservice.volumes.troubleshooting.persistentVolumeClaim.volumeName | string | `nil` | Specifies the name of the persistent volume to use for the volumes.troubleshooting-claim. |
| spotfire-server.acceptEUA | bool | `nil` | Accept the [Cloud Software Group, Inc. End User Agreement](https://www.cloud.com/legal/terms) by setting the value to `true`. |
| spotfire-server.affinity | object | `{}` |  |
| spotfire-server.cliPod.affinity | object | `{}` |  |
| spotfire-server.cliPod.enabled | bool | `true` |  |
| spotfire-server.cliPod.extraEnvVars | list | `[]` | Additional environment variables all spotfire-server pods use.  - name: NAME    value: value |
| spotfire-server.cliPod.extraEnvVarsCM | string | `""` |  |
| spotfire-server.cliPod.extraEnvVarsSecret | string | `""` |  |
| spotfire-server.cliPod.extraInitContainers | list | `[]` | Additional init containers to add to cli pod. More info: `kubectl explain deployment.spec.template.spec.initContainers` |
| spotfire-server.cliPod.extraVolumeMounts | list | `[]` | Extra volumeMounts for the configJob Job. More info: `kubectl explain deployment.spec.template.spec.containers.volumeMounts` |
| spotfire-server.cliPod.extraVolumes | list | `[]` | Extra volumes for the configJob Job. More info: `kubectl explain deployment.spec.template.spec.volumes` |
| spotfire-server.cliPod.image.pullPolicy | string | `nil` | The spotfireConfig image pull policy. Overrides global.spotfire.image.pullPolicy. |
| spotfire-server.cliPod.image.pullSecrets | list | `[]` |  |
| spotfire-server.cliPod.image.registry | string | `nil` | The image registry for spotfireConfig. Overrides global.spotfire.image.registry value. |
| spotfire-server.cliPod.image.repository | string | `"spotfire/spotfire-config"` | The spotfireConfig image repository. |
| spotfire-server.cliPod.image.tag | string | `"14.5.0-v3.0.0"` | The spotfireConfig container image tag to use. |
| spotfire-server.cliPod.logLevel | string | `""` | Set to DEBUG or TRACE to increase log level. Defaults to INFO if unset. |
| spotfire-server.cliPod.nodeSelector | object | `{}` |  |
| spotfire-server.cliPod.podAnnotations | object | `{}` | Podannotations for cliPod |
| spotfire-server.cliPod.podSecurityContext | object | `{}` | The podSecurityContext setting for cliPod More info: `kubectl explain deployment.spec.template.spec.securityContext` |
| spotfire-server.cliPod.securityContext | object | `{}` | The securityContext setting for cliPod. More info: `kubectl explain deployment.spec.template.spec.containers.securityContext` |
| spotfire-server.cliPod.tolerations | list | `[]` |  |
| spotfire-server.configJob.affinity | object | `{}` |  |
| spotfire-server.configJob.extraEnvVars | list | `[]` | Additional environment variables for all spotfire-server pods to use.  - name: NAME    value: value |
| spotfire-server.configJob.extraEnvVarsCM | string | `""` |  |
| spotfire-server.configJob.extraEnvVarsSecret | string | `""` |  |
| spotfire-server.configJob.extraInitContainers | list | `[]` | Additional init containers to add to the Spotfire server configuration pod. More info: `kubectl explain job.spec.template.spec.initContainers` |
| spotfire-server.configJob.extraVolumeMounts | list | `[]` | Extra volumeMounts for the configJob Job. More info: `kubectl explain job.spec.template.spec.containers.volumeMounts` |
| spotfire-server.configJob.extraVolumes | list | `[]` | Extra volumes for the configJob Job. More info: `kubectl explain job.spec.template.spec.volumes` |
| spotfire-server.configJob.image.pullPolicy | string | `nil` | The spotfireConfig image pull policy. Overrides `global.spotfire.image.pullPolicy` value. |
| spotfire-server.configJob.image.pullSecrets | list | `[]` |  |
| spotfire-server.configJob.image.registry | string | `nil` | The image registry for spotfireConfig. Overrides `global.spotfire.image.registry` value. |
| spotfire-server.configJob.image.repository | string | `"spotfire/spotfire-config"` | The spotfireConfig image repository. |
| spotfire-server.configJob.image.tag | string | `"14.5.0-v3.0.0"` | The spotfireConfig container image tag to use. |
| spotfire-server.configJob.logLevel | string | `""` | Set to `DEBUG` or `TRACE` to increase log level. Defaults to `INFO` if unset. |
| spotfire-server.configJob.nodeSelector | object | `{}` |  |
| spotfire-server.configJob.podAnnotations | object | `{}` | Podannotations for configJob |
| spotfire-server.configJob.podSecurityContext | object | `{}` | The podSecurityContext setting for configJob. More info: `kubectl explain job.spec.template.spec.securityContext` |
| spotfire-server.configJob.securityContext | object | `{}` | The securityContext setting for configJob. More info: `kubectl explain job.spec.template.spec.containers.securityContext` |
| spotfire-server.configJob.tolerations | list | `[]` |  |
| spotfire-server.configJob.ttlSecondsAfterFinished | int | `7200` | Set the length of time in seconds to keep job and its logs until the job is removed. |
| spotfire-server.configuration.actionLog | object | File logging enabled, database logging disabled. | Action log settings. See [config-action-logger](https://docs.tibco.com/pub/spotfire_server/latest/doc/html/TIB_sfire_server_tsas_admin_help/server/topics/config-action-logger.html) for more information. |
| spotfire-server.configuration.actionLog.categories | string | `""` | Action log categories and webCategories are a comma separated list of categories. See [config-action-logger](https://docs.tibco.com/pub/spotfire_server/latest/doc/html/TIB_sfire_server_tsas_admin_help/server/topics/action_log_categories.html) for a list of possible categories. default value when empty is "all" |
| spotfire-server.configuration.actionLog.database.config-action-log-database-logger | object | Configuration of actionlog database settings is only applicable if configuration.actionLog.enabled is true | Configure actionlog database. See [config-action-log-database-logger](https://docs.tibco.com/pub/spotfire_server/latest/doc/html/TIB_sfire_server_tsas_admin_help/server/topics/config-action-log-database-logger.html) for more information. |
| spotfire-server.configuration.actionLog.database.config-action-log-database-logger.additionalOptions | object | `{}` | Additional Options. See [config-action-log-database-logger - Options](https://docs.tibco.com/pub/spotfire_server/latest/doc/html/TIB_sfire_server_tsas_admin_help/server/topics/config-action-log-database-logger.html) for more information. |
| spotfire-server.configuration.actionLog.database.config-action-log-database-logger.password | string | `""` | The password to be created for the Spotfire Actionlog database user. If not provided, this password is automatically generated. |
| spotfire-server.configuration.actionLog.database.config-action-log-database-logger.username | string | `"spotfire_actionlog"` | The user to create for actionlog database access |
| spotfire-server.configuration.actionLog.database.create-actionlogdb | object | Actionlog database is created only if configuration.actionLog.enabled is true | Create the actionlog database. See [create-actionlogdb](https://docs.tibco.com/pub/spotfire_server/latest/doc/html/TIB_sfire_server_tsas_admin_help/server/topics/create-actionlogdb.html) for more information. |
| spotfire-server.configuration.actionLog.database.create-actionlogdb.actiondbDbname | string | `"spotfire_actionlog"` | Name for the Actionlog Database to be created to hold the Actionlog database table. |
| spotfire-server.configuration.actionLog.database.create-actionlogdb.adminPassword | string | `""` | Admin password for the actionlog database. |
| spotfire-server.configuration.actionLog.database.create-actionlogdb.adminPasswordExistingSecret | object | Not used unless .name is set | Read spotfire actionlog database password from an existing secret. If set, 'adminPassword' above is not used. |
| spotfire-server.configuration.actionLog.database.create-actionlogdb.adminUsername | string | `"postgres"` | Admin username for the actionlog database. |
| spotfire-server.configuration.actionLog.database.create-actionlogdb.databaseUrl | string | `"jdbc:postgresql://HOSTNAME/"` | Like `configuration.actionLog.database.config-action-log-database-logger.databaseUrl` but is used for the connection when creating the actionlog database. Evaluated as a template. |
| spotfire-server.configuration.actionLog.database.create-actionlogdb.doNotCreateUser | bool | `false` | Set this to true, in case supported databases (AWS Postgres, Aurora Postgres, Azure Postgres, Google Cloud Postgres) does not allow user creation or the actionlog records are being stored on the spotfire database. |
| spotfire-server.configuration.actionLog.database.create-actionlogdb.enabled | bool | `true` | if enabled is true, create the actionlog database |
| spotfire-server.configuration.actionLog.database.create-actionlogdb.oracleRootfolder | string | `""` | Specify the value in case of Oracle database, otherwise keep it blank. |
| spotfire-server.configuration.actionLog.database.create-actionlogdb.timeoutSeconds | string | `""` | Specifies the timeout, in seconds, for the operation. |
| spotfire-server.configuration.actionLog.database.create-actionlogdb.variant | string | `""` | For connecting to MS SQL or Oracle on Amazon RDS, specify `rds`, for MS SQL on Azure, specify `azure`, otherwise omit the option. |
| spotfire-server.configuration.apply | string | `"initialsetup"` | When to apply configurationScripts, commandScripts, admin user creation and action log settings. Possible values: * "always" = Apply on every `helm install` or `helm upgrade`. Note: Configuration made from other tools than helm might be overwritten when updating the helm release. * "initialsetup" = Only apply if Spotfire server database does not already have a configuration. It is suitable for setting up the initial configuration of the environment but where further configuration is done using the spotfire configuration tool. * "never" = Do not apply. Configuration must be configured using the spotfire configuration tool directly towards the database. |
| spotfire-server.configuration.commandScripts | list | `[]` | A list of command scripts to run during helm installation. These commands will run once only and not subsequent helm release upgrades. Each list item should have the keys `name` and `script`. See [config.sh run script](https://docs.tibco.com/pub/spotfire_server/latest/doc/html/TIB_sfire_server_tsas_admin_help/server/topics/scripting_a_configuration.html). Commands in these scripts should NOT operate on `configuration.xml`. Operations such as adding/removing users and assigning licenses are typical administrative commands that can be specified here. |
| spotfire-server.configuration.configurationScripts | list | `[]` | A list of configuration scripts to apply during helm installation. Each list item should have the keys `name` and `script`. See [config.sh run script](https://docs.tibco.com/pub/spotfire_server/latest/doc/html/TIB_sfire_server_tsas_admin_help/server/topics/scripting_a_configuration.html). Commands in these scripts should operate only on a local `configuration.xml`. Commands such as `set-config-prop` and `modify-ds-template` are examples of commands that can be used here. The local `configuration.xml` file is automatically imported after all configuration steps run in the order in which they are defined below. |
| spotfire-server.configuration.deployment.clear | bool | `false` | Clear existing packages before any new files are added. Setting it `true` can cause extra delay because packages need to be added again every time the config-job is run. |
| spotfire-server.configuration.deployment.defaultDeployment.deploymentAreaName | string | `"Production"` | The name of the deployment area to create or update |
| spotfire-server.configuration.deployment.defaultDeployment.enabled | bool | `true` | Create deployment area with default Spotfire.Dxp.sdn taken from spotfire-deployment image. *Warning*: If set to `true` and a deployment volume (see `volumes.deployments` key) is used, a folder with name `deploymentAreaName` will be created and potentially overwrite any existing deployment with the same name on the persistent volume. |
| spotfire-server.configuration.deployment.defaultDeployment.image.pullPolicy | string | `nil` | The spotfire-deployment image pull policy. Overrides `global.spotfire.image.pullPolicy`. |
| spotfire-server.configuration.deployment.defaultDeployment.image.pullSecrets | list | `[]` |  |
| spotfire-server.configuration.deployment.defaultDeployment.image.registry | string | `nil` | The image registry for spotfire-deployment. Overrides `global.spotfire.image.registry` value. |
| spotfire-server.configuration.deployment.defaultDeployment.image.repository | string | `"spotfire/spotfire-deployment"` | The spotfire-deployment image repository. |
| spotfire-server.configuration.deployment.defaultDeployment.image.tag | string | `"14.5.0-v3.0.0"` | The container image tag to use. |
| spotfire-server.configuration.deployment.enabled | bool | `true` | When enabled spotfire deployment areas will be created by the configuration job. See also `volumes.deployment`. |
| spotfire-server.configuration.draining | object | `{"enabled":true,"minimumSeconds":90,"publishNotReadyAddresses":true,"timeoutSeconds":180}` | Configuration of the Spotfire Server container lifecycle PreStop hook. |
| spotfire-server.configuration.draining.enabled | bool | `true` | Enables or disables the container lifecycle PreStop hook. |
| spotfire-server.configuration.draining.minimumSeconds | int | `90` | The minimum time in seconds that the server should be draining, even if it is considered idle. |
| spotfire-server.configuration.draining.publishNotReadyAddresses | bool | `true` | Makes sure that service SRV records are preserved while terminating pods, typically used with the spotfire haproxy deployment. |
| spotfire-server.configuration.draining.timeoutSeconds | int | `180` | The draining timeout in seconds after which the service is forcibly shut down. |
| spotfire-server.configuration.encryptionPassword | string | `""` | The password for encrypting passwords that are stored in the database. If you do not set this option, then a static password is used. See \-\-encryption-password for the [bootstrap](https://docs.tibco.com/pub/spotfire_server/latest/doc/html/TIB_sfire_server_tsas_admin_help/server/topics/bootstrap.html) command. |
| spotfire-server.configuration.preConfigCommandScripts | list | `[]` | The same as `commandScripts` but these command will be run before the configuration is imported. On new installations the commands will be run before any spotfire servers are started, because spotfire server will not start before there is a configuration. |
| spotfire-server.configuration.preferExistingConfig | bool | `false` | Run the configuration job steps starting from the currently active configuration or from the Spotfire default config (created with `config.sh create-default-config`). If no current active configuration exists, the default config is used. Note: When set to false, all configuration done with external tools other than helm will be overwritten on an upgrade. |
| spotfire-server.configuration.properties | object | Default values for kubernetes, see values.yaml. | Configuration properties The key name is the name of the property to set. If the value is a scalar the configuration tool command `set-config-prop` is used. To set a list or map the value should have the keys `itemName` and `value`. If the value is a map or object the configuration tool command `set-config-map-prop` is used. If the value is a list the configuration tool command `set-config-list-prop` is used. |
| spotfire-server.configuration.site | object | Spotfire Server joins the Default site. | Site settings. See [sites](https://docs.tibco.com/pub/spotfire_server/latest/doc/html/TIB_sfire_server_tsas_admin_help/server/topics/sites.html) for more information. |
| spotfire-server.configuration.site.name | string | `"Default"` | The name of the site that the Spotfire Server should belong to. The site must be created beforehand. See [create-site](https://docs.tibco.com/pub/spotfire_server/latest/doc/html/TIB_sfire_server_tsas_admin_help/server/topics/create-site.html) for more information. |
| spotfire-server.configuration.site.publicAddress | string | `""` | The address that clients use for connecting to the system. It is also used for generating absolute URLs. |
| spotfire-server.configuration.spotfireAdmin.create | bool | `true` | Whether to create an admin user or not. |
| spotfire-server.configuration.spotfireAdmin.password | string | `""` | The password to create for the Spotfire admin. If not provided, this password is automatically generated. Although possible, it is not recommended to change the user's password directly in the Spotfire administrative user interface because the password is reset to this value on every helm installation or upgrade. |
| spotfire-server.configuration.spotfireAdmin.passwordExistingSecret | object | Not used unless .name is set | Read password from an existing secret instead of from values. If set, 'password' above is not used. |
| spotfire-server.configuration.spotfireAdmin.username | string | `"admin"` | The user to create for the Spotfire admin. |
| spotfire-server.database.bootstrap | object | - | For details related to bootstrap properties, visit the product documentation [here](https://docs.tibco.com/pub/spotfire_server/latest/doc/html/TIB_sfire_server_tsas_admin_help/server/topics/bootstrap.html). |
| spotfire-server.database.bootstrap.databaseUrl | string | `"jdbc:postgresql://HOSTNAME/spotfire"` | The JDBC URL of the database to be used by Spotfire Server. Evaluated as a template. |
| spotfire-server.database.bootstrap.password | string | `""` | Password to be created for the Spotfire Server database. If not provided, this password is automatically generated. |
| spotfire-server.database.bootstrap.passwordExistingSecret | object | Not used unless .name is set | Read spotfire database password from an existing secret. If set, 'password' above is not used. |
| spotfire-server.database.bootstrap.username | string | `"spotfire"` | Username to be created for the Spotfire Server database. If unset, the default value `spotfire` is used. |
| spotfire-server.database.create-db | object | - | For details related to `create-db` cli properties, visit the product documentation [here](https://docs.tibco.com/pub/spotfire_server/latest/doc/html/TIB_sfire_server_tsas_admin_help/server/topics/create-db.html). create-db cli also uses properties from database.bootstrap section. |
| spotfire-server.database.create-db.adminPassword | string | `""` | Admin password for the database server to be used as the Spotfire Server database. |
| spotfire-server.database.create-db.adminPasswordExistingSecret | object | Not used unless .name is set | Read admin password from an existing secret. If set, 'password' above is not used. |
| spotfire-server.database.create-db.adminUsername | string | `"postgres"` | Admin username for the database server to be used as the Spotfire Server database. |
| spotfire-server.database.create-db.databaseUrl | string | `"jdbc:postgresql://HOSTNAME/"` | Like `database.bootstrap.databaseUrl` but is used for the connection when creating the spotfire database. Evaluated as a template. |
| spotfire-server.database.create-db.doNotCreateUser | bool | `false` | Set this to true, in case supported databases (AWS Postgres, Aurora Postgres, Azure Postgres, Google Cloud Postgres) does not allow user creation |
| spotfire-server.database.create-db.enabled | bool | `true` | if set to true, Spotfire server schema will also get deployed with other installation. |
| spotfire-server.database.create-db.oracleRootfolder | string | `""` | Specify the value in case of Oracle database, otherwise keep it blank. |
| spotfire-server.database.create-db.oracleTablespacePrefix | string | `""` | Specify the value in case of Oracle database, otherwise keep it blank. |
| spotfire-server.database.create-db.spotfiredbDbname | string | `"spotfire"` | Database name to be created to hold the Spotfire Server database schemas. |
| spotfire-server.database.create-db.variant | string | `""` | For connecting to MS SQL or Oracle on Amazon RDS, specify `rds`, for MS SQL on Azure, specify `azure`, otherwise omit the option. |
| spotfire-server.database.upgrade | bool | `false` | Often new Spotfire server version requires an upgraded database. If true, the database will be upgrade to match the server version being deployed. |
| spotfire-server.extraContainers | list | `[]` | Additional sidecar containers to add to the Spotfire server pod. More info: `kubectl explain deployment.spec.template.spec.containers` |
| spotfire-server.extraEnvVars | list | `[]` | Additional environment variables that all spotfire-server pods use. |
| spotfire-server.extraEnvVarsCM | string | `""` |  |
| spotfire-server.extraEnvVarsSecret | string | `""` |  |
| spotfire-server.extraInitContainers | list | `[]` | Additional init containers to add to Spotfire server pod. More info: `kubectl explain deployment.spec.template.spec.initContainers` |
| spotfire-server.extraVolumeMounts | list | `[]` | Extra volumeMounts for the spotfire-server container. More info: `kubectl explain deployment.spec.template.spec.containers.volumeMounts` |
| spotfire-server.extraVolumes | list | `[]` | Extra volumes for the spotfire-server container. More info: `kubectl explain deployment.spec.template.spec.volumes` |
| spotfire-server.fluentBitSidecar.image.pullPolicy | string | `"IfNotPresent"` | The image pull policy for the fluent-bit logging sidecar image. |
| spotfire-server.fluentBitSidecar.image.repository | string | `"fluent/fluent-bit"` | The image repository for fluent-bit logging sidecar. |
| spotfire-server.fluentBitSidecar.image.tag | string | `"3.2.8"` | The image tag to use for fluent-bit logging sidecar. |
| spotfire-server.fluentBitSidecar.securityContext | object | `{}` | The securityContext setting for fluent-bit sidecar container. Overrides any securityContext setting on the Pod level. More info: `kubectl explain pod.spec.securityContext` |
| spotfire-server.haproxy.config | string | The chart creates a configuration automatically. | The haproxy configuration file template. For implementation details see templates/haproxy-config.tpl. |
| spotfire-server.haproxy.enabled | bool | `true` |  |
| spotfire-server.haproxy.includes | object | `{}` |  |
| spotfire-server.haproxy.includesMountPath | string | `"/etc/haproxy/includes"` |  |
| spotfire-server.haproxy.kind | string | `"Deployment"` |  |
| spotfire-server.haproxy.podAnnotations | object | `{"prometheus.io/path":"/metrics","prometheus.io/port":"1024","prometheus.io/scrape":"true"}` | Prometheus annotations. Should match the haproxy.config settings. |
| spotfire-server.haproxy.podLabels."app.kubernetes.io/component" | string | `"haproxy"` |  |
| spotfire-server.haproxy.podLabels."app.kubernetes.io/part-of" | string | `"spotfire"` |  |
| spotfire-server.haproxy.podSecurityPolicy.create | bool | `false` |  |
| spotfire-server.haproxy.service.type | string | `"ClusterIP"` | Sets the service haproxy service proxies traffic to the spotfire-server service. ClusterIP or LoadBalancer. |
| spotfire-server.haproxy.spotfireConfig | object | Caching of static resource and debug response headers enabled. | Spotfire specific configuration related to haproxy. |
| spotfire-server.haproxy.spotfireConfig.agent.port | int | `9081` | Spotfire Server haproxy agent-port. |
| spotfire-server.haproxy.spotfireConfig.cache | object | enabled | Caching of static resources |
| spotfire-server.haproxy.spotfireConfig.captures.forwardedForLength | int | `36` | The maximum number of characters captured from the X-Forwarded-For request header |
| spotfire-server.haproxy.spotfireConfig.cleanup.sameSiteCookieAttributeForHttp | bool | `true` | If the SameSite cookie attribute should be removed for HTTP connections in Set-Cookie response headers, then it might be needed in cases where both HTTP and HTTPS are enabled, and upstream servers set this unconditionally. |
| spotfire-server.haproxy.spotfireConfig.cleanup.secureCookieAttributeForHttp | bool | `true` | If incorrect, then the secure cookie attribute should be removed for HTTP connections in the Set-Cookie response headers. |
| spotfire-server.haproxy.spotfireConfig.debug | bool | `false` | Specifies if debug response headers should be enabled. |
| spotfire-server.haproxy.spotfireConfig.haproxy | object | additional settings | Additional settings for various settings in the default spotfire haproxy configuration. |
| spotfire-server.haproxy.spotfireConfig.haproxy.defaults | string | `nil` | The haproxy defaults section. See [haproxy proxies](https://docs.haproxy.org/3.0/configuration.html#4). |
| spotfire-server.haproxy.spotfireConfig.haproxy.frontend | string | `nil` | The haproxy spotfire frontend section. See [haproxy proxies](https://docs.haproxy.org/3.0/configuration.html#4). |
| spotfire-server.haproxy.spotfireConfig.haproxy.global | string | `nil` | The haproxy global section. See [haproxy global](https://docs.haproxy.org/3.0/configuration.html#3). |
| spotfire-server.haproxy.spotfireConfig.haproxy.stats | string | `nil` | The haproxy metrics and status frontend section. See [haproxy proxies](https://docs.haproxy.org/3.0/configuration.html#4). |
| spotfire-server.haproxy.spotfireConfig.loadBalancingCookie | object | stateless load balancing | Cookie-related configuration. |
| spotfire-server.haproxy.spotfireConfig.loadBalancingCookie.attributes | string | `"insert indirect nocache dynamic httponly secure attr \"SameSite=None\""` | Attributes for the cookie value in the haproxy config. See [haproxy cookie](https://cbonte.github.io/haproxy-dconv/2.6/configuration.html#4.2-cookie) for more information. |
| spotfire-server.haproxy.spotfireConfig.loadBalancingCookie.dynamicCookieKey | string | the cookie key | dynamic-cookie-key value in the haproxy config. |
| spotfire-server.haproxy.spotfireConfig.maintenance | object | disabled | Maintenance mode, can be used to temporarily block requests (but still allow some, see allowCookie below). |
| spotfire-server.haproxy.spotfireConfig.maintenance.allowCookie | object | disabled | Allowed requests in maintenance mode by configuring a cookie for allowed requests. |
| spotfire-server.haproxy.spotfireConfig.maintenance.allowCookie.enabled | bool | `false` | Specifies if a cookie can be used to access the environment while maintenance mode is enabled. |
| spotfire-server.haproxy.spotfireConfig.maintenance.allowCookie.name | string | `""` | The name of the cookie, case sensitive |
| spotfire-server.haproxy.spotfireConfig.maintenance.allowCookie.value | string | `""` | The value of the cookie, case sensitive |
| spotfire-server.haproxy.spotfireConfig.maintenance.enabled | bool | `false` | Specifies if maintenance mode is enabled. |
| spotfire-server.haproxy.spotfireConfig.maintenancePage | object | maintenance page related settings | A custom maintenance page that is displayed if maintenance mode is enabled or if no Spotfire Server instances are running |
| spotfire-server.haproxy.spotfireConfig.maintenancePage.bufSize | int | `24576` | For larger files, haproxy tune.bufsize may need to be increased to accommodate the larger size. |
| spotfire-server.haproxy.spotfireConfig.maintenancePage.responseString | string | `"<html><title>Maintenance - </title><body>Maintenance in progress</body></html>"` | The maintenance page response string. |
| spotfire-server.haproxy.spotfireConfig.maintenancePage.useFile | bool | `false` | If a haproxy include file,  haproxy.includes.'maintenance\\.html'=<path to file>, should be used instead of haproxy.maintenancePage.responseString below. |
| spotfire-server.haproxy.spotfireConfig.serverTemplate.additionalParams | string | `"on-marked-down shutdown-sessions"` | Additional parameters, see [haproxy server](https://cbonte.github.io/haproxy-dconv/2.6/snapshot/configuration.html#server%20%28Alphabetically%20sorted%20keywords%20reference%29) |
| spotfire-server.haproxy.spotfireConfig.timeouts.client | string | `"30m"` | See [haproxy timeout client](https://cbonte.github.io/haproxy-dconv/2.6/configuration.html#4.2-timeout%20client). |
| spotfire-server.haproxy.spotfireConfig.timeouts.connect | string | `"300ms"` | See [haproxy timeout connect](https://cbonte.github.io/haproxy-dconv/2.6/configuration.html#4.2-timeout%20connect). |
| spotfire-server.haproxy.spotfireConfig.timeouts.httpRequest | string | `"3600s"` | See [haproxy timeout http-request](https://cbonte.github.io/haproxy-dconv/2.6/configuration.html#4.2-timeout%20http-request). |
| spotfire-server.haproxy.spotfireConfig.timeouts.queue | string | `"60s"` | See [haproxy timeout queue](https://cbonte.github.io/haproxy-dconv/2.6/configuration.html#4-timeout%20queue). |
| spotfire-server.haproxy.spotfireConfig.timeouts.server | string | `"30m"` | See [haproxy timeout server](https://cbonte.github.io/haproxy-dconv/2.6/configuration.html#4.2-timeout%20server). |
| spotfire-server.haproxy.spotfireConfig.timeouts.tunnel | string | `"31m"` | See [haproxy timeout tunnel](https://cbonte.github.io/haproxy-dconv/2.6/configuration.html#4.2-timeout%20tunnel). |
| spotfire-server.image.pullPolicy | string | `nil` | The spotfire-server image pull policy. Overrides `global.spotfire.image.pullPolicy`. |
| spotfire-server.image.pullSecrets | list | `[]` | spotfire-deployment image pull secrets. |
| spotfire-server.image.registry | string | `nil` | The image registry for spotfire-server. Overrides `global.spotfire.image.registry` value. |
| spotfire-server.image.repository | string | `"spotfire/spotfire-server"` | The spotfire-server image repository. |
| spotfire-server.image.tag | string | `"14.5.0-v3.0.0"` | The container image tag to use. |
| spotfire-server.ingress.annotations | object | `{}` | Annotations for the ingress object. See documentation for your ingress controller for valid annotations. |
| spotfire-server.ingress.enabled | bool | `false` | Enables configuration of ingress to expose Spotfire Server. Requires ingress support in the Kubernetes cluster. |
| spotfire-server.ingress.hosts[0].host | string | `"spotfire.local"` |  |
| spotfire-server.ingress.hosts[0].paths[0].path | string | `"/"` |  |
| spotfire-server.ingress.hosts[0].paths[0].pathType | string | `"Prefix"` |  |
| spotfire-server.ingress.ingressClassName | string | `""` | IngressClass that will be be used for the Ingress (Kubernetes 1.18+) ref: https://kubernetes.io/blog/2020/04/02/improvements-to-the-ingress-api-in-kubernetes-1.18/ |
| spotfire-server.ingress.tls | list | `[]` |  |
| spotfire-server.kedaAutoscaling | object | Disabled | KEDA autoscaling configuration. See https://keda.sh/docs/latest/concepts/scaling-deployments for more details. |
| spotfire-server.kedaAutoscaling.cooldownPeriod | int | `300` | The period to wait after the last trigger reported active before scaling the resource back to 0. |
| spotfire-server.kedaAutoscaling.maxReplicas | int | `4` | This setting is passed to the HPA definition that KEDA creates for a given resource and holds the maximum number of replicas of the target resource. |
| spotfire-server.kedaAutoscaling.minReplicas | int | `1` | The minimum number of replicas KEDA scales the resource down to. |
| spotfire-server.kedaAutoscaling.pollingInterval | int | `30` | The interval to check each trigger on. |
| spotfire-server.kedaAutoscaling.spotfireConfig | object | `{"prometheusServerAddress":"http://prometheus-server.monitor.svc.cluster.local"}` | Spotfire specific settings. |
| spotfire-server.kedaAutoscaling.spotfireConfig.prometheusServerAddress | string | `"http://prometheus-server.monitor.svc.cluster.local"` | REQUIRED. The URL to the Prometheus server where metrics should be fetched from. |
| spotfire-server.livenessProbe.enabled | bool | `true` |  |
| spotfire-server.livenessProbe.failureThreshold | int | `3` |  |
| spotfire-server.livenessProbe.httpGet.path | string | `"/spotfire/rest/status/getStatus"` |  |
| spotfire-server.livenessProbe.httpGet.port | string | `"http"` |  |
| spotfire-server.livenessProbe.periodSeconds | int | `3` |  |
| spotfire-server.log-forwarder.config.filters | string | Example that drops specific events using [grep](https://docs.fluentbit.io/manual/pipeline/filters/grep) | Add custom fluent-bit [filters configuration](https://docs.fluentbit.io/manual/pipeline/filters). |
| spotfire-server.log-forwarder.config.inputs | string | [tcp input](https://docs.fluentbit.io/manual/pipeline/inputs/tcp) on port 5170 and [forward input](https://docs.fluentbit.io/manual/pipeline/inputs/forward) on port 24224 | fluent-bit [input configuration](https://docs.fluentbit.io/manual/pipeline/inputs). |
| spotfire-server.log-forwarder.config.outputs | string | Logs are written to stdout of the log-forwarder pod. | Override this value with an [output configuration](https://docs.fluentbit.io/manual/pipeline/outputs) to send logs to an external system. |
| spotfire-server.log-forwarder.enabled | bool | `true` | enables or disables the fluent-bit log-forwarder pod. If enabled, it collects logs from the spotfire-server pods and can forward traffic to any output supported by fluent-bit. |
| spotfire-server.log-forwarder.extraPorts[0].containerPort | int | `5170` |  |
| spotfire-server.log-forwarder.extraPorts[0].name | string | `"json"` |  |
| spotfire-server.log-forwarder.extraPorts[0].port | int | `5170` |  |
| spotfire-server.log-forwarder.extraPorts[0].protocol | string | `"TCP"` |  |
| spotfire-server.log-forwarder.extraPorts[1].containerPort | int | `24224` |  |
| spotfire-server.log-forwarder.extraPorts[1].name | string | `"forward"` |  |
| spotfire-server.log-forwarder.extraPorts[1].port | int | `24224` |  |
| spotfire-server.log-forwarder.extraPorts[1].protocol | string | `"TCP"` |  |
| spotfire-server.log-forwarder.image.pullPolicy | string | `"IfNotPresent"` |  |
| spotfire-server.log-forwarder.kind | string | `"Deployment"` |  |
| spotfire-server.log-forwarder.labels."app.kubernetes.io/component" | string | `"logging"` |  |
| spotfire-server.log-forwarder.labels."app.kubernetes.io/part-of" | string | `"spotfire"` |  |
| spotfire-server.log-forwarder.podAnnotations."prometheus.io/path" | string | `"/api/v1/metrics/prometheus"` |  |
| spotfire-server.log-forwarder.podAnnotations."prometheus.io/port" | string | `"2020"` |  |
| spotfire-server.log-forwarder.podAnnotations."prometheus.io/scrape" | string | `"true"` |  |
| spotfire-server.log-forwarder.podLabels."app.kubernetes.io/component" | string | `"logging"` |  |
| spotfire-server.log-forwarder.podLabels."app.kubernetes.io/part-of" | string | `"spotfire"` |  |
| spotfire-server.log-forwarder.rbac.create | bool | `false` | Specifies whether to create an RBAC for the fluent-bit / log-forwarder. Setting this to `true` requires additional privileges in the Kubernetes cluster. |
| spotfire-server.log-forwarder.service.labels."app.kubernetes.io/component" | string | `"logging"` |  |
| spotfire-server.log-forwarder.service.labels."app.kubernetes.io/part-of" | string | `"spotfire"` |  |
| spotfire-server.logging.logForwarderAddress | string | `""` | Specifies a logForwarderAddress. If left empty, then the default `log-forwarder` is used in the case where `log-forwarder.enabled=true`. Template. |
| spotfire-server.logging.logLevel | string | `""` | The Spotfire Server log-level. Set to `debug`, `trace`, `minimal` or leave empty for info. |
| spotfire-server.nodeSelector | object | `{}` |  |
| spotfire-server.podAnnotations."prometheus.io/path" | string | `"/spotfire/metrics"` |  |
| spotfire-server.podAnnotations."prometheus.io/port" | string | `"9080"` |  |
| spotfire-server.podAnnotations."prometheus.io/scrape" | string | `"true"` |  |
| spotfire-server.podSecurityContext | object | `{}` | The Pod securityContext setting applies to all the containers inside the Pod. More info: `kubectl explain deployment.spec.template.spec.securityContext` |
| spotfire-server.readinessProbe.enabled | bool | `false` |  |
| spotfire-server.replicaCount | int | `1` | The number of Spotfire Server containers. |
| spotfire-server.resources | object | `{}` |  |
| spotfire-server.securityContext | object | `{}` | The securityContext setting for spotfire-server container. Overrides any securityContext setting on the Pod level. More info: `kubectl explain deployment.spec.template.spec.containers.securityContext` |
| spotfire-server.service.clusterIP | string | `"None"` |  |
| spotfire-server.service.type | string | `"ClusterIP"` |  |
| spotfire-server.serviceAccount.annotations | object | `{}` |  |
| spotfire-server.serviceAccount.create | bool | `true` |  |
| spotfire-server.serviceAccount.name | string | `""` |  |
| spotfire-server.spotfireServerJava.extraJavaOpts | list | `[]` | Additional `JAVA_OPTS` for spotfire-server pods. |
| spotfire-server.startupProbe.enabled | bool | `true` |  |
| spotfire-server.startupProbe.failureThreshold | int | `30` |  |
| spotfire-server.startupProbe.httpGet.path | string | `"/spotfire/rest/status/getStatus"` |  |
| spotfire-server.startupProbe.httpGet.port | string | `"http"` |  |
| spotfire-server.startupProbe.initialDelaySeconds | int | `60` |  |
| spotfire-server.startupProbe.periodSeconds | int | `10` |  |
| spotfire-server.tolerations | list | `[]` |  |
| spotfire-server.toolPassword | string | `""` | The Spotfire config tool password to use for `bootstrap.xml`. If not provided, this password is automatically generated. The password is only used locally inside pods for use to together with the configuration and is not usable for anything outside the pod. |
| spotfire-server.troubleshooting.jvm.heapDumpOnOutOfMemoryError.dumpPath | string | `"/opt/spotfire/troubleshooting/jvm-heap-dumps"` | Define a path where the generated dump is exported. By default, this gets mounted in EmptyDir: {} internally, which survives container restarts. In case you want to persist troubleshooting information to an external location, you can override the default behaviour by specifying PVC in `volumes.troubleshooting`. |
| spotfire-server.troubleshooting.jvm.heapDumpOnOutOfMemoryError.enabled | bool | `true` | Enable or disable for a heap dump in case of OutOfMemoryError. |
| spotfire-server.volumes.certificates.existingClaim | string | `""` |  |
| spotfire-server.volumes.certificates.subPath | string | `""` | The subPath of the volume to be used for the volume mount |
| spotfire-server.volumes.customExt.existingClaim | string | `""` | Defines an already-existing persistent volume claim. |
| spotfire-server.volumes.customExt.subPath | string | `""` | The subPath of the volume to be used for the volume mount |
| spotfire-server.volumes.customExtInformationservices.existingClaim | string | `""` | Defines an already-existing persistent volume claim. |
| spotfire-server.volumes.customExtInformationservices.subPath | string | `""` | The subPath of the volume to be used for the volume mount |
| spotfire-server.volumes.deployments.existingClaim | string | `""` | Defines an already-existing persistent volume claim. |
| spotfire-server.volumes.deployments.subPath | string | `""` | The subPath of the volume to be used for the volume mount |
| spotfire-server.volumes.libraryImportExport.existingClaim | string | `""` | When `persistentVolumeClaim.create` is `false`, then this value is used to define an already-existing PVC. |
| spotfire-server.volumes.libraryImportExport.persistentVolumeClaim.create | bool | `false` | If `true`, then a `PersistentVolumeClaim` (PVC) is created. |
| spotfire-server.volumes.libraryImportExport.persistentVolumeClaim.resources | object | `{"requests":{"storage":"1Gi"}}` | Specifies the standard Kubernetes resource requests and/or limits for the `volumes.libraryImportExport` PVC. |
| spotfire-server.volumes.libraryImportExport.persistentVolumeClaim.storageClassName | string | `""` | Specifies the name of the `StorageClass` to use for the `volumes.libraryImportExport` PVC. |
| spotfire-server.volumes.libraryImportExport.persistentVolumeClaim.volumeName | string | `nil` | Specifies the name of the persistent volume to use for the `volumes.libraryImportExport` PVC. |
| spotfire-server.volumes.libraryImportExport.subPath | string | `""` | The subPath of the volume to be used for the volume mount |
| spotfire-server.volumes.troubleshooting.existingClaim | string | `""` | When `persistentVolumeClaim.create` is `false`, then use this value to define an already-existing PVC. |
| spotfire-server.volumes.troubleshooting.persistentVolumeClaim.create | bool | `false` | If `true`, then a `PersistentVolumeClaim` (PVC) is created. |
| spotfire-server.volumes.troubleshooting.persistentVolumeClaim.resources | object | `{"requests":{"storage":"2Gi"}}` | Specifies the standard K8s resource requests and/or limits for the `volumes.troubleshooting` PVC. |
| spotfire-server.volumes.troubleshooting.persistentVolumeClaim.storageClassName | string | `""` | Specifies the name of the `StorageClass` that to use for the `volumes.troubleshooting` PVC. |
| spotfire-server.volumes.troubleshooting.persistentVolumeClaim.volumeName | string | `nil` | Specifies the name of the persistent volume to use for the `volumes.troubleshooting` PVC. |
| spotfire-terrservice.acceptEUA | bool | `nil` | Accept the [Cloud Software Group, Inc. End User Agreement](https://www.cloud.com/legal/terms) by setting the value to `true`. |
| spotfire-terrservice.affinity | object | `{}` |  |
| spotfire-terrservice.configuration | object | `{}` | Add [Custom configuration properties](https://docs.tibco.com/pub/terrsrv/latest/doc/html/TIB_terrsrv_install/_shared/install/topics/custom_configuration_properties.html). Keys under configuration should be named the same as the configuration property, for example 'engine.execution.timeout'. |
| spotfire-terrservice.extraContainers | list | `[]` | Additional sidecar containers to add to the service pod. |
| spotfire-terrservice.extraEnvVars | list | `[]` | Additional environment variables. |
| spotfire-terrservice.extraEnvVarsCM | string | `""` | The name of the ConfigMap containing additional environment variables. |
| spotfire-terrservice.extraEnvVarsSecret | string | `""` | The name of the Secret containing extra additional environment variables. |
| spotfire-terrservice.extraInitContainers | list | `[]` | Additional init containers to add to the service pod. |
| spotfire-terrservice.extraVolumeMounts | list | `[]` | Extra volumeMounts for the service container. More info: `kubectl explain deployment.spec.template.spec.containers.volumeMounts`. |
| spotfire-terrservice.extraVolumes | list | `[]` | Extra volumes for the service container. More info: `kubectl explain deployment.spec.template.spec.volumes`. |
| spotfire-terrservice.fluentBitSidecar.image.pullPolicy | string | `"IfNotPresent"` | The image pull policy for the fluent-bit logging sidecar image. |
| spotfire-terrservice.fluentBitSidecar.image.repository | string | `"fluent/fluent-bit"` | The image repository for fluent-bit logging sidecar. |
| spotfire-terrservice.fluentBitSidecar.image.tag | string | `"3.2.8"` | The image tag to use for fluent-bit logging sidecar. |
| spotfire-terrservice.fluentBitSidecar.securityContext | object | `{}` | The securityContext setting for fluent-bit sidecar container. Overrides any securityContext setting on the Pod level. |
| spotfire-terrservice.fullnameOverride | string | `""` |  |
| spotfire-terrservice.image.pullPolicy | string | `nil` | The spotfire-server image pull policy. Overrides global.spotfire.image.pullPolicy. |
| spotfire-terrservice.image.pullSecrets | list | `[]` | Image pull secrets. |
| spotfire-terrservice.image.registry | string | `nil` | The image registry for spotfire-server. Overrides global.spotfire.image.registry value. |
| spotfire-terrservice.image.repository | string | `"spotfire/spotfire-terrservice"` | The spotfire-server image repository. |
| spotfire-terrservice.image.tag | string | `"1.22.0-v3.0.0"` | The container image tag to use. |
| spotfire-terrservice.kedaAutoscaling | object | `{"advanced":{},"cooldownPeriod":300,"enabled":false,"fallback":{},"maxReplicas":4,"minReplicas":1,"pollingInterval":30,"spotfireConfig":{"prometheusServerAddress":"http://prometheus-server.monitor.svc.cluster.local"},"threshold":null,"triggers":[]}` | KEDA autoscaling configuration. See https://keda.sh/docs/latest/concepts/scaling-deployments for more details. |
| spotfire-terrservice.kedaAutoscaling.cooldownPeriod | int | `300` | The period to wait after the last trigger reported active before scaling the resource back to 0. |
| spotfire-terrservice.kedaAutoscaling.maxReplicas | int | `4` | This setting is passed to the HPA definition that KEDA creates for a given resource and holds the maximum number of replicas of the target resource. |
| spotfire-terrservice.kedaAutoscaling.minReplicas | int | `1` | The minimum number of replicas KEDA scales the resource down to. |
| spotfire-terrservice.kedaAutoscaling.pollingInterval | int | `30` | The interval to check each trigger on. |
| spotfire-terrservice.kedaAutoscaling.spotfireConfig | object | `{"prometheusServerAddress":"http://prometheus-server.monitor.svc.cluster.local"}` | Spotfire specific settings. |
| spotfire-terrservice.kedaAutoscaling.spotfireConfig.prometheusServerAddress | string | `"http://prometheus-server.monitor.svc.cluster.local"` | REQUIRED. The URL for the Prometheus server from where metrics are fetched. |
| spotfire-terrservice.livenessProbe.enabled | bool | `true` |  |
| spotfire-terrservice.livenessProbe.failureThreshold | int | `10` |  |
| spotfire-terrservice.livenessProbe.httpGet.path | string | `"/spotfire/liveness"` |  |
| spotfire-terrservice.livenessProbe.httpGet.port | string | `"registration"` |  |
| spotfire-terrservice.livenessProbe.initialDelaySeconds | int | `60` |  |
| spotfire-terrservice.livenessProbe.periodSeconds | int | `3` |  |
| spotfire-terrservice.logging.logForwarderAddress | string | `""` | The spotfire-server log-forwarder name. Template. |
| spotfire-terrservice.logging.logLevel | string | `"debug"` | Set to `debug`, `trace`, `minimal`, or leave empty for info. This applies for both node manager and the service. |
| spotfire-terrservice.nameOverride | string | `""` |  |
| spotfire-terrservice.nodeSelector | object | `{}` |  |
| spotfire-terrservice.nodemanagerConfig.preStopDrainingTimeoutSeconds | int | `610` | The draining timeout after which the service is forcefully shut down. |
| spotfire-terrservice.nodemanagerConfig.serverBackendAddress | string | `""` | The spotfire-server service name. This value is evaluated as a helm template. |
| spotfire-terrservice.podAnnotations."prometheus.io/path" | string | `"/spotfire/metrics"` |  |
| spotfire-terrservice.podAnnotations."prometheus.io/port" | string | `"9080"` |  |
| spotfire-terrservice.podAnnotations."prometheus.io/scrape" | string | `"true"` |  |
| spotfire-terrservice.podSecurityContext | object | `{}` | The Pod securityContext setting applies to all of the containers inside the Pod. |
| spotfire-terrservice.readinessProbe.enabled | bool | `false` |  |
| spotfire-terrservice.readinessProbe.failureThreshold | int | `10` |  |
| spotfire-terrservice.readinessProbe.httpGet.path | string | `"/spotfire/readiness"` |  |
| spotfire-terrservice.readinessProbe.httpGet.port | string | `"registration"` |  |
| spotfire-terrservice.readinessProbe.initialDelaySeconds | int | `60` |  |
| spotfire-terrservice.readinessProbe.periodSeconds | int | `3` |  |
| spotfire-terrservice.replicaCount | int | `1` |  |
| spotfire-terrservice.resources | object | `{}` |  |
| spotfire-terrservice.securityContext | object | `{}` | The securityContext setting for the service container. Overrides any securityContext setting on the Pod level. |
| spotfire-terrservice.service.port | int | `9501` |  |
| spotfire-terrservice.service.type | string | `"ClusterIP"` |  |
| spotfire-terrservice.serviceAccount.annotations | object | `{}` |  |
| spotfire-terrservice.serviceAccount.create | bool | `false` |  |
| spotfire-terrservice.serviceAccount.name | string | `""` |  |
| spotfire-terrservice.startupProbe.enabled | bool | `true` |  |
| spotfire-terrservice.startupProbe.failureThreshold | int | `20` |  |
| spotfire-terrservice.startupProbe.httpGet.path | string | `"/spotfire/started"` |  |
| spotfire-terrservice.startupProbe.httpGet.port | string | `"registration"` |  |
| spotfire-terrservice.startupProbe.initialDelaySeconds | int | `60` |  |
| spotfire-terrservice.startupProbe.periodSeconds | int | `3` |  |
| spotfire-terrservice.tolerations | list | `[]` |  |
| spotfire-terrservice.volumes.packages.existingClaim | string | `""` | When 'persistentVolumeClaim.create' is 'false', then use this value to define an already existing persistent volume claim. |
| spotfire-terrservice.volumes.packages.persistentVolumeClaim.create | bool | `false` | If 'true', then a 'PersistentVolumeClaim' is created. |
| spotfire-terrservice.volumes.packages.persistentVolumeClaim.resources | object | `{"requests":{"storage":"1Gi"}}` | Specifies the standard Kubernetes resource requests and/or limits for the customExt volume claims. |
| spotfire-terrservice.volumes.packages.persistentVolumeClaim.storageClassName | string | `""` | Specifies the name of the 'StorageClass' to use for the customExt volume-claim. |
| spotfire-terrservice.volumes.packages.persistentVolumeClaim.volumeName | string | `nil` | Specifies the name of the persistent volume that should be used for the customExt volume-claim. |
| spotfire-terrservice.volumes.packages.subPath | string | `""` | The subPath of the volume to be used for the volume mount |
| spotfire-terrservice.volumes.troubleshooting.existingClaim | string | `""` | When 'persistentVolumeClaim.create' is 'false', then use this value to define an already existing persistent volume claim. |
| spotfire-terrservice.volumes.troubleshooting.persistentVolumeClaim.create | bool | `false` | If 'true', then a 'PersistentVolumeClaim' will be created. |
| spotfire-terrservice.volumes.troubleshooting.persistentVolumeClaim.resources | object | `{"requests":{"storage":"2Gi"}}` | Specifies the standard Kubernetes resource requests and/or limits for the volumes.troubleshooting claims. |
| spotfire-terrservice.volumes.troubleshooting.persistentVolumeClaim.storageClassName | string | `""` | Specifies the name of the 'StorageClass' to use for the volumes.troubleshooting-claim. |
| spotfire-terrservice.volumes.troubleshooting.persistentVolumeClaim.volumeName | string | `nil` | Specifies the name of the persistent volume to use for the volumes.troubleshooting-claim. |
| spotfire-webplayer.acceptEUA | bool | `nil` | Accept the [Cloud Software Group, Inc. End User Agreement](https://www.cloud.com/legal/terms) by setting the value to `true`. |
| spotfire-webplayer.affinity | object | `{}` |  |
| spotfire-webplayer.config."Spotfire.Dxp.Worker.Core.config" | string | `""` | A custom [Spotfire.Dxp.Worker.Core.config](https://docs.tibco.com/pub/spotfire_server/latest/doc/html/TIB_sfire_server_tsas_admin_help/server/topics/spotfire.dxp.worker.core.config_file.html). |
| spotfire-webplayer.config."Spotfire.Dxp.Worker.Host.dll.config" | string | `""` | A custom Spotfire.Dxp.Worker.Host.dll.config. See [Spotfire.Dxp.Worker.Host.exe.config](https://docs.tibco.com/pub/spotfire_server/latest/doc/html/TIB_sfire_server_tsas_admin_help/server/topics/spotfire.dxp.worker.host.exe.config_file.html). |
| spotfire-webplayer.config."Spotfire.Dxp.Worker.Web.config" | string | `""` | A custom [Spotfire.Dxp.Worker.Web.config](https://docs.tibco.com/pub/spotfire_server/latest/doc/html/TIB_sfire_server_tsas_admin_help/server/topics/spotfire.dxp.worker.web.config_file.html). |
| spotfire-webplayer.extraContainers | list | `[]` | Additional sidecar containers to add to the service pod. |
| spotfire-webplayer.extraEnvVars | list | `[]` | Additional environment variables. |
| spotfire-webplayer.extraEnvVarsCM | string | `""` | The name of the ConfigMap containing additional environment variables. |
| spotfire-webplayer.extraEnvVarsSecret | string | `""` | The name of the Secret containing extra additional environment variables. |
| spotfire-webplayer.extraInitContainers | list | `[]` | Additional init containers to add to the service pod. |
| spotfire-webplayer.extraVolumeMounts | list | `[]` | Extra volumeMounts for the service container. More info: `kubectl explain deployment.spec.template.spec.containers.volumeMounts`. |
| spotfire-webplayer.extraVolumes | list | `[]` | Extra volumes for the service container. More info: `kubectl explain deployment.spec.template.spec.volumes`. |
| spotfire-webplayer.fluentBitSidecar.image.pullPolicy | string | `"IfNotPresent"` | The image pull policy for the fluent-bit logging sidecar image. |
| spotfire-webplayer.fluentBitSidecar.image.repository | string | `"fluent/fluent-bit"` | The image repository for fluent-bit logging sidecar. |
| spotfire-webplayer.fluentBitSidecar.image.tag | string | `"3.2.8"` | The image tag to use for fluent-bit logging sidecar. |
| spotfire-webplayer.fluentBitSidecar.securityContext | object | `{}` | The securityContext setting for fluent-bit sidecar container. Overrides any securityContext setting on the Pod level. |
| spotfire-webplayer.fullnameOverride | string | `""` |  |
| spotfire-webplayer.image.pullPolicy | string | `nil` | The spotfire-server image pull policy. Overrides global.spotfire.image.pullPolicy. |
| spotfire-webplayer.image.pullSecrets | list | `[]` | Image pull secrets. |
| spotfire-webplayer.image.registry | string | `nil` | The image registry for spotfire-server. Overrides global.spotfire.image.registry value. |
| spotfire-webplayer.image.repository | string | `"spotfire/spotfire-webplayer"` | The spotfire-server image repository. |
| spotfire-webplayer.image.tag | string | `"14.5.0-v3.0.0"` | The container image tag to use. |
| spotfire-webplayer.kedaAutoscaling | object | `{"advanced":{},"cooldownPeriod":300,"enabled":false,"fallback":{},"maxReplicas":4,"minReplicas":1,"pollingInterval":30,"spotfireConfig":{"prometheusServerAddress":"http://prometheus-server.monitor.svc.cluster.local"},"threshold":null,"triggers":[]}` | KEDA autoscaling configuration. See https://keda.sh/docs/latest/concepts/scaling-deployments for more details. |
| spotfire-webplayer.kedaAutoscaling.cooldownPeriod | int | `300` | The period to wait after the last trigger reported active before scaling the resource back to 0. |
| spotfire-webplayer.kedaAutoscaling.maxReplicas | int | `4` | This setting is passed to the HPA definition that KEDA creates for a given resource and holds the maximum number of replicas of the target resource. |
| spotfire-webplayer.kedaAutoscaling.minReplicas | int | `1` | The minimum number of replicas KEDA scales the resource down to. |
| spotfire-webplayer.kedaAutoscaling.pollingInterval | int | `30` | The interval to check each trigger on. |
| spotfire-webplayer.kedaAutoscaling.spotfireConfig | object | `{"prometheusServerAddress":"http://prometheus-server.monitor.svc.cluster.local"}` | Spotfire specific settings. |
| spotfire-webplayer.kedaAutoscaling.spotfireConfig.prometheusServerAddress | string | `"http://prometheus-server.monitor.svc.cluster.local"` | REQUIRED. The URL for the Prometheus server from where metrics are fetched. |
| spotfire-webplayer.livenessProbe.enabled | bool | `true` |  |
| spotfire-webplayer.livenessProbe.failureThreshold | int | `10` |  |
| spotfire-webplayer.livenessProbe.httpGet.path | string | `"/spotfire/liveness"` |  |
| spotfire-webplayer.livenessProbe.httpGet.port | string | `"registration"` |  |
| spotfire-webplayer.livenessProbe.initialDelaySeconds | int | `60` |  |
| spotfire-webplayer.livenessProbe.periodSeconds | int | `3` |  |
| spotfire-webplayer.logging.logForwarderAddress | string | `""` | The spotfire-server log-forwarder name. Template. |
| spotfire-webplayer.logging.logLevel | string | `"debug"` | Set to `debug`, `trace`, `minimal`, or leave empty for info. This applies to node manager and not the service. |
| spotfire-webplayer.logging.workerhost.logConfiguration | string | `"standard"` | Log configuration for the service. Currently available configs are: `standard`, `minimum`, `info`, `debug`, `monitoring`, `fullmonitoring`, `trace`. |
| spotfire-webplayer.nameOverride | string | `""` |  |
| spotfire-webplayer.nodeSelector | object | `{}` |  |
| spotfire-webplayer.nodemanagerConfig.preStopDrainingTimeoutSeconds | int | `610` | The draining timeout after which the service is forcefully shut down. |
| spotfire-webplayer.nodemanagerConfig.serverBackendAddress | string | `""` | The spotfire-server service name. This value is evaluated as a helm template. |
| spotfire-webplayer.podAnnotations."prometheus.io/path" | string | `"/spotfire/metrics"` |  |
| spotfire-webplayer.podAnnotations."prometheus.io/port" | string | `"9080"` |  |
| spotfire-webplayer.podAnnotations."prometheus.io/scrape" | string | `"true"` |  |
| spotfire-webplayer.podSecurityContext | object | `{}` | The Pod securityContext setting applies to all of the containers inside the Pod. |
| spotfire-webplayer.readinessProbe.enabled | bool | `false` |  |
| spotfire-webplayer.readinessProbe.failureThreshold | int | `10` |  |
| spotfire-webplayer.readinessProbe.httpGet.path | string | `"/spotfire/readiness"` |  |
| spotfire-webplayer.readinessProbe.httpGet.port | string | `"registration"` |  |
| spotfire-webplayer.readinessProbe.initialDelaySeconds | int | `60` |  |
| spotfire-webplayer.readinessProbe.periodSeconds | int | `3` |  |
| spotfire-webplayer.replicaCount | int | `1` |  |
| spotfire-webplayer.resources | object | `{}` |  |
| spotfire-webplayer.securityContext | object | `{}` | The securityContext setting for the service container. Overrides any securityContext setting on the Pod level. |
| spotfire-webplayer.service.port | int | `9501` |  |
| spotfire-webplayer.service.type | string | `"ClusterIP"` |  |
| spotfire-webplayer.serviceAccount.annotations | object | `{}` |  |
| spotfire-webplayer.serviceAccount.create | bool | `false` |  |
| spotfire-webplayer.serviceAccount.name | string | `""` |  |
| spotfire-webplayer.startupProbe.enabled | bool | `true` |  |
| spotfire-webplayer.startupProbe.failureThreshold | int | `20` |  |
| spotfire-webplayer.startupProbe.httpGet.path | string | `"/spotfire/started"` |  |
| spotfire-webplayer.startupProbe.httpGet.port | string | `"registration"` |  |
| spotfire-webplayer.startupProbe.initialDelaySeconds | int | `60` |  |
| spotfire-webplayer.startupProbe.periodSeconds | int | `3` |  |
| spotfire-webplayer.tolerations | list | `[]` |  |
| spotfire-webplayer.volumes.customModules.existingClaim | string | `""` | When 'persistentVolumeClaim.create' is 'false', then use this value to define an already existing persistent volume claim. |
| spotfire-webplayer.volumes.customModules.persistentVolumeClaim.create | bool | `false` | If 'true', then a 'PersistentVolumeClaim' is created. |
| spotfire-webplayer.volumes.customModules.persistentVolumeClaim.resources | object | `{"requests":{"storage":"2Gi"}}` | Specifies the standard Kubernetes resource requests and/or limits for the volumes.customModules claims. |
| spotfire-webplayer.volumes.customModules.persistentVolumeClaim.storageClassName | string | `""` | Specifies the name of the 'StorageClass' to use for the volumes.customModules-claim. |
| spotfire-webplayer.volumes.customModules.persistentVolumeClaim.volumeName | string | `nil` | Specifies the name of the persistent volume to use for the volumes.customModules-claim. |
| spotfire-webplayer.volumes.customModules.subPath | string | `""` | The subPath of the volume to be used for the volume mount |
| spotfire-webplayer.volumes.troubleshooting.existingClaim | string | `""` | When 'persistentVolumeClaim.create' is 'false', then use this value to define an already existing persistent volume claim. |
| spotfire-webplayer.volumes.troubleshooting.persistentVolumeClaim.create | bool | `false` | If 'true', then a 'PersistentVolumeClaim' will be created. |
| spotfire-webplayer.volumes.troubleshooting.persistentVolumeClaim.resources | object | `{"requests":{"storage":"2Gi"}}` | Specifies the standard Kubernetes resource requests and/or limits for the volumes.troubleshooting claims. |
| spotfire-webplayer.volumes.troubleshooting.persistentVolumeClaim.storageClassName | string | `""` | Specifies the name of the 'StorageClass' to use for the volumes.troubleshooting-claim. |
| spotfire-webplayer.volumes.troubleshooting.persistentVolumeClaim.volumeName | string | `nil` | Specifies the name of the persistent volume to use for the volumes.troubleshooting-claim. |
| spotfire-webplayer.webplayerConfig.resourcePool | string | `""` | The web player resource pool. |

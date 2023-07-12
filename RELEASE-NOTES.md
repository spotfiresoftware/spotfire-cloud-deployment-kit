# Release v1.5.0

This release includes recipes for building container images and Helm charts for the following products.

- TIBCO Spotfire Server 12.5.0
- TIBCO Spotfire Web Player 12.5.0
- TIBCO Spotfire Automation Services 12.5.0
- TIBCO Enterprise Runtime for R - Server Edition 1.16.0
- TIBCO Spotfire Service for Python 1.16.0
- TIBCO Spotfire Service for R 1.16.0


The recipes are validated with the listed Spotfire products and versions. They could work with other Spotfire versions with modifications.

Version mapping table:

| Chart name | Chart version | appVersion | Image tag |
| ---------- | ------------- | ---------- | --------- |
| spotfire-server | 0.1.7 | 12.5.0 | 12.5.0-1.5.0 |
| spotfire-webplayer | 0.1.7 | 12.5.0 | 12.5.0-1.5.0 |
| spotfire-automationservices | 0.1.7 | 12.5.0 | 12.5.0-1.5.0 |
| spotfire-terrservice | 0.1.7 | 1.16.0 | 1.16.0-1.5.0 |
| spotfire-pythonservice | 0.1.7 | 1.16.0 | 1.16.0-1.5.0 |
| spotfire-rservice | 0.1.7 | 1.16.0 | 1.16.0-1.5.0 |

Note: The image tag format is \<appVersion\>-\<cdk version\>

## Changes

### General

- Volume mounts for charts now support specifying [subPath](https://kubernetes.io/docs/concepts/storage/volumes/#using-subpath).
- Added a chart to support deploying the new service TIBCO Spotfire Service for R.
- Fix provided for the issue "[Unable to build container image spotfire-base due to failure to install openjdk-17-jre-headless](https://github.com/TIBCOSoftware/spotfire-cloud-deployment-kit/issues/14)."
- Minimum Kubernetes version required by charts updated to 1.24.0-0.
- Added  custom configuration for action log database logging for the spotfire-server helm chart. An umbrella-example ( helm/examples/spotfire-umbrella-example/values-actionlogdb ) was added for testing and example purposes.  Various configuration keys are included in under the Values.configuration section of the 
  Values.yaml file. These keys provide the following capabilities:
    * Configuring 'Categories and Web Categories'.
    * Enabling or disabling logging to a database. 
    * Enabling access and/or creating the action log database.
- Various other bug fixes and improvements.

### spotfire-server chart 0.1.7

- Added the ability to configure action log settings in spotfire-server to log to a database.

| New key | Old key | Comment |
| - | - | - |
| volumes.libraryImportExport.subPath | | Added |
| volumes.customExt.subPath | | Added |
| volumes.customExtInformationservices.subPath | | Added |
| volumes.certificates.subPath | | Added |
| volumes.deployments.subPath | | Added |
| configuration.actionLog.\* | | Added |

### spotfire-pythonservice chart 0.1.7

| New key | Old key | Comment |
| - | - | - |
| volumes.packages.subPath | | Added |


### spotfire-terrservice chart 0.1.7

| New key | Old key | Comment |
| - | - | - |
| volumes.packages.subPath | | Added |


### spotfire-webplayer chart 0.1.7

| New key | Old key | Comment |
| - | - | - |
| volumes.customModules.subPath | | Added |


### spotfire-automationservices chart 0.1.7

| New key | Old key | Comment |
| - | - | - |
| volumes.customModules.subPath | | Added |

### spotfire-rservice chart 0.1.7

- New.


# Release v1.4.0

This release includes recipes for building container images and Helm charts for the following products.

- TIBCO Spotfire Server 12.4.0
- TIBCO Spotfire Service for Python 1.15.0
- TIBCO Enterprise Runtime for R - Server Edition 1.15.0
- TIBCO Spotfire Web Player 12.4.0
- TIBCO Spotfire Automation Services 12.4.0

The recipes are validated with the listed Spotfire products and versions. They could work with other Spotfire versions with modifications.

Version mapping table:

| Chart name | Chart version | appVersion | Image tag |
| ---------- | ------------- | ---------- | --------- |
| spotfire-server | 0.1.6 | 12.4.0 | 12.4.0-1.4.0 |
| spotfire-webplayer | 0.1.6 | 12.4.0 | 12.4.0-1.4.0 |
| spotfire-automationservices | 0.1.6 | 12.4.0 | 12.4.0-1.4.0 |
| spotfire-terrservice | 0.1.6 | 1.15.0 | 1.15.0-1.4.0 |
| spotfire-pythonservice | 0.1.6 | 1.15.0 | 1.15.0-1.4.0 |

Note: The image tag format is \<appVersion\>-\<cdk version\>

## Changes

### General

- Bug fixes and improvements.

### spotfire-server chart 0.1.6

- Added possibility to set spotfire-server in maintenance mode during the spotfire-server deployment will be inaccessible
- Spotfire server configuration properties are exposed in as values

| New key | Old key | Comment |
| - | - | - |
| configuration.draining.publishNotReadyAddresses | | Added |
| configuration.properties.* | | Added |
| configuration.deployment.clear | | Added |
| haproxy.config | | Changed. If you have overridden this value, review changes in the chart. |
| haproxy.spotfireConfig.compression.* | | Added |
| haproxy.spotfireConfig.cache.* | | Added |
| haproxy.spotfireConfig.maintenance.* | | Added |
| haproxy.spotfireConfig.maintenancePage.* | | Added |
| haproxy.includesMountPath | | Added |

### spotfire-pythonservice chart 0.1.6

| New key | Old key | Comment |
| - | - | - |
| | global.serviceName | Removed |

### spotfire-terrservice chart 0.1.6

| New key | Old key | Comment |
| - | - | - |
| | global.serviceName | Removed |

### spotfire-webplayer chart 0.1.6

- You can mount in a volume containing Spotfire modules to be loaded during startup.

| New key | Old key | Comment |
| - | - | - |
| | global.serviceName | Removed |
| volumes.customModules.* | | Added |

### spotfire-automationservices chart 0.1.6

- You can mount in a volume containing Spotfire modules to be loaded during startup.

| New key | Old key | Comment |
| - | - | - |
| | global.serviceName | Removed |
| volumes.customModules.* | | Added |


# Release v1.3.1

Fixes the following issues:

- Error when building containers `cp: cannot create regular file 'spotfire-deployment/build/Spotfire.Dxp.sdn': No such file or directory`.
- Missing executable attribute on some shell scripts, making it impossible to start some container images.

# Release v1.3.0

This release includes recipes for building container images and Helm charts for the following products.

- TIBCO Spotfire Server 12.3.0
- TIBCO Spotfire Service for Python 1.15.0
- TIBCO Enterprise Runtime for R - Server Edition 1.15.0
- TIBCO Spotfire Web Player 12.3.0
- TIBCO Spotfire Automation Services 12.3.0

The recipes are validated with the listed Spotfire products and versions. They could work with other Spotfire versions with modifications.

Version mapping table:

| Chart name | Chart version | appVersion | Image tag |
| ---------- | ------------- | ---------- | --------- |
| spotfire-server | 0.1.5 | 12.3.0 | 12.3.0-1.3.0 |
| spotfire-webplayer | 0.1.5 | 12.3.0 | 12.3.0-1.3.0 |
| spotfire-automationservices | 0.1.5 | 12.3.0 | 12.3.0-1.3.0 |
| spotfire-terrservice | 0.1.5 | 1.15.0 | 1.15.0-1.3.0 |
| spotfire-pythonservice | 0.1.5 | 1.15.0 | 1.15.0-1.3.0 |

Note: The image tag format is \<appVersion\>-\<cdk version\>

## Changes

### General

- Various enhancements and bug fixes to the Helm charts and container images.
- All charts require you to accept the [Cloud Software Group, Inc. End User Agreement](https://terms.tibco.com/#end-user-agreement) by setting `acceptEUA` or `global.spotfire.acceptEUA` to **true**.
- All containers require you to accept the [Cloud Software Group, Inc. End User Agreement](https://terms.tibco.com/#end-user-agreement) by setting the environment variable `ACCEPT_EUA` to **Y**.
- An example umbrella chart that can install an entire Spotfire system, including a database, a Spotfire Server, a Web Player with multiple resource pools, Automation Services, TIBCO Enterprise Runtime for R - Server Edition (a TERR service), and Spotfire Service for Python. See helm/examples/umbrella-chart/README.md for more information.

### spotfire-server chart 0.1.5

- Language packs are automatically deployed when the `configuration.deployment.defaultDeployment.enabled` is set to **true**. Previously, the language packs were not deployed when using the default deployment.
- Haproxy chart upgraded from 1.17.3 to 1.18.\*.
- Fluentbit (log-forwarder) chart upgraded from 0.21.2 to 0.22.\*.

Changes in values.yaml:

| New key | Old key | Comment |
| ------- | ------- | ------- |
| `acceptEUA` | | Accept the End User Agreement by setting `acceptEUA` or `global.spotfire.acceptEUA` to **true**. If not set, the Helm release does not install. |
| `global.spotfire.acceptEUA` | | The same as `acceptEUA`, but as a global value. |
| `haproxy.spotfireConfig.captures.forwardedForLength` | | |

### spotfire-pythonservice chart 0.1.5

- Now you can set individual service properties (in `custom.properties`) by adding the name of the property as a subkey to the `configuration` key in values.yaml. Previously, you had to set the entire `custom.properties` file as a string.
- Improved documentation for installing additional python packages, including an example.

Changes in values.yaml:

| New key | Old key | Comment |
| ------- | ------- | ------- |
| `acceptEUA` | | Accept the End User Agreement by setting `acceptEUA` or `global.spotfire.acceptEUA` to **true**. If not set, the Helm release does not install. |
| `global.spotfire.acceptEUA` | | The same as `acceptEUA`, but as a global value. |
| `configuration.*` | `config.conf/custom.properties` | A new key that exposes the service configuration 'custom.properties' as Helm values. |
| | `config.log4j2.xml`| You can no longer set the entire file contents from values, but the log level can be set with `logging.logLevel`. |
| | `volumes.packages.mountPath` | Removed. `mountPath` is now hardcoded to **/opt/packages**. |

### spotfire-terrservice chart 0.1.5

- Now you can set individual service properties (in `custom.properties`) by adding the name of the property as a subkey to the `configuration` key in the file values.yaml. Previously, you had to set the entire `custom.properties` file as a string.

Changes in values.yaml:

| New key | Old key | Comment |
| ------- | ------- | ------- |
| `acceptEUA` | | Accept the End User Agreement by setting `acceptEUA` or `global.spotfire.acceptEUA` to **true**. If not set, the Helm release does not install. |
| `global.spotfire.acceptEUA` | | The same as `acceptEUA`, but as a global value. |
| `configuration.*` | `config.conf/custom.properties` | New key exposes the service configuration 'custom.properties' as Helm values. |
| | `config.log4j2.xml`| You can no longer set the entire file content from values, but log level can be set with `logging.logLevel`. |
| | `volumes.packages.mountPath` | Removed. `mountPath` is now hardcoded to **/opt/packages**. |

### spotfire-webplayer chart 0.1.5

Changes in values.yaml:

| New key | Old key | Comment |
| ------- | ------- | ------- |
| `acceptEUA` | | Accept the End User Agreement by setting `acceptEUA` or `global.spotfire.acceptEUA` to **true**. If not set, the Helm release does not install. |
| `global.spotfire.acceptEUA` | | The same as `acceptEUA`, but as a global value. |

### spotfire-automationservices chart 0.1.5

Changes in values.yaml:

| New key | Old key | Comment |
| ------- | ------- | ------- |
| `acceptEUA` | | Accept the End User Agreement by setting `acceptEUA` or `global.spotfire.acceptEUA` to **true**. If not set, the Helm release does not install. |
| `global.spotfire.acceptEUA` | | The same as `acceptEUA`, but as a global value. |


# Release v1.2.0

This release includes recipes for building container images and Helm charts for the following products.

- TIBCO Spotfire Server 12.2.0
- TIBCO Spotfire Service for Python 1.14.0
- TIBCO Enterprise Runtime for R - Server Edition 1.14.0
- TIBCO Spotfire Web Player 12.2.0
- TIBCO Spotfire Automation Services 12.2.0

The recipes are validated with the listed Spotfire products and versions. They could work with other Spotfire versions with modifications.

Version mapping table:

| Chart name | Chart version | appVersion | Image tag |
| ---------- | ------------- | ---------- | --------- |
| spotfire-server | 0.1.4 | 12.2.0 | 12.2.0-1.2.0 |
| spotfire-webplayer | 0.1.4 | 12.2.0 | 12.2.0-1.2.0 |
| spotfire-automationservices | 0.1.4 | 12.2.0 | 12.2.0-1.2.0 |
| spotfire-terrservice | 0.1.4 | 1.14.0 | 1.14.0-1.2.0 |
| spotfire-pythonservice | 0.1.4 | 1.14.0 | 1.14.0-1.2.0 |

Note: The image tag format is \<appVersion\>-\<cdk version\>

## Changes

### General

- Various improvements and bug fixes.

### spotfire-server chart 0.1.4

- A client deployment (Spotfire.Dxp.sdn) can be added automatically to a deployment area during installation. See `configuration.deployment` in the chart's README.md.
- The password for creating and connecting to the Spotfire database, as well as the Spotfire admin password, can be read from an existing secret. See information about `*.<prefix>ExistingSecret` in the chart's README.md.
- The encryptionPassword was not used during an upgrade to the Spotfire configuration. This issue is fixed. See information about `configuration.apply` in the chart's README.md.

Updates to values.yaml

| New key | Old key | Comment |
| - | - | - |
| `configuration.apply` | | Added |
| `configuration.deployment` | | Added. A spotfire deployment can be added automatically to the deployment area during installation. |
| `configuration.draining.*` | `draining.*` | Moved |
| `configuration.encryptionPassword` | `encryptionPassword` | Moved |
| `configuration.preferExistingConfig` | `configuration.useExisting` | Moved |
| `configuration.site.*` | `site.*` | Moved |
| `configuration.spotfireAdmin.*` | `spotfireAdmin.*` | Moved |
| `configuration.spotfireAdmin.passwordExistingSecret.{name,key}` | `spotfireAdmin.existingSecret` | Changed. Only the password and not the username is read from the existingSecret. |
| `database.bootstrap.passwordExistingSecret.{name,key}` | `database.bootstrap.existingSecret` | Changed. Only the password and not the username is read from the existingSecret. |
| `database.create-db.adminUsernameExistingSecret.*` | | Removed |
| `haproxy.spotfireConfig.serverTemplate.additionalParams` | | Added |
| `kedaAutoscaling.threshold` | | Added |
| | `configuration.applyKubernetesConfiguration` | Removed |

### spotfire-pythonservice chart 0.1.4

Updates to values.yaml

| New key | Old key | Comment |
| - | - | - |
| `kedaAutoscaling.threshold` | | Added |

### spotfire-terrservice chart 0.1.4

Updates to values.yaml

| New key | Old key | Comment |
| - | - | - |
| `kedaAutoscaling.threshold` | | Added |

### spotfire-webplayer chart 0.1.4

Updates to values.yaml

| New key | Old key | Comment |
| - | - | - |
| `kedaAutoscaling.threshold` | | Added |

### spotfire-automationservices chart 0.1.4

Updates to values.yaml

| New key | Old key | Comment |
| - | - | - |
| `kedaAutoscaling.threshold` | | Added |

# Release v1.1.0

This release includes recipes for building container images and Helm charts for the following products.

- TIBCO Spotfire Server 12.1.1
- TIBCO Spotfire Service for Python 1.13.0
- TIBCO Enterprise Runtime for R - Server Edition 1.13.0
- TIBCO Spotfire Web Player 12.1.1
- TIBCO Spotfire Automation Services 12.1.1

The recipes are validated with the listed Spotfire products and versions. They could work with other Spotfire versions with modifications.

Version mapping table:

| Chart name                  | Chart version | appVersion | Image tag    |
|-----------------------------|---------------|------------|--------------|
| spotfire-server             | 0.1.3         | 12.1.1     | 12.1.1-1.1.0 |
| spotfire-webplayer          | 0.1.3         | 12.1.1     | 12.1.1-1.1.0 |
| spotfire-automationservices | 0.1.3         | 12.1.1     | 12.1.1-1.1.0 |
| spotifre-terrservice        | 0.1.3         | 1.13.0     | 1.13.0-1.1.0 |
| spotfire-pythonservice      | 0.1.3         | 1.13.0     | 1.13.0-1.1.0 |

**Note**: Image tag format is `<appVersion>-<cdk version>`

## Changes

General: Various improvements and bug fixes.

### spotfire-server chart 0.1.3

- You can use an existing Secret to specify usernames and passwords for the database connection and Spotfire admin user. Related values: `database.bootstrap.existingSecret`,` database.create-db.adminUsernameExistingSecret.name`, `database.create-db.adminUsernameExistingSecret.key`, `database.create-db.adminPasswordExistingSecret.name`, `database.create-db.adminPasswordExistingSecret.key`,`spotfireAdmin.existingSecret`.
- Information services runs as a separate process by default. You can use a separate mount path / volume to add jar-files that should be loaded for information services. Related values: `volumes.customExtInformationservices.existingClaim`

#### Breaking changes

For the spotfire-server chart, in `values.yaml`, the following keys have been renamed / restructured.

| Old name | New Name |
| -------- | -------- |
| `spotfireAdminUsername` | `spotfireAdmin.username` | 
| `spotfireAdminPassword` | `spotfireAdmin.password` |

This code is provided as-is with no warranties.

# Release v1.0.0

This release includes recipes for building container images and Helm charts for the following products.

- TIBCO Spotfire Server 12.0.0 LTS
- TIBCO Spotfire Service for Python 1.12.0
- TIBCO Enterprise Runtime for R - Server Edition 1.12.0
- TIBCO Spotfire Web Player 12.0.0 LTS
- TIBCO Spotfire Automation Services 12.0.0 LTS

The recipes are validated with the listed Spotfire products and versions. They could work with other Spotfire versions with modifications.

This code is provided as-is with no warranties.

# Release v0.2.0

Updated recipes for building container images and Helm charts for:

* TIBCO Spotfire Server 12.0.0 LTS
* TIBCO Spotfire Service for Python 1.12.0
* TIBCO Enterprise Runtime for R - Server Edition 1.12.0

Added recipes for building container images and Helm charts for:

* TIBCO Spotfire Web Player 12.0.0 LTS
* TIBCO Spotfire Automation Services 12.0.0 LTS

The recipes have been validated with the listed Spotfire products and versions. They could work for other Spotfire versions with some modifications.

This functionality is a preview and is subject to change. The code is provided as-is with no warranties.

# Cloud Deployment Kit for Spotfire v0.1.0

First release.

Added recipes for building container images and helm charts for:
- TIBCO Spotfire Server 11.8.1
- TIBCO Spotfire Service for Python 1.11.1
- TIBCO Enterprise Runtime for R - Server Edition 1.11.1

The recipes have been validated with the listed Spotfire products and versions. They could work for other Spotfire versions with some modifications.

This functionality is a preview and is subject to change. The code is provided as-is with no warranties.

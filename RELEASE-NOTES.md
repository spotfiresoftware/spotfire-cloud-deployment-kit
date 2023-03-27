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

### spotfire-server chart

- Language packs are automatically deployed when the `configuration.deployment.defaultDeployment.enabled` is set to **true**. Previously, the language packs were not deployed when using the default deployment.
- Haproxy chart upgraded from 1.17.3 to 1.18.\*.
- Fluentbit (log-forwarder) chart upgraded from 0.21.2 to 0.22.\*.

Changes in values.yaml:

| New key | Old key | Comment |
| ------- | ------- | ------- |
| `acceptEUA` | | Accept the End User Agreement by setting `acceptEUA` or `global.spotfire.acceptEUA` to **true**. If not set, the Helm release does not install. |
| `global.spotfire.acceptEUA` | | The same as `acceptEUA`, but as a global value. |
| `haproxy.spotfireConfig.captures.forwardedForLength` | | |

### spotfire-pythonservice chart

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

### spotfire-terrservice chart

- Now you can set individual service properties (in `custom.properties`) by adding the name of the property as a subkey to the `configuration` key in the file values.yaml. Previously, you had to set the entire `custom.properties` file as a string.

Changes in values.yaml:

| New key | Old key | Comment |
| ------- | ------- | ------- |
| `acceptEUA` | | Accept the End User Agreement by setting `acceptEUA` or `global.spotfire.acceptEUA` to **true**. If not set, the Helm release does not install. |
| `global.spotfire.acceptEUA` | | The same as `acceptEUA`, but as a global value. |
| `configuration.*` | `config.conf/custom.properties` | New key exposes the service configuration 'custom.properties' as Helm values. |
| | `config.log4j2.xml`| You can no longer set the entire file content from values, but log level can be set with `logging.logLevel`. |
| | `volumes.packages.mountPath` | Removed. `mountPath` is now hardcoded to **/opt/packages**. |

### spotfire-webplayer chart

Changes in values.yaml:

| New key | Old key | Comment |
| ------- | ------- | ------- |
| `acceptEUA` | | Accept the End User Agreement by setting `acceptEUA` or `global.spotfire.acceptEUA` to **true**. If not set, the Helm release does not install. |
| `global.spotfire.acceptEUA` | | The same as `acceptEUA`, but as a global value. |

### spotfire-automationservices chart

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

### spotfire-server chart

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

### spotfire-pythonservice chart

Updates to values.yaml

| New key | Old key | Comment |
| - | - | - |
| `kedaAutoscaling.threshold` | | Added |

### spotfire-terrservice chart

Updates to values.yaml

| New key | Old key | Comment |
| - | - | - |
| `kedaAutoscaling.threshold` | | Added |

### spotfire-webplayer chart

Updates to values.yaml

| New key | Old key | Comment |
| - | - | - |
| `kedaAutoscaling.threshold` | | Added |

### spotfire-automationservices chart

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

### spotfire-server chart

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

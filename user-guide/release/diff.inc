## Helm chart changes

### Chart spotfire-automationservices changes from 2.0.0 to 3.0.0

values.yaml

| Key | Comment | Old Value | New Value |
| --- | ------- | --------- | --------- |
| .image.tag | Value changed | `14.6.0-v4.0.0` | `14.7.0-v5.0.0` |
| .fluentBitSidecar.image.tag | Value changed | `4.0.7` | `4.1.0` |

Chart.yaml

| Key | Comment | Old Value | New Value |
| --- | ------- | --------- | --------- |
| .version | Value changed | `2.0.0` | `3.0.0` |
| .appVersion | Value changed | `14.6.0` | `14.7.0` |
| .dependencies[0].version | Value changed | `2.0.0` | `3.0.0` |


### Chart spotfire-platform changes from 2.0.0 to 3.0.0

values.yaml

| Key | Comment | Old Value | New Value |
| --- | ------- | --------- | --------- |
| .postgresql.image | Dictionary item added |  |  |
| .postgresql.primary | Dictionary item added |  |  |

Chart.yaml

| Key | Comment | Old Value | New Value |
| --- | ------- | --------- | --------- |
| .version | Value changed | `2.0.0` | `3.0.0` |
| .appVersion | Value changed | `14.6-v4.0.0` | `14.7-v5.0.0` |
| .dependencies[3] | Value changed | `{'name': 'spotfire-terrservice', 'repository': 'file://../spotfire-terrservice/', 'version': '2.0.0', 'condition': 'spotfire-terrservice.enabled'}` | `{'name': 'spotfire-terrservice', 'repository': 'file://../spotfire-terrservice/', 'version': '3.0.0', 'condition': 'spotfire-terrservice.enabled'}` |
| .dependencies[1] | Value changed | `{'name': 'spotfire-webplayer', 'repository': 'file://../spotfire-webplayer/', 'version': '2.0.0', 'condition': 'spotfire-webplayer.enabled'}` | `{'name': 'spotfire-webplayer', 'repository': 'file://../spotfire-webplayer/', 'version': '3.0.0', 'condition': 'spotfire-webplayer.enabled'}` |
| .dependencies[0] | Value changed | `{'name': 'spotfire-server', 'repository': 'file://../spotfire-server/', 'version': '2.0.0'}` | `{'name': 'spotfire-server', 'repository': 'file://../spotfire-server/', 'version': '3.0.0'}` |
| .dependencies[2] | Value changed | `{'name': 'spotfire-automationservices', 'repository': 'file://../spotfire-automationservices/', 'version': '2.0.0', 'condition': 'spotfire-automationservices.enabled'}` | `{'name': 'spotfire-automationservices', 'repository': 'file://../spotfire-automationservices/', 'version': '3.0.0', 'condition': 'spotfire-automationservices.enabled'}` |
| .dependencies[4] | Value changed | `{'name': 'spotfire-rservice', 'repository': 'file://../spotfire-rservice/', 'version': '2.0.0', 'condition': 'spotfire-rservice.enabled'}` | `{'name': 'spotfire-rservice', 'repository': 'file://../spotfire-rservice/', 'version': '3.0.0', 'condition': 'spotfire-rservice.enabled'}` |
| .dependencies[5] | Value changed | `{'name': 'spotfire-pythonservice', 'repository': 'file://../spotfire-pythonservice/', 'version': '2.0.0', 'condition': 'spotfire-pythonservice.enabled'}` | `{'name': 'spotfire-pythonservice', 'repository': 'file://../spotfire-pythonservice/', 'version': '3.0.0', 'condition': 'spotfire-pythonservice.enabled'}` |


### Chart spotfire-pythonservice changes from 2.0.0 to 3.0.0

values.yaml

| Key | Comment | Old Value | New Value |
| --- | ------- | --------- | --------- |
| .image.tag | Value changed | `1.23.0-v4.0.0` | `1.24.0-v5.0.0` |
| .fluentBitSidecar.image.tag | Value changed | `4.0.7` | `4.1.0` |

Chart.yaml

| Key | Comment | Old Value | New Value |
| --- | ------- | --------- | --------- |
| .version | Value changed | `2.0.0` | `3.0.0` |
| .appVersion | Value changed | `1.23.0` | `1.24.0` |
| .dependencies[0].version | Value changed | `2.0.0` | `3.0.0` |


### Chart spotfire-rservice changes from 2.0.0 to 3.0.0

values.yaml

| Key | Comment | Old Value | New Value |
| --- | ------- | --------- | --------- |
| .image.tag | Value changed | `1.23.0-v4.0.0` | `1.24.0-v5.0.0` |
| .fluentBitSidecar.image.tag | Value changed | `4.0.7` | `4.1.0` |

Chart.yaml

| Key | Comment | Old Value | New Value |
| --- | ------- | --------- | --------- |
| .version | Value changed | `2.0.0` | `3.0.0` |
| .appVersion | Value changed | `1.23.0` | `1.24.0` |
| .dependencies[0].version | Value changed | `2.0.0` | `3.0.0` |


### Chart spotfire-server changes from 2.0.0 to 3.0.0

values.yaml

| Key | Comment | Old Value | New Value |
| --- | ------- | --------- | --------- |
| .image.tag | Value changed | `14.6.0-v4.0.0` | `14.7.0-v5.0.0` |
| .fluentBitSidecar.image.tag | Value changed | `4.0.7` | `4.1.0` |
| .startupProbe.httpGet.port | Value changed | `http` | `service` |
| .livenessProbe.httpGet.port | Value changed | `http` | `service` |
| .cliPod.image.tag | Value changed | `14.6.0-v4.0.0` | `14.7.0-v5.0.0` |
| .configJob.image.tag | Value changed | `14.6.0-v4.0.0` | `14.7.0-v5.0.0` |
| .configuration.deployment.defaultDeployment.image.tag | Value changed | `14.6.0-v4.0.0` | `14.7.0-v5.0.0` |
| .ingress.servicePort | Dictionary item added |  |  |
| .database.upgradeOptions | Dictionary item added |  |  |
| .configuration.deployment.defaultDeployment.resources | Dictionary item added |  |  |

Chart.yaml

| Key | Comment | Old Value | New Value |
| --- | ------- | --------- | --------- |
| .version | Value changed | `2.0.0` | `3.0.0` |
| .appVersion | Value changed | `14.6.0` | `14.7.0` |
| .dependencies[0] | Value changed | `{'name': 'fluent-bit', 'alias': 'log-forwarder', 'repository': 'https://fluent.github.io/helm-charts', 'version': '0.52.*', 'condition': 'log-forwarder.enabled'}` | `{'name': 'fluent-bit', 'alias': 'log-forwarder', 'repository': 'https://fluent.github.io/helm-charts', 'version': '0.54.*', 'condition': 'log-forwarder.enabled'}` |
| .dependencies[2] | Value changed | `{'name': 'spotfire-common', 'repository': 'file://../spotfire-common', 'version': '2.0.0'}` | `{'name': 'spotfire-common', 'repository': 'file://../spotfire-common', 'version': '3.0.0'}` |
| .dependencies[1] | Value changed | `{'name': 'haproxy', 'repository': 'https://haproxytech.github.io/helm-charts', 'version': '1.24.*', 'condition': 'haproxy.enabled'}` | `{'name': 'haproxy', 'repository': 'https://haproxytech.github.io/helm-charts', 'version': '1.26.*', 'condition': 'haproxy.enabled'}` |


### Chart spotfire-terrservice changes from 2.0.0 to 3.0.0

values.yaml

| Key | Comment | Old Value | New Value |
| --- | ------- | --------- | --------- |
| .image.tag | Value changed | `1.23.0-v4.0.0` | `1.24.0-v5.0.0` |
| .fluentBitSidecar.image.tag | Value changed | `4.0.7` | `4.1.0` |

Chart.yaml

| Key | Comment | Old Value | New Value |
| --- | ------- | --------- | --------- |
| .version | Value changed | `2.0.0` | `3.0.0` |
| .appVersion | Value changed | `1.23.0` | `1.24.0` |
| .dependencies[0].version | Value changed | `2.0.0` | `3.0.0` |


### Chart spotfire-webplayer changes from 2.0.0 to 3.0.0

values.yaml

| Key | Comment | Old Value | New Value |
| --- | ------- | --------- | --------- |
| .image.tag | Value changed | `14.6.0-v4.0.0` | `14.7.0-v5.0.0` |
| .fluentBitSidecar.image.tag | Value changed | `4.0.7` | `4.1.0` |

Chart.yaml

| Key | Comment | Old Value | New Value |
| --- | ------- | --------- | --------- |
| .version | Value changed | `2.0.0` | `3.0.0` |
| .appVersion | Value changed | `14.6.0` | `14.7.0` |
| .dependencies[0].version | Value changed | `2.0.0` | `3.0.0` |


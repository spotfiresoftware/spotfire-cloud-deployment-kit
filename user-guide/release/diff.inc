## Helm chart changes

### Chart spotfire-automationservices changes from 1.0.0 to 2.0.0

values.yaml

| Key | Comment | Old Value | New Value |
| --- | ------- | --------- | --------- |
| .image.tag | Value changed | `14.5.0-v3.0.0` | `14.6.0-v4.0.0` |
| .fluentBitSidecar.image.tag | Value changed | `3.2.8` | `4.0.7` |
| .fluentBitSidecar.resources | Dictionary item added |  |  |
| .volumes.certificates | Dictionary item added |  |  |

Chart.yaml

| Key | Comment | Old Value | New Value |
| --- | ------- | --------- | --------- |
| .version | Value changed | `1.0.0` | `2.0.0` |
| .appVersion | Value changed | `14.5.0` | `14.6.0` |
| .dependencies[0].version | Value changed | `1.0.0` | `2.0.0` |


### Chart spotfire-platform changes from 1.0.0 to 2.0.0

values.yaml

| Key | Comment | Old Value | New Value |
| --- | ------- | --------- | --------- |

Chart.yaml

| Key | Comment | Old Value | New Value |
| --- | ------- | --------- | --------- |
| .version | Value changed | `1.0.0` | `2.0.0` |
| .appVersion | Value changed | `14.5-v3.0.0` | `14.6-v4.0.0` |
| .dependencies[2] | Value changed | `{'name': 'spotfire-automationservices', 'repository': 'file://../spotfire-automationservices/', 'version': '1.0.0', 'condition': 'spotfire-automationservices.enabled'}` | `{'name': 'spotfire-automationservices', 'repository': 'file://../spotfire-automationservices/', 'version': '2.0.0', 'condition': 'spotfire-automationservices.enabled'}` |
| .dependencies[5] | Value changed | `{'name': 'spotfire-pythonservice', 'repository': 'file://../spotfire-pythonservice/', 'version': '1.0.0', 'condition': 'spotfire-pythonservice.enabled'}` | `{'name': 'spotfire-pythonservice', 'repository': 'file://../spotfire-pythonservice/', 'version': '2.0.0', 'condition': 'spotfire-pythonservice.enabled'}` |
| .dependencies[4] | Value changed | `{'name': 'spotfire-rservice', 'repository': 'file://../spotfire-rservice/', 'version': '1.0.0', 'condition': 'spotfire-rservice.enabled'}` | `{'name': 'spotfire-rservice', 'repository': 'file://../spotfire-rservice/', 'version': '2.0.0', 'condition': 'spotfire-rservice.enabled'}` |
| .dependencies[0] | Value changed | `{'name': 'spotfire-server', 'repository': 'file://../spotfire-server/', 'version': '1.0.0'}` | `{'name': 'spotfire-server', 'repository': 'file://../spotfire-server/', 'version': '2.0.0'}` |
| .dependencies[1] | Value changed | `{'name': 'spotfire-webplayer', 'repository': 'file://../spotfire-webplayer/', 'version': '1.0.0', 'condition': 'spotfire-webplayer.enabled'}` | `{'name': 'spotfire-webplayer', 'repository': 'file://../spotfire-webplayer/', 'version': '2.0.0', 'condition': 'spotfire-webplayer.enabled'}` |
| .dependencies[3] | Value changed | `{'name': 'spotfire-terrservice', 'repository': 'file://../spotfire-terrservice/', 'version': '1.0.0', 'condition': 'spotfire-terrservice.enabled'}` | `{'name': 'spotfire-terrservice', 'repository': 'file://../spotfire-terrservice/', 'version': '2.0.0', 'condition': 'spotfire-terrservice.enabled'}` |


### Chart spotfire-pythonservice changes from 1.0.0 to 2.0.0

values.yaml

| Key | Comment | Old Value | New Value |
| --- | ------- | --------- | --------- |
| .image.tag | Value changed | `1.22.0-v3.0.0` | `1.23.0-v4.0.0` |
| .fluentBitSidecar.image.tag | Value changed | `3.2.8` | `4.0.7` |
| .fluentBitSidecar.resources | Dictionary item added |  |  |
| .volumes.certificates | Dictionary item added |  |  |

Chart.yaml

| Key | Comment | Old Value | New Value |
| --- | ------- | --------- | --------- |
| .version | Value changed | `1.0.0` | `2.0.0` |
| .appVersion | Value changed | `1.22.0` | `1.23.0` |
| .dependencies[0].version | Value changed | `1.0.0` | `2.0.0` |


### Chart spotfire-rservice changes from 1.0.0 to 2.0.0

values.yaml

| Key | Comment | Old Value | New Value |
| --- | ------- | --------- | --------- |
| .image.tag | Value changed | `1.22.0-v3.0.0` | `1.23.0-v4.0.0` |
| .fluentBitSidecar.image.tag | Value changed | `3.2.8` | `4.0.7` |
| .fluentBitSidecar.resources | Dictionary item added |  |  |
| .volumes.certificates | Dictionary item added |  |  |

Chart.yaml

| Key | Comment | Old Value | New Value |
| --- | ------- | --------- | --------- |
| .version | Value changed | `1.0.0` | `2.0.0` |
| .appVersion | Value changed | `1.22.0` | `1.23.0` |
| .dependencies[0].version | Value changed | `1.0.0` | `2.0.0` |


### Chart spotfire-server changes from 1.0.0 to 2.0.0

values.yaml

| Key | Comment | Old Value | New Value |
| --- | ------- | --------- | --------- |
| .image.tag | Value changed | `14.5.0-v3.0.0` | `14.6.0-v4.0.0` |
| .fluentBitSidecar.image.tag | Value changed | `3.2.8` | `4.0.7` |
| .cliPod.image.tag | Value changed | `14.5.0-v3.0.0` | `14.6.0-v4.0.0` |
| .configJob.image.tag | Value changed | `14.5.0-v3.0.0` | `14.6.0-v4.0.0` |
| .configuration.deployment.defaultDeployment.image.tag | Value changed | `14.5.0-v3.0.0` | `14.6.0-v4.0.0` |
| .fluentBitSidecar.resources | Dictionary item added |  |  |
| .cliPod.resources | Dictionary item added |  |  |
| .configJob.resources | Dictionary item added |  |  |
| .haproxy.spotfireConfig.globals | Dictionary item added |  |  |

Chart.yaml

| Key | Comment | Old Value | New Value |
| --- | ------- | --------- | --------- |
| .version | Value changed | `1.0.0` | `2.0.0` |
| .appVersion | Value changed | `14.5.0` | `14.6.0` |
| .dependencies[0].version | Value changed | `0.48.*` | `0.52.*` |
| .dependencies[2].version | Value changed | `1.0.0` | `2.0.0` |


### Chart spotfire-terrservice changes from 1.0.0 to 2.0.0

values.yaml

| Key | Comment | Old Value | New Value |
| --- | ------- | --------- | --------- |
| .image.tag | Value changed | `1.22.0-v3.0.0` | `1.23.0-v4.0.0` |
| .fluentBitSidecar.image.tag | Value changed | `3.2.8` | `4.0.7` |
| .fluentBitSidecar.resources | Dictionary item added |  |  |
| .volumes.certificates | Dictionary item added |  |  |

Chart.yaml

| Key | Comment | Old Value | New Value |
| --- | ------- | --------- | --------- |
| .version | Value changed | `1.0.0` | `2.0.0` |
| .appVersion | Value changed | `1.22.0` | `1.23.0` |
| .dependencies[0].version | Value changed | `1.0.0` | `2.0.0` |


### Chart spotfire-webplayer changes from 1.0.0 to 2.0.0

values.yaml

| Key | Comment | Old Value | New Value |
| --- | ------- | --------- | --------- |
| .image.tag | Value changed | `14.5.0-v3.0.0` | `14.6.0-v4.0.0` |
| .fluentBitSidecar.image.tag | Value changed | `3.2.8` | `4.0.7` |
| .fluentBitSidecar.resources | Dictionary item added |  |  |
| .volumes.certificates | Dictionary item added |  |  |

Chart.yaml

| Key | Comment | Old Value | New Value |
| --- | ------- | --------- | --------- |
| .version | Value changed | `1.0.0` | `2.0.0` |
| .appVersion | Value changed | `14.5.0` | `14.6.0` |
| .dependencies[0].version | Value changed | `1.0.0` | `2.0.0` |


## Helm chart changes

### Chart spotfire-automationservices changes from 2.0.0 to 2.0.2

values.yaml

| Key | Comment | Old Value | New Value |
| --- | ------- | --------- | --------- |
| .image.tag | Value changed | `14.6.0-v4.0.0` | `14.6.0-HF-002-v4.0.2` |

Chart.yaml

| Key | Comment | Old Value | New Value |
| --- | ------- | --------- | --------- |
| .version | Value changed | `2.0.0` | `2.0.2` |
| .appVersion | Value changed | `14.6.0` | `14.6.0-HF-002` |
| .dependencies[0].version | Value changed | `2.0.0` | `2.0.2` |


### Chart spotfire-platform changes from 2.0.0 to 2.0.2

values.yaml

| Key | Comment | Old Value | New Value |
| --- | ------- | --------- | --------- |
| .postgresql.image | Dictionary item added |  |  |
| .postgresql.primary | Dictionary item added |  |  |

Chart.yaml

| Key | Comment | Old Value | New Value |
| --- | ------- | --------- | --------- |
| .version | Value changed | `2.0.0` | `2.0.2` |
| .appVersion | Value changed | `14.6-v4.0.0` | `14.6-v4.0.2` |
| .dependencies[2] | Value changed | `{'name': 'spotfire-automationservices', 'repository': 'file://../spotfire-automationservices/', 'version': '2.0.0', 'condition': 'spotfire-automationservices.enabled'}` | `{'name': 'spotfire-automationservices', 'repository': 'file://../spotfire-automationservices/', 'version': '2.0.2', 'condition': 'spotfire-automationservices.enabled'}` |
| .dependencies[0] | Value changed | `{'name': 'spotfire-server', 'repository': 'file://../spotfire-server/', 'version': '2.0.0'}` | `{'name': 'spotfire-server', 'repository': 'file://../spotfire-server/', 'version': '2.0.2'}` |
| .dependencies[1] | Value changed | `{'name': 'spotfire-webplayer', 'repository': 'file://../spotfire-webplayer/', 'version': '2.0.0', 'condition': 'spotfire-webplayer.enabled'}` | `{'name': 'spotfire-webplayer', 'repository': 'file://../spotfire-webplayer/', 'version': '2.0.2', 'condition': 'spotfire-webplayer.enabled'}` |
| .dependencies[4] | Value changed | `{'name': 'spotfire-rservice', 'repository': 'file://../spotfire-rservice/', 'version': '2.0.0', 'condition': 'spotfire-rservice.enabled'}` | `{'name': 'spotfire-rservice', 'repository': 'file://../spotfire-rservice/', 'version': '2.0.2', 'condition': 'spotfire-rservice.enabled'}` |
| .dependencies[5] | Value changed | `{'name': 'spotfire-pythonservice', 'repository': 'file://../spotfire-pythonservice/', 'version': '2.0.0', 'condition': 'spotfire-pythonservice.enabled'}` | `{'name': 'spotfire-pythonservice', 'repository': 'file://../spotfire-pythonservice/', 'version': '2.0.2', 'condition': 'spotfire-pythonservice.enabled'}` |
| .dependencies[3] | Value changed | `{'name': 'spotfire-terrservice', 'repository': 'file://../spotfire-terrservice/', 'version': '2.0.0', 'condition': 'spotfire-terrservice.enabled'}` | `{'name': 'spotfire-terrservice', 'repository': 'file://../spotfire-terrservice/', 'version': '2.0.2', 'condition': 'spotfire-terrservice.enabled'}` |


### Chart spotfire-pythonservice changes from 2.0.0 to 2.0.2

values.yaml

| Key | Comment | Old Value | New Value |
| --- | ------- | --------- | --------- |
| .image.tag | Value changed | `1.23.0-v4.0.0` | `1.23.0-v4.0.2` |

Chart.yaml

| Key | Comment | Old Value | New Value |
| --- | ------- | --------- | --------- |
| .version | Value changed | `2.0.0` | `2.0.2` |
| .dependencies[0].version | Value changed | `2.0.0` | `2.0.2` |


### Chart spotfire-rservice changes from 2.0.0 to 2.0.2

values.yaml

| Key | Comment | Old Value | New Value |
| --- | ------- | --------- | --------- |
| .image.tag | Value changed | `1.23.0-v4.0.0` | `1.23.0-v4.0.2` |

Chart.yaml

| Key | Comment | Old Value | New Value |
| --- | ------- | --------- | --------- |
| .version | Value changed | `2.0.0` | `2.0.2` |
| .dependencies[0].version | Value changed | `2.0.0` | `2.0.2` |


### Chart spotfire-server changes from 2.0.0 to 2.0.2

values.yaml

| Key | Comment | Old Value | New Value |
| --- | ------- | --------- | --------- |
| .image.tag | Value changed | `14.6.0-v4.0.0` | `14.6.0-v4.0.2` |
| .cliPod.image.tag | Value changed | `14.6.0-v4.0.0` | `14.6.0-v4.0.2` |
| .configJob.image.tag | Value changed | `14.6.0-v4.0.0` | `14.6.0-v4.0.2` |
| .configuration.deployment.defaultDeployment.image.tag | Value changed | `14.6.0-v4.0.0` | `14.6.0-HF-002-v4.0.2` |
| .configuration.deployment.defaultDeployment.resources | Dictionary item added |  |  |

Chart.yaml

| Key | Comment | Old Value | New Value |
| --- | ------- | --------- | --------- |
| .version | Value changed | `2.0.0` | `2.0.2` |
| .dependencies[2].version | Value changed | `2.0.0` | `2.0.2` |


### Chart spotfire-terrservice changes from 2.0.0 to 2.0.2

values.yaml

| Key | Comment | Old Value | New Value |
| --- | ------- | --------- | --------- |
| .image.tag | Value changed | `1.23.0-v4.0.0` | `1.23.0-v4.0.2` |

Chart.yaml

| Key | Comment | Old Value | New Value |
| --- | ------- | --------- | --------- |
| .version | Value changed | `2.0.0` | `2.0.2` |
| .dependencies[0].version | Value changed | `2.0.0` | `2.0.2` |


### Chart spotfire-webplayer changes from 2.0.0 to 2.0.2

values.yaml

| Key | Comment | Old Value | New Value |
| --- | ------- | --------- | --------- |
| .image.tag | Value changed | `14.6.0-v4.0.0` | `14.6.0-HF-002-v4.0.2` |

Chart.yaml

| Key | Comment | Old Value | New Value |
| --- | ------- | --------- | --------- |
| .version | Value changed | `2.0.0` | `2.0.2` |
| .appVersion | Value changed | `14.6.0` | `14.6.0-HF-002` |
| .dependencies[0].version | Value changed | `2.0.0` | `2.0.2` |


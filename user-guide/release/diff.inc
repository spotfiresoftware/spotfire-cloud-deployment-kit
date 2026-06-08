## Helm chart changes

### Chart spotfire-automationservices changes from 4.0.2 to 4.0.3

values.yaml

| Key | Comment | Old Value | New Value |
| --- | ------- | --------- | --------- |
| .image.tag | Value changed | `14.8.0-HF-002-v6.0.2` | `14.8.0-HF-003-v6.0.3` |

Chart.yaml

| Key | Comment | Old Value | New Value |
| --- | ------- | --------- | --------- |
| .version | Value changed | `4.0.2` | `4.0.3` |
| .appVersion | Value changed | `14.8.0-HF-002` | `14.8.0-HF-003` |
| .dependencies[0].version | Value changed | `4.0.2` | `4.0.3` |


### Chart spotfire-platform changes from 4.0.2 to 4.0.3

values.yaml

| Key | Comment | Old Value | New Value |
| --- | ------- | --------- | --------- |

Chart.yaml

| Key | Comment | Old Value | New Value |
| --- | ------- | --------- | --------- |
| .version | Value changed | `4.0.2` | `4.0.3` |
| .appVersion | Value changed | `14.8-v6.0.2` | `14.8-v6.0.3` |
| .dependencies[5] | Value changed | `{'name': 'spotfire-pythonservice', 'repository': 'file://../spotfire-pythonservice/', 'version': '4.0.2', 'condition': 'spotfire-pythonservice.enabled'}` | `{'name': 'spotfire-pythonservice', 'repository': 'file://../spotfire-pythonservice/', 'version': '4.0.3', 'condition': 'spotfire-pythonservice.enabled'}` |
| .dependencies[3] | Value changed | `{'name': 'spotfire-terrservice', 'repository': 'file://../spotfire-terrservice/', 'version': '4.0.2', 'condition': 'spotfire-terrservice.enabled'}` | `{'name': 'spotfire-terrservice', 'repository': 'file://../spotfire-terrservice/', 'version': '4.0.3', 'condition': 'spotfire-terrservice.enabled'}` |
| .dependencies[4] | Value changed | `{'name': 'spotfire-rservice', 'repository': 'file://../spotfire-rservice/', 'version': '4.0.2', 'condition': 'spotfire-rservice.enabled'}` | `{'name': 'spotfire-rservice', 'repository': 'file://../spotfire-rservice/', 'version': '4.0.3', 'condition': 'spotfire-rservice.enabled'}` |
| .dependencies[2] | Value changed | `{'name': 'spotfire-automationservices', 'repository': 'file://../spotfire-automationservices/', 'version': '4.0.2', 'condition': 'spotfire-automationservices.enabled'}` | `{'name': 'spotfire-automationservices', 'repository': 'file://../spotfire-automationservices/', 'version': '4.0.3', 'condition': 'spotfire-automationservices.enabled'}` |
| .dependencies[1] | Value changed | `{'name': 'spotfire-webplayer', 'repository': 'file://../spotfire-webplayer/', 'version': '4.0.2', 'condition': 'spotfire-webplayer.enabled'}` | `{'name': 'spotfire-webplayer', 'repository': 'file://../spotfire-webplayer/', 'version': '4.0.3', 'condition': 'spotfire-webplayer.enabled'}` |
| .dependencies[0] | Value changed | `{'name': 'spotfire-server', 'repository': 'file://../spotfire-server/', 'version': '4.0.2'}` | `{'name': 'spotfire-server', 'repository': 'file://../spotfire-server/', 'version': '4.0.3'}` |


### Chart spotfire-pythonservice changes from 4.0.2 to 4.0.3

values.yaml

| Key | Comment | Old Value | New Value |
| --- | ------- | --------- | --------- |
| .image.tag | Value changed | `1.25.0-v6.0.2` | `1.25.0-v6.0.3` |

Chart.yaml

| Key | Comment | Old Value | New Value |
| --- | ------- | --------- | --------- |
| .version | Value changed | `4.0.2` | `4.0.3` |
| .dependencies[0].version | Value changed | `4.0.2` | `4.0.3` |


### Chart spotfire-rservice changes from 4.0.2 to 4.0.3

values.yaml

| Key | Comment | Old Value | New Value |
| --- | ------- | --------- | --------- |
| .image.tag | Value changed | `1.25.0-v6.0.2` | `1.25.0-v6.0.3` |

Chart.yaml

| Key | Comment | Old Value | New Value |
| --- | ------- | --------- | --------- |
| .version | Value changed | `4.0.2` | `4.0.3` |
| .dependencies[0].version | Value changed | `4.0.2` | `4.0.3` |


### Chart spotfire-server changes from 4.0.2 to 4.0.3

values.yaml

| Key | Comment | Old Value | New Value |
| --- | ------- | --------- | --------- |
| .image.tag | Value changed | `14.8.0-v6.0.2` | `14.8.0-v6.0.3` |
| .cliPod.image.tag | Value changed | `14.8.0-v6.0.2` | `14.8.0-v6.0.3` |
| .configJob.image.tag | Value changed | `14.8.0-v6.0.2` | `14.8.0-v6.0.3` |
| .configuration.deployment.defaultDeployment.image.tag | Value changed | `14.8.0-HF-002-v6.0.2` | `14.8.0-HF-003-v6.0.3` |

Chart.yaml

| Key | Comment | Old Value | New Value |
| --- | ------- | --------- | --------- |
| .version | Value changed | `4.0.2` | `4.0.3` |
| .dependencies[2].version | Value changed | `4.0.2` | `4.0.3` |


### Chart spotfire-terrservice changes from 4.0.2 to 4.0.3

values.yaml

| Key | Comment | Old Value | New Value |
| --- | ------- | --------- | --------- |
| .image.tag | Value changed | `1.25.0-v6.0.2` | `1.25.0-v6.0.3` |

Chart.yaml

| Key | Comment | Old Value | New Value |
| --- | ------- | --------- | --------- |
| .version | Value changed | `4.0.2` | `4.0.3` |
| .dependencies[0].version | Value changed | `4.0.2` | `4.0.3` |


### Chart spotfire-webplayer changes from 4.0.2 to 4.0.3

values.yaml

| Key | Comment | Old Value | New Value |
| --- | ------- | --------- | --------- |
| .image.tag | Value changed | `14.8.0-HF-002-v6.0.2` | `14.8.0-HF-003-v6.0.3` |

Chart.yaml

| Key | Comment | Old Value | New Value |
| --- | ------- | --------- | --------- |
| .version | Value changed | `4.0.2` | `4.0.3` |
| .appVersion | Value changed | `14.8.0-HF-002` | `14.8.0-HF-003` |
| .dependencies[0].version | Value changed | `4.0.2` | `4.0.3` |


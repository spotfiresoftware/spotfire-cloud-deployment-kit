## Helm chart changes

### Chart spotfire-automationservices changes from 2.2.3 to 2.2.4

values.yaml

| Key | Comment | Old Value | New Value |
| --- | ------- | --------- | --------- |
| .image.tag | Value changed | `14.6.2-HF-011-v4.2.3` | `14.6.2-HF-012-v4.2.4` |

Chart.yaml

| Key | Comment | Old Value | New Value |
| --- | ------- | --------- | --------- |
| .version | Value changed | `2.2.3` | `2.2.4` |
| .appVersion | Value changed | `14.6.2-HF-011` | `14.6.2-HF-012` |
| .dependencies[0].version | Value changed | `2.2.3` | `2.2.4` |


### Chart spotfire-platform changes from 2.2.3 to 2.2.4

values.yaml

| Key | Comment | Old Value | New Value |
| --- | ------- | --------- | --------- |

Chart.yaml

| Key | Comment | Old Value | New Value |
| --- | ------- | --------- | --------- |
| .version | Value changed | `2.2.3` | `2.2.4` |
| .appVersion | Value changed | `14.6-v4.2.3` | `14.6-v4.2.4` |
| .dependencies[4] | Value changed | `{'name': 'spotfire-rservice', 'repository': 'file://../spotfire-rservice/', 'version': '2.2.3', 'condition': 'spotfire-rservice.enabled'}` | `{'name': 'spotfire-rservice', 'repository': 'file://../spotfire-rservice/', 'version': '2.2.4', 'condition': 'spotfire-rservice.enabled'}` |
| .dependencies[0] | Value changed | `{'name': 'spotfire-server', 'repository': 'file://../spotfire-server/', 'version': '2.2.3'}` | `{'name': 'spotfire-server', 'repository': 'file://../spotfire-server/', 'version': '2.2.4'}` |
| .dependencies[5] | Value changed | `{'name': 'spotfire-pythonservice', 'repository': 'file://../spotfire-pythonservice/', 'version': '2.2.3', 'condition': 'spotfire-pythonservice.enabled'}` | `{'name': 'spotfire-pythonservice', 'repository': 'file://../spotfire-pythonservice/', 'version': '2.2.4', 'condition': 'spotfire-pythonservice.enabled'}` |
| .dependencies[3] | Value changed | `{'name': 'spotfire-terrservice', 'repository': 'file://../spotfire-terrservice/', 'version': '2.2.3', 'condition': 'spotfire-terrservice.enabled'}` | `{'name': 'spotfire-terrservice', 'repository': 'file://../spotfire-terrservice/', 'version': '2.2.4', 'condition': 'spotfire-terrservice.enabled'}` |
| .dependencies[2] | Value changed | `{'name': 'spotfire-automationservices', 'repository': 'file://../spotfire-automationservices/', 'version': '2.2.3', 'condition': 'spotfire-automationservices.enabled'}` | `{'name': 'spotfire-automationservices', 'repository': 'file://../spotfire-automationservices/', 'version': '2.2.4', 'condition': 'spotfire-automationservices.enabled'}` |
| .dependencies[1] | Value changed | `{'name': 'spotfire-webplayer', 'repository': 'file://../spotfire-webplayer/', 'version': '2.2.3', 'condition': 'spotfire-webplayer.enabled'}` | `{'name': 'spotfire-webplayer', 'repository': 'file://../spotfire-webplayer/', 'version': '2.2.4', 'condition': 'spotfire-webplayer.enabled'}` |


### Chart spotfire-pythonservice changes from 2.2.3 to 2.2.4

values.yaml

| Key | Comment | Old Value | New Value |
| --- | ------- | --------- | --------- |
| .image.tag | Value changed | `1.23.2-v4.2.3` | `1.23.2-v4.2.4` |

Chart.yaml

| Key | Comment | Old Value | New Value |
| --- | ------- | --------- | --------- |
| .version | Value changed | `2.2.3` | `2.2.4` |
| .dependencies[0].version | Value changed | `2.2.3` | `2.2.4` |


### Chart spotfire-rservice changes from 2.2.3 to 2.2.4

values.yaml

| Key | Comment | Old Value | New Value |
| --- | ------- | --------- | --------- |
| .image.tag | Value changed | `1.23.2-v4.2.3` | `1.23.2-v4.2.4` |

Chart.yaml

| Key | Comment | Old Value | New Value |
| --- | ------- | --------- | --------- |
| .version | Value changed | `2.2.3` | `2.2.4` |
| .dependencies[0].version | Value changed | `2.2.3` | `2.2.4` |


### Chart spotfire-server changes from 2.2.3 to 2.2.4

values.yaml

| Key | Comment | Old Value | New Value |
| --- | ------- | --------- | --------- |
| .image.tag | Value changed | `14.6.2-v4.2.3` | `14.6.2-v4.2.4` |
| .cliPod.image.tag | Value changed | `14.6.2-v4.2.3` | `14.6.2-v4.2.4` |
| .configJob.image.tag | Value changed | `14.6.2-v4.2.3` | `14.6.2-v4.2.4` |
| .configuration.deployment.defaultDeployment.image.tag | Value changed | `14.6.2-HF-011-v4.2.3` | `14.6.2-HF-012-v4.2.4` |

Chart.yaml

| Key | Comment | Old Value | New Value |
| --- | ------- | --------- | --------- |
| .version | Value changed | `2.2.3` | `2.2.4` |
| .dependencies[2].version | Value changed | `2.2.3` | `2.2.4` |


### Chart spotfire-terrservice changes from 2.2.3 to 2.2.4

values.yaml

| Key | Comment | Old Value | New Value |
| --- | ------- | --------- | --------- |
| .image.tag | Value changed | `1.23.2-v4.2.3` | `1.23.2-v4.2.4` |

Chart.yaml

| Key | Comment | Old Value | New Value |
| --- | ------- | --------- | --------- |
| .version | Value changed | `2.2.3` | `2.2.4` |
| .dependencies[0].version | Value changed | `2.2.3` | `2.2.4` |


### Chart spotfire-webplayer changes from 2.2.3 to 2.2.4

values.yaml

| Key | Comment | Old Value | New Value |
| --- | ------- | --------- | --------- |
| .image.tag | Value changed | `14.6.2-HF-011-v4.2.3` | `14.6.2-HF-012-v4.2.4` |

Chart.yaml

| Key | Comment | Old Value | New Value |
| --- | ------- | --------- | --------- |
| .version | Value changed | `2.2.3` | `2.2.4` |
| .appVersion | Value changed | `14.6.2-HF-011` | `14.6.2-HF-012` |
| .dependencies[0].version | Value changed | `2.2.3` | `2.2.4` |


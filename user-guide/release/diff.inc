## Helm chart changes

### Chart spotfire-automationservices changes from 2.3.0 to 2.3.1

values.yaml

| Key | Comment | Old Value | New Value |
| --- | ------- | --------- | --------- |
| .image.tag | Value changed | `14.6.3-v4.3.0` | `14.6.3-HF-014-v4.3.1` |

Chart.yaml

| Key | Comment | Old Value | New Value |
| --- | ------- | --------- | --------- |
| .version | Value changed | `2.3.0` | `2.3.1` |
| .appVersion | Value changed | `14.6.3` | `14.6.3-HF-014` |
| .dependencies[0].version | Value changed | `2.3.0` | `2.3.1` |


### Chart spotfire-platform changes from 2.3.0 to 2.3.1

values.yaml

| Key | Comment | Old Value | New Value |
| --- | ------- | --------- | --------- |

Chart.yaml

| Key | Comment | Old Value | New Value |
| --- | ------- | --------- | --------- |
| .version | Value changed | `2.3.0` | `2.3.1` |
| .appVersion | Value changed | `14.6-v4.3.0` | `14.6-v4.3.1` |
| .dependencies[2] | Value changed | `{'name': 'spotfire-automationservices', 'repository': 'file://../spotfire-automationservices/', 'version': '2.3.0', 'condition': 'spotfire-automationservices.enabled'}` | `{'name': 'spotfire-automationservices', 'repository': 'file://../spotfire-automationservices/', 'version': '2.3.1', 'condition': 'spotfire-automationservices.enabled'}` |
| .dependencies[3] | Value changed | `{'name': 'spotfire-terrservice', 'repository': 'file://../spotfire-terrservice/', 'version': '2.3.0', 'condition': 'spotfire-terrservice.enabled'}` | `{'name': 'spotfire-terrservice', 'repository': 'file://../spotfire-terrservice/', 'version': '2.3.1', 'condition': 'spotfire-terrservice.enabled'}` |
| .dependencies[4] | Value changed | `{'name': 'spotfire-rservice', 'repository': 'file://../spotfire-rservice/', 'version': '2.3.0', 'condition': 'spotfire-rservice.enabled'}` | `{'name': 'spotfire-rservice', 'repository': 'file://../spotfire-rservice/', 'version': '2.3.1', 'condition': 'spotfire-rservice.enabled'}` |
| .dependencies[5] | Value changed | `{'name': 'spotfire-pythonservice', 'repository': 'file://../spotfire-pythonservice/', 'version': '2.3.0', 'condition': 'spotfire-pythonservice.enabled'}` | `{'name': 'spotfire-pythonservice', 'repository': 'file://../spotfire-pythonservice/', 'version': '2.3.1', 'condition': 'spotfire-pythonservice.enabled'}` |
| .dependencies[1] | Value changed | `{'name': 'spotfire-webplayer', 'repository': 'file://../spotfire-webplayer/', 'version': '2.3.0', 'condition': 'spotfire-webplayer.enabled'}` | `{'name': 'spotfire-webplayer', 'repository': 'file://../spotfire-webplayer/', 'version': '2.3.1', 'condition': 'spotfire-webplayer.enabled'}` |
| .dependencies[0] | Value changed | `{'name': 'spotfire-server', 'repository': 'file://../spotfire-server/', 'version': '2.3.0'}` | `{'name': 'spotfire-server', 'repository': 'file://../spotfire-server/', 'version': '2.3.1'}` |


### Chart spotfire-pythonservice changes from 2.3.0 to 2.3.1

values.yaml

| Key | Comment | Old Value | New Value |
| --- | ------- | --------- | --------- |
| .image.tag | Value changed | `14.6.3-v4.3.0` | `14.6.3-v4.3.1` |

Chart.yaml

| Key | Comment | Old Value | New Value |
| --- | ------- | --------- | --------- |
| .version | Value changed | `2.3.0` | `2.3.1` |
| .dependencies[0].version | Value changed | `2.3.0` | `2.3.1` |


### Chart spotfire-rservice changes from 2.3.0 to 2.3.1

values.yaml

| Key | Comment | Old Value | New Value |
| --- | ------- | --------- | --------- |
| .image.tag | Value changed | `14.6.3-v4.3.0` | `14.6.3-v4.3.1` |

Chart.yaml

| Key | Comment | Old Value | New Value |
| --- | ------- | --------- | --------- |
| .version | Value changed | `2.3.0` | `2.3.1` |
| .dependencies[0].version | Value changed | `2.3.0` | `2.3.1` |


### Chart spotfire-server changes from 2.3.0 to 2.3.1

values.yaml

| Key | Comment | Old Value | New Value |
| --- | ------- | --------- | --------- |
| .image.tag | Value changed | `14.6.3-v4.3.0` | `14.6.3-v4.3.1` |
| .cliPod.image.tag | Value changed | `14.6.3-v4.3.0` | `14.6.3-v4.3.1` |
| .configJob.image.tag | Value changed | `14.6.3-v4.3.0` | `14.6.3-v4.3.1` |
| .configuration.deployment.defaultDeployment.image.tag | Value changed | `14.6.3-v4.3.0` | `14.6.3-HF-014-v4.3.1` |

Chart.yaml

| Key | Comment | Old Value | New Value |
| --- | ------- | --------- | --------- |
| .version | Value changed | `2.3.0` | `2.3.1` |
| .dependencies[2].version | Value changed | `2.3.0` | `2.3.1` |


### Chart spotfire-terrservice changes from 2.3.0 to 2.3.1

values.yaml

| Key | Comment | Old Value | New Value |
| --- | ------- | --------- | --------- |
| .image.tag | Value changed | `14.6.3-v4.3.0` | `14.6.3-v4.3.1` |

Chart.yaml

| Key | Comment | Old Value | New Value |
| --- | ------- | --------- | --------- |
| .version | Value changed | `2.3.0` | `2.3.1` |
| .dependencies[0].version | Value changed | `2.3.0` | `2.3.1` |


### Chart spotfire-webplayer changes from 2.3.0 to 2.3.1

values.yaml

| Key | Comment | Old Value | New Value |
| --- | ------- | --------- | --------- |
| .image.tag | Value changed | `14.6.3-v4.3.0` | `14.6.3-HF-014-v4.3.1` |

Chart.yaml

| Key | Comment | Old Value | New Value |
| --- | ------- | --------- | --------- |
| .version | Value changed | `2.3.0` | `2.3.1` |
| .appVersion | Value changed | `14.6.3` | `14.6.3-HF-014` |
| .dependencies[0].version | Value changed | `2.3.0` | `2.3.1` |


## Helm chart changes

### Chart spotfire-automationservices changes from 2.2.1 to 2.2.2

values.yaml

| Key | Comment | Old Value | New Value |
| --- | ------- | --------- | --------- |
| .image.tag | Value changed | `14.6.2-HF-009-v4.2.1` | `14.6.2-HF-010-v4.2.2` |

Chart.yaml

| Key | Comment | Old Value | New Value |
| --- | ------- | --------- | --------- |
| .version | Value changed | `2.2.1` | `2.2.2` |
| .appVersion | Value changed | `14.6.2-HF-009` | `14.6.2-HF-010` |
| .dependencies[0].version | Value changed | `2.2.1` | `2.2.2` |


### Chart spotfire-platform changes from 2.2.1 to 2.2.2

values.yaml

| Key | Comment | Old Value | New Value |
| --- | ------- | --------- | --------- |

Chart.yaml

| Key | Comment | Old Value | New Value |
| --- | ------- | --------- | --------- |
| .version | Value changed | `2.2.1` | `2.2.2` |
| .appVersion | Value changed | `14.6-v4.2.1` | `14.6-v4.2.2` |
| .dependencies[3] | Value changed | `{'name': 'spotfire-terrservice', 'repository': 'file://../spotfire-terrservice/', 'version': '2.2.1', 'condition': 'spotfire-terrservice.enabled'}` | `{'name': 'spotfire-terrservice', 'repository': 'file://../spotfire-terrservice/', 'version': '2.2.2', 'condition': 'spotfire-terrservice.enabled'}` |
| .dependencies[2] | Value changed | `{'name': 'spotfire-automationservices', 'repository': 'file://../spotfire-automationservices/', 'version': '2.2.1', 'condition': 'spotfire-automationservices.enabled'}` | `{'name': 'spotfire-automationservices', 'repository': 'file://../spotfire-automationservices/', 'version': '2.2.2', 'condition': 'spotfire-automationservices.enabled'}` |
| .dependencies[1] | Value changed | `{'name': 'spotfire-webplayer', 'repository': 'file://../spotfire-webplayer/', 'version': '2.2.1', 'condition': 'spotfire-webplayer.enabled'}` | `{'name': 'spotfire-webplayer', 'repository': 'file://../spotfire-webplayer/', 'version': '2.2.2', 'condition': 'spotfire-webplayer.enabled'}` |
| .dependencies[4] | Value changed | `{'name': 'spotfire-rservice', 'repository': 'file://../spotfire-rservice/', 'version': '2.2.1', 'condition': 'spotfire-rservice.enabled'}` | `{'name': 'spotfire-rservice', 'repository': 'file://../spotfire-rservice/', 'version': '2.2.2', 'condition': 'spotfire-rservice.enabled'}` |
| .dependencies[5] | Value changed | `{'name': 'spotfire-pythonservice', 'repository': 'file://../spotfire-pythonservice/', 'version': '2.2.1', 'condition': 'spotfire-pythonservice.enabled'}` | `{'name': 'spotfire-pythonservice', 'repository': 'file://../spotfire-pythonservice/', 'version': '2.2.2', 'condition': 'spotfire-pythonservice.enabled'}` |
| .dependencies[0] | Value changed | `{'name': 'spotfire-server', 'repository': 'file://../spotfire-server/', 'version': '2.2.1'}` | `{'name': 'spotfire-server', 'repository': 'file://../spotfire-server/', 'version': '2.2.2'}` |


### Chart spotfire-pythonservice changes from 2.2.1 to 2.2.2

values.yaml

| Key | Comment | Old Value | New Value |
| --- | ------- | --------- | --------- |
| .image.tag | Value changed | `1.23.2-v4.2.1` | `1.23.2-v4.2.2` |

Chart.yaml

| Key | Comment | Old Value | New Value |
| --- | ------- | --------- | --------- |
| .version | Value changed | `2.2.1` | `2.2.2` |
| .dependencies[0].version | Value changed | `2.2.1` | `2.2.2` |


### Chart spotfire-rservice changes from 2.2.1 to 2.2.2

values.yaml

| Key | Comment | Old Value | New Value |
| --- | ------- | --------- | --------- |
| .image.tag | Value changed | `1.23.2-v4.2.1` | `1.23.2-v4.2.2` |

Chart.yaml

| Key | Comment | Old Value | New Value |
| --- | ------- | --------- | --------- |
| .version | Value changed | `2.2.1` | `2.2.2` |
| .dependencies[0].version | Value changed | `2.2.1` | `2.2.2` |


### Chart spotfire-server changes from 2.2.1 to 2.2.2

values.yaml

| Key | Comment | Old Value | New Value |
| --- | ------- | --------- | --------- |
| .image.tag | Value changed | `14.6.2-v4.2.1` | `14.6.2-v4.2.2` |
| .cliPod.image.tag | Value changed | `14.6.2-v4.2.1` | `14.6.2-v4.2.2` |
| .configJob.image.tag | Value changed | `14.6.2-v4.2.1` | `14.6.2-v4.2.2` |
| .configuration.deployment.defaultDeployment.image.tag | Value changed | `14.6.2-HF-009-v4.2.1` | `14.6.2-HF-010-v4.2.2` |

Chart.yaml

| Key | Comment | Old Value | New Value |
| --- | ------- | --------- | --------- |
| .version | Value changed | `2.2.1` | `2.2.2` |
| .dependencies[2].version | Value changed | `2.2.1` | `2.2.2` |


### Chart spotfire-terrservice changes from 2.2.1 to 2.2.2

values.yaml

| Key | Comment | Old Value | New Value |
| --- | ------- | --------- | --------- |
| .image.tag | Value changed | `1.23.2-v4.2.1` | `1.23.2-v4.2.2` |

Chart.yaml

| Key | Comment | Old Value | New Value |
| --- | ------- | --------- | --------- |
| .version | Value changed | `2.2.1` | `2.2.2` |
| .dependencies[0].version | Value changed | `2.2.1` | `2.2.2` |


### Chart spotfire-webplayer changes from 2.2.1 to 2.2.2

values.yaml

| Key | Comment | Old Value | New Value |
| --- | ------- | --------- | --------- |
| .image.tag | Value changed | `14.6.2-HF-009-v4.2.1` | `14.6.2-HF-010-v4.2.2` |

Chart.yaml

| Key | Comment | Old Value | New Value |
| --- | ------- | --------- | --------- |
| .version | Value changed | `2.2.1` | `2.2.2` |
| .appVersion | Value changed | `14.6.2-HF-009` | `14.6.2-HF-010` |
| .dependencies[0].version | Value changed | `2.2.1` | `2.2.2` |


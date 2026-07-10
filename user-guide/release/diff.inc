## Helm chart changes

### Chart spotfire-automationservices changes from 5.0.0 to 5.0.1

values.yaml

| Key | Comment | Old Value | New Value |
| --- | ------- | --------- | --------- |
| .image.tag | Value changed | `15.0.0-v7.0.0` | `15.0.0-HF-001-v7.0.1` |
| .podDeletionCost.image.tag | Value changed | `15.0.0-v7.0.0` | `15.0.0-v7.0.1` |

Chart.yaml

| Key | Comment | Old Value | New Value |
| --- | ------- | --------- | --------- |
| .version | Value changed | `5.0.0` | `5.0.1` |
| .appVersion | Value changed | `15.0.0` | `15.0.0-HF-001` |
| .dependencies[0].version | Value changed | `5.0.0` | `5.0.1` |


### Chart spotfire-platform changes from 5.0.0 to 5.0.1

values.yaml

| Key | Comment | Old Value | New Value |
| --- | ------- | --------- | --------- |

Chart.yaml

| Key | Comment | Old Value | New Value |
| --- | ------- | --------- | --------- |
| .version | Value changed | `5.0.0` | `5.0.1` |
| .appVersion | Value changed | `15.0-v7.0.0` | `15.0-v7.0.1` |
| .dependencies[0] | Value changed | `{'name': 'spotfire-server', 'repository': 'file://../spotfire-server/', 'version': '5.0.0'}` | `{'name': 'spotfire-server', 'repository': 'file://../spotfire-server/', 'version': '5.0.1'}` |
| .dependencies[2] | Value changed | `{'name': 'spotfire-automationservices', 'repository': 'file://../spotfire-automationservices/', 'version': '5.0.0', 'condition': 'spotfire-automationservices.enabled'}` | `{'name': 'spotfire-automationservices', 'repository': 'file://../spotfire-automationservices/', 'version': '5.0.1', 'condition': 'spotfire-automationservices.enabled'}` |
| .dependencies[5] | Value changed | `{'name': 'spotfire-pythonservice', 'repository': 'file://../spotfire-pythonservice/', 'version': '5.0.0', 'condition': 'spotfire-pythonservice.enabled'}` | `{'name': 'spotfire-pythonservice', 'repository': 'file://../spotfire-pythonservice/', 'version': '5.0.1', 'condition': 'spotfire-pythonservice.enabled'}` |
| .dependencies[1] | Value changed | `{'name': 'spotfire-webplayer', 'repository': 'file://../spotfire-webplayer/', 'version': '5.0.0', 'condition': 'spotfire-webplayer.enabled'}` | `{'name': 'spotfire-webplayer', 'repository': 'file://../spotfire-webplayer/', 'version': '5.0.1', 'condition': 'spotfire-webplayer.enabled'}` |
| .dependencies[4] | Value changed | `{'name': 'spotfire-rservice', 'repository': 'file://../spotfire-rservice/', 'version': '5.0.0', 'condition': 'spotfire-rservice.enabled'}` | `{'name': 'spotfire-rservice', 'repository': 'file://../spotfire-rservice/', 'version': '5.0.1', 'condition': 'spotfire-rservice.enabled'}` |
| .dependencies[3] | Value changed | `{'name': 'spotfire-terrservice', 'repository': 'file://../spotfire-terrservice/', 'version': '5.0.0', 'condition': 'spotfire-terrservice.enabled'}` | `{'name': 'spotfire-terrservice', 'repository': 'file://../spotfire-terrservice/', 'version': '5.0.1', 'condition': 'spotfire-terrservice.enabled'}` |


### Chart spotfire-pythonservice changes from 5.0.0 to 5.0.1

values.yaml

| Key | Comment | Old Value | New Value |
| --- | ------- | --------- | --------- |
| .image.tag | Value changed | `15.0.0-v7.0.0` | `15.0.0-v7.0.1` |
| .podDeletionCost.image.tag | Value changed | `15.0.0-v7.0.0` | `15.0.0-v7.0.1` |

Chart.yaml

| Key | Comment | Old Value | New Value |
| --- | ------- | --------- | --------- |
| .version | Value changed | `5.0.0` | `5.0.1` |
| .dependencies[0].version | Value changed | `5.0.0` | `5.0.1` |


### Chart spotfire-rservice changes from 5.0.0 to 5.0.1

values.yaml

| Key | Comment | Old Value | New Value |
| --- | ------- | --------- | --------- |
| .image.tag | Value changed | `15.0.0-v7.0.0` | `15.0.0-v7.0.1` |
| .podDeletionCost.image.tag | Value changed | `15.0.0-v7.0.0` | `15.0.0-v7.0.1` |

Chart.yaml

| Key | Comment | Old Value | New Value |
| --- | ------- | --------- | --------- |
| .version | Value changed | `5.0.0` | `5.0.1` |
| .dependencies[0].version | Value changed | `5.0.0` | `5.0.1` |


### Chart spotfire-server changes from 5.0.0 to 5.0.1

values.yaml

| Key | Comment | Old Value | New Value |
| --- | ------- | --------- | --------- |
| .image.tag | Value changed | `15.0.0-v7.0.0` | `15.0.0-v7.0.1` |
| .podDeletionCost.image.tag | Value changed | `15.0.0-v7.0.0` | `15.0.0-v7.0.1` |
| .cliPod.image.tag | Value changed | `15.0.0-v7.0.0` | `15.0.0-v7.0.1` |
| .configJob.image.tag | Value changed | `15.0.0-v7.0.0` | `15.0.0-v7.0.1` |
| .configuration.deployment.defaultDeployment.image.tag | Value changed | `15.0.0-v7.0.0` | `15.0.0-HF-001-v7.0.1` |

Chart.yaml

| Key | Comment | Old Value | New Value |
| --- | ------- | --------- | --------- |
| .version | Value changed | `5.0.0` | `5.0.1` |
| .dependencies[2].version | Value changed | `5.0.0` | `5.0.1` |


### Chart spotfire-terrservice changes from 5.0.0 to 5.0.1

values.yaml

| Key | Comment | Old Value | New Value |
| --- | ------- | --------- | --------- |
| .image.tag | Value changed | `15.0.0-v7.0.0` | `15.0.0-v7.0.1` |
| .podDeletionCost.image.tag | Value changed | `15.0.0-v7.0.0` | `15.0.0-v7.0.1` |

Chart.yaml

| Key | Comment | Old Value | New Value |
| --- | ------- | --------- | --------- |
| .version | Value changed | `5.0.0` | `5.0.1` |
| .dependencies[0].version | Value changed | `5.0.0` | `5.0.1` |


### Chart spotfire-webplayer changes from 5.0.0 to 5.0.1

values.yaml

| Key | Comment | Old Value | New Value |
| --- | ------- | --------- | --------- |
| .image.tag | Value changed | `15.0.0-v7.0.0` | `15.0.0-HF-001-v7.0.1` |
| .podDeletionCost.image.tag | Value changed | `15.0.0-v7.0.0` | `15.0.0-v7.0.1` |

Chart.yaml

| Key | Comment | Old Value | New Value |
| --- | ------- | --------- | --------- |
| .version | Value changed | `5.0.0` | `5.0.1` |
| .appVersion | Value changed | `15.0.0` | `15.0.0-HF-001` |
| .dependencies[0].version | Value changed | `5.0.0` | `5.0.1` |


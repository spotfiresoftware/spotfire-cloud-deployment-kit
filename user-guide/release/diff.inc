## Helm chart changes

### Chart spotfire-automationservices changes from 4.0.4 to 5.0.0

values.yaml

| Key | Comment | Old Value | New Value |
| --- | ------- | --------- | --------- |
| .image.tag | Value changed | `14.8.0-HF-004-v6.0.4` | `15.0.0-v7.0.0` |
| .fluentBitSidecar.image.tag | Value changed | `4.2.2` | `4.2.3` |
| .podDeletionCost | Dictionary item added |  |  |
| .topologySpreadConstraints | Dictionary item added |  |  |

Chart.yaml

| Key | Comment | Old Value | New Value |
| --- | ------- | --------- | --------- |
| .version | Value changed | `4.0.4` | `5.0.0` |
| .appVersion | Value changed | `14.8.0-HF-004` | `15.0.0` |
| .dependencies[0].version | Value changed | `4.0.4` | `5.0.0` |


### Chart spotfire-platform changes from 4.0.4 to 5.0.0

values.yaml

| Key | Comment | Old Value | New Value |
| --- | ------- | --------- | --------- |

Chart.yaml

| Key | Comment | Old Value | New Value |
| --- | ------- | --------- | --------- |
| .version | Value changed | `4.0.4` | `5.0.0` |
| .appVersion | Value changed | `14.8-v6.0.4` | `15.0-v7.0.0` |
| .dependencies[2] | Value changed | `{'name': 'spotfire-automationservices', 'repository': 'file://../spotfire-automationservices/', 'version': '4.0.4', 'condition': 'spotfire-automationservices.enabled'}` | `{'name': 'spotfire-automationservices', 'repository': 'file://../spotfire-automationservices/', 'version': '5.0.0', 'condition': 'spotfire-automationservices.enabled'}` |
| .dependencies[1] | Value changed | `{'name': 'spotfire-webplayer', 'repository': 'file://../spotfire-webplayer/', 'version': '4.0.4', 'condition': 'spotfire-webplayer.enabled'}` | `{'name': 'spotfire-webplayer', 'repository': 'file://../spotfire-webplayer/', 'version': '5.0.0', 'condition': 'spotfire-webplayer.enabled'}` |
| .dependencies[4] | Value changed | `{'name': 'spotfire-rservice', 'repository': 'file://../spotfire-rservice/', 'version': '4.0.4', 'condition': 'spotfire-rservice.enabled'}` | `{'name': 'spotfire-rservice', 'repository': 'file://../spotfire-rservice/', 'version': '5.0.0', 'condition': 'spotfire-rservice.enabled'}` |
| .dependencies[5] | Value changed | `{'name': 'spotfire-pythonservice', 'repository': 'file://../spotfire-pythonservice/', 'version': '4.0.4', 'condition': 'spotfire-pythonservice.enabled'}` | `{'name': 'spotfire-pythonservice', 'repository': 'file://../spotfire-pythonservice/', 'version': '5.0.0', 'condition': 'spotfire-pythonservice.enabled'}` |
| .dependencies[3] | Value changed | `{'name': 'spotfire-terrservice', 'repository': 'file://../spotfire-terrservice/', 'version': '4.0.4', 'condition': 'spotfire-terrservice.enabled'}` | `{'name': 'spotfire-terrservice', 'repository': 'file://../spotfire-terrservice/', 'version': '5.0.0', 'condition': 'spotfire-terrservice.enabled'}` |
| .dependencies[0] | Value changed | `{'name': 'spotfire-server', 'repository': 'file://../spotfire-server/', 'version': '4.0.4'}` | `{'name': 'spotfire-server', 'repository': 'file://../spotfire-server/', 'version': '5.0.0'}` |


### Chart spotfire-pythonservice changes from 4.0.4 to 5.0.0

values.yaml

| Key | Comment | Old Value | New Value |
| --- | ------- | --------- | --------- |
| .image.tag | Value changed | `1.25.0-v6.0.4` | `15.0.0-v7.0.0` |
| .fluentBitSidecar.image.tag | Value changed | `4.2.2` | `4.2.3` |
| .podDeletionCost | Dictionary item added |  |  |
| .topologySpreadConstraints | Dictionary item added |  |  |

Chart.yaml

| Key | Comment | Old Value | New Value |
| --- | ------- | --------- | --------- |
| .version | Value changed | `4.0.4` | `5.0.0` |
| .appVersion | Value changed | `1.25.0` | `15.0.0` |
| .dependencies[0].version | Value changed | `4.0.4` | `5.0.0` |


### Chart spotfire-rservice changes from 4.0.4 to 5.0.0

values.yaml

| Key | Comment | Old Value | New Value |
| --- | ------- | --------- | --------- |
| .image.tag | Value changed | `1.25.0-v6.0.4` | `15.0.0-v7.0.0` |
| .fluentBitSidecar.image.tag | Value changed | `4.2.2` | `4.2.3` |
| .podDeletionCost | Dictionary item added |  |  |
| .topologySpreadConstraints | Dictionary item added |  |  |

Chart.yaml

| Key | Comment | Old Value | New Value |
| --- | ------- | --------- | --------- |
| .version | Value changed | `4.0.4` | `5.0.0` |
| .appVersion | Value changed | `1.25.0` | `15.0.0` |
| .dependencies[0].version | Value changed | `4.0.4` | `5.0.0` |


### Chart spotfire-server changes from 4.0.4 to 5.0.0

values.yaml

| Key | Comment | Old Value | New Value |
| --- | ------- | --------- | --------- |
| .image.tag | Value changed | `14.8.0-v6.0.4` | `15.0.0-v7.0.0` |
| .fluentBitSidecar.image.tag | Value changed | `4.2.2` | `4.2.3` |
| .cliPod.image.tag | Value changed | `14.8.0-v6.0.4` | `15.0.0-v7.0.0` |
| .configJob.image.tag | Value changed | `14.8.0-v6.0.4` | `15.0.0-v7.0.0` |
| .configuration.deployment.defaultDeployment.image.tag | Value changed | `14.8.0-HF-004-v6.0.4` | `15.0.0-v7.0.0` |
| .podDeletionCost | Dictionary item added |  |  |
| .topologySpreadConstraints | Dictionary item added |  |  |
| .cliPod.topologySpreadConstraints | Dictionary item added |  |  |
| .haproxy.image | Dictionary item added |  |  |

Chart.yaml

| Key | Comment | Old Value | New Value |
| --- | ------- | --------- | --------- |
| .description | Value changed | `A Helm chart for Spotfire Server.` | `Deploy Spotfire® Server on Kubernetes using Helm. This chart handles database schema setup, autoscaling, persistent storage, ingress routing, and configuration out of the box.` |
| .version | Value changed | `4.0.4` | `5.0.0` |
| .appVersion | Value changed | `14.8.0` | `15.0.0` |
| .dependencies[2].version | Value changed | `4.0.4` | `5.0.0` |


### Chart spotfire-terrservice changes from 4.0.4 to 5.0.0

values.yaml

| Key | Comment | Old Value | New Value |
| --- | ------- | --------- | --------- |
| .image.tag | Value changed | `1.25.0-v6.0.4` | `15.0.0-v7.0.0` |
| .fluentBitSidecar.image.tag | Value changed | `4.2.2` | `4.2.3` |
| .podDeletionCost | Dictionary item added |  |  |
| .topologySpreadConstraints | Dictionary item added |  |  |

Chart.yaml

| Key | Comment | Old Value | New Value |
| --- | ------- | --------- | --------- |
| .version | Value changed | `4.0.4` | `5.0.0` |
| .appVersion | Value changed | `1.25.0` | `15.0.0` |
| .dependencies[0].version | Value changed | `4.0.4` | `5.0.0` |


### Chart spotfire-webplayer changes from 4.0.4 to 5.0.0

values.yaml

| Key | Comment | Old Value | New Value |
| --- | ------- | --------- | --------- |
| .image.tag | Value changed | `14.8.0-HF-004-v6.0.4` | `15.0.0-v7.0.0` |
| .fluentBitSidecar.image.tag | Value changed | `4.2.2` | `4.2.3` |
| .podDeletionCost | Dictionary item added |  |  |
| .topologySpreadConstraints | Dictionary item added |  |  |

Chart.yaml

| Key | Comment | Old Value | New Value |
| --- | ------- | --------- | --------- |
| .version | Value changed | `4.0.4` | `5.0.0` |
| .appVersion | Value changed | `14.8.0-HF-004` | `15.0.0` |
| .dependencies[0].version | Value changed | `4.0.4` | `5.0.0` |


## Helm chart changes

### Chart spotfire-automationservices changes from 0.4.0 to 1.0.0

values.yaml

| Key | Comment | Old Value | New Value |
| --- | ------- | --------- | --------- |
| .image.tag | Value changed | `14.4.2-v2.6.0` | `14.5.0-v3.0.0` |
| .fluentBitSidecar.image.tag | Value changed | `3.2.4` | `3.2.8` |
| .logging.workerhost | Dictionary item added |  |  |

Chart.yaml

| Key | Comment | Old Value | New Value |
| --- | ------- | --------- | --------- |
| .version | Value changed | `0.4.0` | `1.0.0` |
| .appVersion | Value changed | `14.4.2` | `14.5.0` |
| .dependencies[0].version | Value changed | `0.4.0` | `1.0.0` |


### Chart spotfire-platform changes from 0.4.0 to 1.0.0

values.yaml

| Key | Comment | Old Value | New Value |
| --- | ------- | --------- | --------- |

Chart.yaml

| Key | Comment | Old Value | New Value |
| --- | ------- | --------- | --------- |
| .version | Value changed | `0.4.0` | `1.0.0` |
| .dependencies[1] | Value changed | `{'name': 'spotfire-webplayer', 'repository': 'file://../spotfire-webplayer/', 'version': '0.4.0', 'condition': 'spotfire-webplayer.enabled'}` | `{'name': 'spotfire-webplayer', 'repository': 'file://../spotfire-webplayer/', 'version': '1.0.0', 'condition': 'spotfire-webplayer.enabled'}` |
| .dependencies[2] | Value changed | `{'name': 'spotfire-automationservices', 'repository': 'file://../spotfire-automationservices/', 'version': '0.4.0', 'condition': 'spotfire-automationservices.enabled'}` | `{'name': 'spotfire-automationservices', 'repository': 'file://../spotfire-automationservices/', 'version': '1.0.0', 'condition': 'spotfire-automationservices.enabled'}` |
| .dependencies[0] | Value changed | `{'name': 'spotfire-server', 'repository': 'file://../spotfire-server/', 'version': '0.4.0'}` | `{'name': 'spotfire-server', 'repository': 'file://../spotfire-server/', 'version': '1.0.0'}` |
| .dependencies[5] | Value changed | `{'name': 'spotfire-pythonservice', 'repository': 'file://../spotfire-pythonservice/', 'version': '0.4.0', 'condition': 'spotfire-pythonservice.enabled'}` | `{'name': 'spotfire-pythonservice', 'repository': 'file://../spotfire-pythonservice/', 'version': '1.0.0', 'condition': 'spotfire-pythonservice.enabled'}` |
| .dependencies[3] | Value changed | `{'name': 'spotfire-terrservice', 'repository': 'file://../spotfire-terrservice/', 'version': '0.4.0', 'condition': 'spotfire-terrservice.enabled'}` | `{'name': 'spotfire-terrservice', 'repository': 'file://../spotfire-terrservice/', 'version': '1.0.0', 'condition': 'spotfire-terrservice.enabled'}` |
| .dependencies[4] | Value changed | `{'name': 'spotfire-rservice', 'repository': 'file://../spotfire-rservice/', 'version': '0.4.0', 'condition': 'spotfire-rservice.enabled'}` | `{'name': 'spotfire-rservice', 'repository': 'file://../spotfire-rservice/', 'version': '1.0.0', 'condition': 'spotfire-rservice.enabled'}` |
| .appVersion | Dictionary item added |  |  |


### Chart spotfire-pythonservice changes from 0.4.0 to 1.0.0

values.yaml

| Key | Comment | Old Value | New Value |
| --- | ------- | --------- | --------- |
| .image.tag | Value changed | `1.21.2-v2.6.0` | `1.22.0-v3.0.0` |
| .fluentBitSidecar.image.tag | Value changed | `3.2.4` | `3.2.8` |

Chart.yaml

| Key | Comment | Old Value | New Value |
| --- | ------- | --------- | --------- |
| .version | Value changed | `0.4.0` | `1.0.0` |
| .appVersion | Value changed | `1.21.2` | `1.22.0` |
| .dependencies[0].version | Value changed | `0.4.0` | `1.0.0` |


### Chart spotfire-rservice changes from 0.4.0 to 1.0.0

values.yaml

| Key | Comment | Old Value | New Value |
| --- | ------- | --------- | --------- |
| .image.tag | Value changed | `1.21.2-v2.6.0` | `1.22.0-v3.0.0` |
| .fluentBitSidecar.image.tag | Value changed | `3.2.4` | `3.2.8` |

Chart.yaml

| Key | Comment | Old Value | New Value |
| --- | ------- | --------- | --------- |
| .version | Value changed | `0.4.0` | `1.0.0` |
| .appVersion | Value changed | `1.21.2` | `1.22.0` |
| .dependencies[0].version | Value changed | `0.4.0` | `1.0.0` |


### Chart spotfire-server changes from 0.4.0 to 1.0.0

values.yaml

| Key | Comment | Old Value | New Value |
| --- | ------- | --------- | --------- |
| .image.tag | Value changed | `14.4.2-v2.6.0` | `14.5.0-v3.0.0` |
| .fluentBitSidecar.image.tag | Value changed | `3.2.4` | `3.2.8` |
| .cliPod.image.tag | Value changed | `14.4.2-v2.6.0` | `14.5.0-v3.0.0` |
| .configJob.image.tag | Value changed | `14.4.2-v2.6.0` | `14.5.0-v3.0.0` |
| .configuration.deployment.defaultDeployment.image.tag | Value changed | `14.4.2-v2.6.0` | `14.5.0-v3.0.0` |
| .configuration.properties.deployment.compressible-resources.brotli-executable | Dictionary item added |  |  |
| .haproxy.spotfireConfig.haproxy | Dictionary item added |  |  |

Chart.yaml

| Key | Comment | Old Value | New Value |
| --- | ------- | --------- | --------- |
| .version | Value changed | `0.4.0` | `1.0.0` |
| .appVersion | Value changed | `14.4.2` | `14.5.0` |
| .dependencies[1].version | Value changed | `1.23.*` | `1.24.*` |
| .dependencies[2].version | Value changed | `0.4.0` | `1.0.0` |


### Chart spotfire-terrservice changes from 0.4.0 to 1.0.0

values.yaml

| Key | Comment | Old Value | New Value |
| --- | ------- | --------- | --------- |
| .image.tag | Value changed | `1.21.2-v2.6.0` | `1.22.0-v3.0.0` |
| .fluentBitSidecar.image.tag | Value changed | `3.2.4` | `3.2.8` |

Chart.yaml

| Key | Comment | Old Value | New Value |
| --- | ------- | --------- | --------- |
| .version | Value changed | `0.4.0` | `1.0.0` |
| .appVersion | Value changed | `1.21.2` | `1.22.0` |
| .dependencies[0].version | Value changed | `0.4.0` | `1.0.0` |


### Chart spotfire-webplayer changes from 0.4.0 to 1.0.0

values.yaml

| Key | Comment | Old Value | New Value |
| --- | ------- | --------- | --------- |
| .image.tag | Value changed | `14.4.2-v2.6.0` | `14.5.0-v3.0.0` |
| .fluentBitSidecar.image.tag | Value changed | `3.2.4` | `3.2.8` |
| .logging.workerhost | Dictionary item added |  |  |

Chart.yaml

| Key | Comment | Old Value | New Value |
| --- | ------- | --------- | --------- |
| .version | Value changed | `0.4.0` | `1.0.0` |
| .appVersion | Value changed | `14.4.2` | `14.5.0` |
| .dependencies[0].version | Value changed | `0.4.0` | `1.0.0` |


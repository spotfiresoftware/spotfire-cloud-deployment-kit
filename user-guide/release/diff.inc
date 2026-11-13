## Helm chart changes

### Chart spotfire-automationservices changes from 6.0.0 to 6.0.1

values.yaml

| Key | Comment | Old Value | New Value |
| --- | ------- | --------- | --------- |
| .image.tag | Value changed | `15.1.0-v8.0.0` | `15.1.0-HF-001-v8.0.1` |
| .fluentBitSidecar.image.tag | Value changed | `4.2.3` | `5.1.5` |
| .fluentBitSidecar.image.digest | Value changed | `sha256:a5761fa961cb22dd0875883a4d446b1acd99d4935d77358aa9f50ee177e44fe2` | `sha256:2740f387f6e68fab66d28e4fa6a853387b9cab6ffb4cb78958f69bba4eb0e7b4` |
| .podDeletionCost.image.tag | Value changed | `15.1.0-v8.0.0` | `15.1.0-v8.0.1` |

Chart.yaml

| Key | Comment | Old Value | New Value |
| --- | ------- | --------- | --------- |
| .version | Value changed | `6.0.0` | `6.0.1` |
| .appVersion | Value changed | `15.1.0` | `15.1.0-HF-001` |
| .dependencies[0].version | Value changed | `6.0.0` | `6.0.1` |


### Chart spotfire-platform changes from 6.0.0 to 6.0.1

values.yaml

| Key | Comment | Old Value | New Value |
| --- | ------- | --------- | --------- |

Chart.yaml

| Key | Comment | Old Value | New Value |
| --- | ------- | --------- | --------- |
| .version | Value changed | `6.0.0` | `6.0.1` |
| .appVersion | Value changed | `15.1-v8.0.0` | `15.1-v8.0.1` |
| .dependencies[4] | Value changed | `{'name': 'spotfire-rservice', 'repository': 'file://../spotfire-rservice/', 'version': '6.0.0', 'condition': 'spotfire-rservice.enabled'}` | `{'name': 'spotfire-rservice', 'repository': 'file://../spotfire-rservice/', 'version': '6.0.1', 'condition': 'spotfire-rservice.enabled'}` |
| .dependencies[1] | Value changed | `{'name': 'spotfire-webplayer', 'repository': 'file://../spotfire-webplayer/', 'version': '6.0.0', 'condition': 'spotfire-webplayer.enabled'}` | `{'name': 'spotfire-webplayer', 'repository': 'file://../spotfire-webplayer/', 'version': '6.0.1', 'condition': 'spotfire-webplayer.enabled'}` |
| .dependencies[2] | Value changed | `{'name': 'spotfire-automationservices', 'repository': 'file://../spotfire-automationservices/', 'version': '6.0.0', 'condition': 'spotfire-automationservices.enabled'}` | `{'name': 'spotfire-automationservices', 'repository': 'file://../spotfire-automationservices/', 'version': '6.0.1', 'condition': 'spotfire-automationservices.enabled'}` |
| .dependencies[5] | Value changed | `{'name': 'spotfire-pythonservice', 'repository': 'file://../spotfire-pythonservice/', 'version': '6.0.0', 'condition': 'spotfire-pythonservice.enabled'}` | `{'name': 'spotfire-pythonservice', 'repository': 'file://../spotfire-pythonservice/', 'version': '6.0.1', 'condition': 'spotfire-pythonservice.enabled'}` |
| .dependencies[3] | Value changed | `{'name': 'spotfire-terrservice', 'repository': 'file://../spotfire-terrservice/', 'version': '6.0.0', 'condition': 'spotfire-terrservice.enabled'}` | `{'name': 'spotfire-terrservice', 'repository': 'file://../spotfire-terrservice/', 'version': '6.0.1', 'condition': 'spotfire-terrservice.enabled'}` |
| .dependencies[0] | Value changed | `{'name': 'spotfire-server', 'repository': 'file://../spotfire-server/', 'version': '6.0.0'}` | `{'name': 'spotfire-server', 'repository': 'file://../spotfire-server/', 'version': '6.0.1'}` |


### Chart spotfire-pythonservice changes from 6.0.0 to 6.0.1

values.yaml

| Key | Comment | Old Value | New Value |
| --- | ------- | --------- | --------- |
| .image.tag | Value changed | `15.1.0-v8.0.0` | `15.1.0-v8.0.1` |
| .fluentBitSidecar.image.tag | Value changed | `4.2.3` | `5.1.5` |
| .fluentBitSidecar.image.digest | Value changed | `sha256:a5761fa961cb22dd0875883a4d446b1acd99d4935d77358aa9f50ee177e44fe2` | `sha256:2740f387f6e68fab66d28e4fa6a853387b9cab6ffb4cb78958f69bba4eb0e7b4` |
| .podDeletionCost.image.tag | Value changed | `15.1.0-v8.0.0` | `15.1.0-v8.0.1` |

Chart.yaml

| Key | Comment | Old Value | New Value |
| --- | ------- | --------- | --------- |
| .version | Value changed | `6.0.0` | `6.0.1` |
| .dependencies[0].version | Value changed | `6.0.0` | `6.0.1` |


### Chart spotfire-rservice changes from 6.0.0 to 6.0.1

values.yaml

| Key | Comment | Old Value | New Value |
| --- | ------- | --------- | --------- |
| .image.tag | Value changed | `15.1.0-v8.0.0` | `15.1.0-v8.0.1` |
| .fluentBitSidecar.image.tag | Value changed | `4.2.3` | `5.1.5` |
| .fluentBitSidecar.image.digest | Value changed | `sha256:a5761fa961cb22dd0875883a4d446b1acd99d4935d77358aa9f50ee177e44fe2` | `sha256:2740f387f6e68fab66d28e4fa6a853387b9cab6ffb4cb78958f69bba4eb0e7b4` |
| .podDeletionCost.image.tag | Value changed | `15.1.0-v8.0.0` | `15.1.0-v8.0.1` |

Chart.yaml

| Key | Comment | Old Value | New Value |
| --- | ------- | --------- | --------- |
| .version | Value changed | `6.0.0` | `6.0.1` |
| .dependencies[0].version | Value changed | `6.0.0` | `6.0.1` |


### Chart spotfire-server changes from 6.0.0 to 6.0.1

values.yaml

| Key | Comment | Old Value | New Value |
| --- | ------- | --------- | --------- |
| .image.tag | Value changed | `15.1.0-v8.0.0` | `15.1.0-v8.0.1` |
| .fluentBitSidecar.image.tag | Value changed | `4.2.3` | `5.1.5` |
| .fluentBitSidecar.image.digest | Value changed | `sha256:a5761fa961cb22dd0875883a4d446b1acd99d4935d77358aa9f50ee177e44fe2` | `sha256:2740f387f6e68fab66d28e4fa6a853387b9cab6ffb4cb78958f69bba4eb0e7b4` |
| .podDeletionCost.image.tag | Value changed | `15.1.0-v8.0.0` | `15.1.0-v8.0.1` |
| .cliPod.image.tag | Value changed | `15.1.0-v8.0.0` | `15.1.0-v8.0.1` |
| .configJob.image.tag | Value changed | `15.1.0-v8.0.0` | `15.1.0-v8.0.1` |
| .configuration.deployment.defaultDeployment.image.tag | Value changed | `15.1.0-v8.0.0` | `15.1.0-HF-001-v8.0.1` |
| .haproxy.image.tag | Value changed | `3.2.23@sha256:441f189191238aba73965a3efd27ee9784b8a86886d572d6fe879e65247cc385` | `3.2.26@sha256:f1ce627668cb2a195a55a5faa4689540edac89eaa69abb95ca843d522f2771a1` |
| .log-forwarder.image.tag | Value changed | `4.2.3` | `5.1.5` |
| .log-forwarder.image.digest | Value changed | `sha256:a5761fa961cb22dd0875883a4d446b1acd99d4935d77358aa9f50ee177e44fe2` | `sha256:2740f387f6e68fab66d28e4fa6a853387b9cab6ffb4cb78958f69bba4eb0e7b4` |

Chart.yaml

| Key | Comment | Old Value | New Value |
| --- | ------- | --------- | --------- |
| .version | Value changed | `6.0.0` | `6.0.1` |
| .dependencies[0].version | Value changed | `0.55.*` | `0.58.*` |
| .dependencies[2].version | Value changed | `6.0.0` | `6.0.1` |


### Chart spotfire-terrservice changes from 6.0.0 to 6.0.1

values.yaml

| Key | Comment | Old Value | New Value |
| --- | ------- | --------- | --------- |
| .image.tag | Value changed | `15.1.0-v8.0.0` | `15.1.0-v8.0.1` |
| .fluentBitSidecar.image.tag | Value changed | `4.2.3` | `5.1.5` |
| .fluentBitSidecar.image.digest | Value changed | `sha256:a5761fa961cb22dd0875883a4d446b1acd99d4935d77358aa9f50ee177e44fe2` | `sha256:2740f387f6e68fab66d28e4fa6a853387b9cab6ffb4cb78958f69bba4eb0e7b4` |
| .podDeletionCost.image.tag | Value changed | `15.1.0-v8.0.0` | `15.1.0-v8.0.1` |

Chart.yaml

| Key | Comment | Old Value | New Value |
| --- | ------- | --------- | --------- |
| .version | Value changed | `6.0.0` | `6.0.1` |
| .dependencies[0].version | Value changed | `6.0.0` | `6.0.1` |


### Chart spotfire-webplayer changes from 6.0.0 to 6.0.1

values.yaml

| Key | Comment | Old Value | New Value |
| --- | ------- | --------- | --------- |
| .image.tag | Value changed | `15.1.0-v8.0.0` | `15.1.0-HF-001-v8.0.1` |
| .fluentBitSidecar.image.tag | Value changed | `4.2.3` | `5.1.5` |
| .fluentBitSidecar.image.digest | Value changed | `sha256:a5761fa961cb22dd0875883a4d446b1acd99d4935d77358aa9f50ee177e44fe2` | `sha256:2740f387f6e68fab66d28e4fa6a853387b9cab6ffb4cb78958f69bba4eb0e7b4` |
| .podDeletionCost.image.tag | Value changed | `15.1.0-v8.0.0` | `15.1.0-v8.0.1` |

Chart.yaml

| Key | Comment | Old Value | New Value |
| --- | ------- | --------- | --------- |
| .version | Value changed | `6.0.0` | `6.0.1` |
| .appVersion | Value changed | `15.1.0` | `15.1.0-HF-001` |
| .dependencies[0].version | Value changed | `6.0.0` | `6.0.1` |


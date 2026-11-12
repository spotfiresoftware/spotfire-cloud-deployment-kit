## Helm chart changes

### Chart spotfire-automationservices changes from 2.3.0 to 2.4.0

values.yaml

| Key | Comment | Old Value | New Value |
| --- | ------- | --------- | --------- |
| .image.tag | Value changed | `14.6.3-v4.3.0` | `14.6.4-v4.4.0` |
| .fluentBitSidecar.image.repository | Value changed | `fluent/fluent-bit` | `cr.fluentbit.io/fluent/fluent-bit` |
| .fluentBitSidecar.securityContext | Value changed |  | `{'allowPrivilegeEscalation': False, 'capabilities': {'drop': ['ALL']}, 'privileged': False, 'runAsNonRoot': True, 'runAsUser': 1000, 'runAsGroup': 1000}` |
| .securityContext | Value changed |  | `{'allowPrivilegeEscalation': False, 'capabilities': {'drop': ['ALL']}, 'privileged': False, 'runAsNonRoot': True, 'runAsUser': 1000}` |
| .fluentBitSidecar.image.digest | Dictionary item added |  |  |
| .serviceAccount.automountServiceAccountToken | Dictionary item added |  |  |
| .podSecurityContext.seccompProfile | Dictionary item added |  |  |

Chart.yaml

| Key | Comment | Old Value | New Value |
| --- | ------- | --------- | --------- |
| .version | Value changed | `2.3.0` | `2.4.0` |
| .appVersion | Value changed | `14.6.3` | `14.6.4` |
| .dependencies[0].version | Value changed | `2.3.0` | `2.4.0` |


### Chart spotfire-platform changes from 2.3.0 to 2.4.0

values.yaml

| Key | Comment | Old Value | New Value |
| --- | ------- | --------- | --------- |

Chart.yaml

| Key | Comment | Old Value | New Value |
| --- | ------- | --------- | --------- |
| .version | Value changed | `2.3.0` | `2.4.0` |
| .appVersion | Value changed | `14.6-v4.3.0` | `14.6-v4.4.0` |
| .dependencies[4] | Value changed | `{'name': 'spotfire-rservice', 'repository': 'file://../spotfire-rservice/', 'version': '2.3.0', 'condition': 'spotfire-rservice.enabled'}` | `{'name': 'spotfire-rservice', 'repository': 'file://../spotfire-rservice/', 'version': '2.4.0', 'condition': 'spotfire-rservice.enabled'}` |
| .dependencies[1] | Value changed | `{'name': 'spotfire-webplayer', 'repository': 'file://../spotfire-webplayer/', 'version': '2.3.0', 'condition': 'spotfire-webplayer.enabled'}` | `{'name': 'spotfire-webplayer', 'repository': 'file://../spotfire-webplayer/', 'version': '2.4.0', 'condition': 'spotfire-webplayer.enabled'}` |
| .dependencies[5] | Value changed | `{'name': 'spotfire-pythonservice', 'repository': 'file://../spotfire-pythonservice/', 'version': '2.3.0', 'condition': 'spotfire-pythonservice.enabled'}` | `{'name': 'spotfire-pythonservice', 'repository': 'file://../spotfire-pythonservice/', 'version': '2.4.0', 'condition': 'spotfire-pythonservice.enabled'}` |
| .dependencies[0] | Value changed | `{'name': 'spotfire-server', 'repository': 'file://../spotfire-server/', 'version': '2.3.0'}` | `{'name': 'spotfire-server', 'repository': 'file://../spotfire-server/', 'version': '2.4.0'}` |
| .dependencies[2] | Value changed | `{'name': 'spotfire-automationservices', 'repository': 'file://../spotfire-automationservices/', 'version': '2.3.0', 'condition': 'spotfire-automationservices.enabled'}` | `{'name': 'spotfire-automationservices', 'repository': 'file://../spotfire-automationservices/', 'version': '2.4.0', 'condition': 'spotfire-automationservices.enabled'}` |
| .dependencies[3] | Value changed | `{'name': 'spotfire-terrservice', 'repository': 'file://../spotfire-terrservice/', 'version': '2.3.0', 'condition': 'spotfire-terrservice.enabled'}` | `{'name': 'spotfire-terrservice', 'repository': 'file://../spotfire-terrservice/', 'version': '2.4.0', 'condition': 'spotfire-terrservice.enabled'}` |


### Chart spotfire-pythonservice changes from 2.3.0 to 2.4.0

values.yaml

| Key | Comment | Old Value | New Value |
| --- | ------- | --------- | --------- |
| .image.tag | Value changed | `14.6.3-v4.3.0` | `14.6.4-v4.4.0` |
| .fluentBitSidecar.image.repository | Value changed | `fluent/fluent-bit` | `cr.fluentbit.io/fluent/fluent-bit` |
| .fluentBitSidecar.securityContext | Value changed |  | `{'allowPrivilegeEscalation': False, 'capabilities': {'drop': ['ALL']}, 'privileged': False, 'runAsNonRoot': True, 'runAsUser': 1000, 'runAsGroup': 1000}` |
| .securityContext | Value changed |  | `{'allowPrivilegeEscalation': False, 'capabilities': {'drop': ['ALL']}, 'privileged': False, 'runAsNonRoot': True, 'runAsUser': 1000}` |
| .fluentBitSidecar.image.digest | Dictionary item added |  |  |
| .serviceAccount.automountServiceAccountToken | Dictionary item added |  |  |
| .podSecurityContext.seccompProfile | Dictionary item added |  |  |

Chart.yaml

| Key | Comment | Old Value | New Value |
| --- | ------- | --------- | --------- |
| .version | Value changed | `2.3.0` | `2.4.0` |
| .appVersion | Value changed | `14.6.3` | `14.6.4` |
| .dependencies[0].version | Value changed | `2.3.0` | `2.4.0` |


### Chart spotfire-rservice changes from 2.3.0 to 2.4.0

values.yaml

| Key | Comment | Old Value | New Value |
| --- | ------- | --------- | --------- |
| .image.tag | Value changed | `14.6.3-v4.3.0` | `14.6.4-v4.4.0` |
| .fluentBitSidecar.image.repository | Value changed | `fluent/fluent-bit` | `cr.fluentbit.io/fluent/fluent-bit` |
| .fluentBitSidecar.securityContext | Value changed |  | `{'allowPrivilegeEscalation': False, 'capabilities': {'drop': ['ALL']}, 'privileged': False, 'runAsNonRoot': True, 'runAsUser': 1000, 'runAsGroup': 1000}` |
| .securityContext | Value changed |  | `{'allowPrivilegeEscalation': False, 'capabilities': {'drop': ['ALL']}, 'privileged': False, 'runAsNonRoot': True, 'runAsUser': 1000}` |
| .fluentBitSidecar.image.digest | Dictionary item added |  |  |
| .serviceAccount.automountServiceAccountToken | Dictionary item added |  |  |
| .podSecurityContext.seccompProfile | Dictionary item added |  |  |

Chart.yaml

| Key | Comment | Old Value | New Value |
| --- | ------- | --------- | --------- |
| .version | Value changed | `2.3.0` | `2.4.0` |
| .appVersion | Value changed | `14.6.3` | `14.6.4` |
| .dependencies[0].version | Value changed | `2.3.0` | `2.4.0` |


### Chart spotfire-server changes from 2.3.0 to 2.4.0

values.yaml

| Key | Comment | Old Value | New Value |
| --- | ------- | --------- | --------- |
| .image.tag | Value changed | `14.6.3-v4.3.0` | `14.6.4-v4.4.0` |
| .fluentBitSidecar.image.repository | Value changed | `fluent/fluent-bit` | `cr.fluentbit.io/fluent/fluent-bit` |
| .cliPod.image.tag | Value changed | `14.6.3-v4.3.0` | `14.6.4-v4.4.0` |
| .configJob.image.tag | Value changed | `14.6.3-v4.3.0` | `14.6.4-v4.4.0` |
| .configuration.deployment.defaultDeployment.image.tag | Value changed | `14.6.3-v4.3.0` | `14.6.4-v4.4.0` |
| .haproxy.image.tag | Value changed | `3.2.19` | `3.2.23@sha256:441f189191238aba73965a3efd27ee9784b8a86886d572d6fe879e65247cc385` |
| .log-forwarder.image | Value changed | `{'pullPolicy': 'IfNotPresent'}` | `{'repository': 'cr.fluentbit.io/fluent/fluent-bit', 'tag': '4.2.3', 'digest': 'sha256:a5761fa961cb22dd0875883a4d446b1acd99d4935d77358aa9f50ee177e44fe2', 'pullPolicy': 'IfNotPresent'}` |
| .networkPolicy | Dictionary item added |  |  |
| .fluentBitSidecar.image.digest | Dictionary item added |  |  |
| .serviceAccount.automountServiceAccountToken | Dictionary item added |  |  |
| .configuration.encryptionPasswordExistingSecret | Dictionary item added |  |  |
| .haproxy.image.repository | Dictionary item added |  |  |
| .toolPassword | Dictionary item removed |  |  |

Chart.yaml

| Key | Comment | Old Value | New Value |
| --- | ------- | --------- | --------- |
| .version | Value changed | `2.3.0` | `2.4.0` |
| .appVersion | Value changed | `14.6.3` | `14.6.4` |
| .dependencies[2].version | Value changed | `2.3.0` | `2.4.0` |


### Chart spotfire-terrservice changes from 2.3.0 to 2.4.0

values.yaml

| Key | Comment | Old Value | New Value |
| --- | ------- | --------- | --------- |
| .image.tag | Value changed | `14.6.3-v4.3.0` | `14.6.4-v4.4.0` |
| .fluentBitSidecar.image.repository | Value changed | `fluent/fluent-bit` | `cr.fluentbit.io/fluent/fluent-bit` |
| .fluentBitSidecar.securityContext | Value changed |  | `{'allowPrivilegeEscalation': False, 'capabilities': {'drop': ['ALL']}, 'privileged': False, 'runAsNonRoot': True, 'runAsUser': 1000, 'runAsGroup': 1000}` |
| .securityContext | Value changed |  | `{'allowPrivilegeEscalation': False, 'capabilities': {'drop': ['ALL']}, 'privileged': False, 'runAsNonRoot': True, 'runAsUser': 1000}` |
| .fluentBitSidecar.image.digest | Dictionary item added |  |  |
| .serviceAccount.automountServiceAccountToken | Dictionary item added |  |  |
| .podSecurityContext.seccompProfile | Dictionary item added |  |  |

Chart.yaml

| Key | Comment | Old Value | New Value |
| --- | ------- | --------- | --------- |
| .version | Value changed | `2.3.0` | `2.4.0` |
| .appVersion | Value changed | `14.6.3` | `14.6.4` |
| .dependencies[0].version | Value changed | `2.3.0` | `2.4.0` |


### Chart spotfire-webplayer changes from 2.3.0 to 2.4.0

values.yaml

| Key | Comment | Old Value | New Value |
| --- | ------- | --------- | --------- |
| .image.tag | Value changed | `14.6.3-v4.3.0` | `14.6.4-v4.4.0` |
| .fluentBitSidecar.image.repository | Value changed | `fluent/fluent-bit` | `cr.fluentbit.io/fluent/fluent-bit` |
| .fluentBitSidecar.securityContext | Value changed |  | `{'allowPrivilegeEscalation': False, 'capabilities': {'drop': ['ALL']}, 'privileged': False, 'runAsNonRoot': True, 'runAsUser': 1000, 'runAsGroup': 1000}` |
| .securityContext | Value changed |  | `{'allowPrivilegeEscalation': False, 'capabilities': {'drop': ['ALL']}, 'privileged': False, 'runAsNonRoot': True, 'runAsUser': 1000}` |
| .fluentBitSidecar.image.digest | Dictionary item added |  |  |
| .serviceAccount.automountServiceAccountToken | Dictionary item added |  |  |
| .podSecurityContext.seccompProfile | Dictionary item added |  |  |

Chart.yaml

| Key | Comment | Old Value | New Value |
| --- | ------- | --------- | --------- |
| .version | Value changed | `2.3.0` | `2.4.0` |
| .appVersion | Value changed | `14.6.3` | `14.6.4` |
| .dependencies[0].version | Value changed | `2.3.0` | `2.4.0` |


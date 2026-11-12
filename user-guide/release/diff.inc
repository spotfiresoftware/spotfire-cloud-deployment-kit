## Helm chart changes

### Chart spotfire-automationservices changes from 5.0.0 to 6.0.0

values.yaml

| Key | Comment | Old Value | New Value |
| --- | ------- | --------- | --------- |
| .image.tag | Value changed | `15.0.0-v7.0.0` | `15.1.0-v8.0.0` |
| .fluentBitSidecar.image.repository | Value changed | `fluent/fluent-bit` | `cr.fluentbit.io/fluent/fluent-bit` |
| .fluentBitSidecar.securityContext | Value changed |  | `{'allowPrivilegeEscalation': False, 'capabilities': {'drop': ['ALL']}, 'privileged': False, 'runAsNonRoot': True, 'runAsUser': 1000, 'runAsGroup': 1000}` |
| .securityContext | Value changed |  | `{'allowPrivilegeEscalation': False, 'capabilities': {'drop': ['ALL']}, 'privileged': False, 'runAsNonRoot': True, 'runAsUser': 1000}` |
| .podDeletionCost.image.tag | Value changed | `15.0.0-v7.0.0` | `15.1.0-v8.0.0` |
| .fluentBitSidecar.image.digest | Dictionary item added |  |  |
| .serviceAccount.automountServiceAccountToken | Dictionary item added |  |  |
| .podSecurityContext.seccompProfile | Dictionary item added |  |  |
| .podDeletionCost.podAnnotations | Dictionary item added |  |  |
| .podDeletionCost.nodeSelector | Dictionary item added |  |  |
| .podDeletionCost.tolerations | Dictionary item added |  |  |
| .podDeletionCost.affinity | Dictionary item added |  |  |

Chart.yaml

| Key | Comment | Old Value | New Value |
| --- | ------- | --------- | --------- |
| .version | Value changed | `5.0.0` | `6.0.0` |
| .appVersion | Value changed | `15.0.0` | `15.1.0` |
| .dependencies[0].version | Value changed | `5.0.0` | `6.0.0` |


### Chart spotfire-platform changes from 5.0.0 to 6.0.0

values.yaml

| Key | Comment | Old Value | New Value |
| --- | ------- | --------- | --------- |

Chart.yaml

| Key | Comment | Old Value | New Value |
| --- | ------- | --------- | --------- |
| .version | Value changed | `5.0.0` | `6.0.0` |
| .appVersion | Value changed | `15.0-v7.0.0` | `15.1-v8.0.0` |
| .dependencies[3] | Value changed | `{'name': 'spotfire-terrservice', 'repository': 'file://../spotfire-terrservice/', 'version': '5.0.0', 'condition': 'spotfire-terrservice.enabled'}` | `{'name': 'spotfire-terrservice', 'repository': 'file://../spotfire-terrservice/', 'version': '6.0.0', 'condition': 'spotfire-terrservice.enabled'}` |
| .dependencies[1] | Value changed | `{'name': 'spotfire-webplayer', 'repository': 'file://../spotfire-webplayer/', 'version': '5.0.0', 'condition': 'spotfire-webplayer.enabled'}` | `{'name': 'spotfire-webplayer', 'repository': 'file://../spotfire-webplayer/', 'version': '6.0.0', 'condition': 'spotfire-webplayer.enabled'}` |
| .dependencies[2] | Value changed | `{'name': 'spotfire-automationservices', 'repository': 'file://../spotfire-automationservices/', 'version': '5.0.0', 'condition': 'spotfire-automationservices.enabled'}` | `{'name': 'spotfire-automationservices', 'repository': 'file://../spotfire-automationservices/', 'version': '6.0.0', 'condition': 'spotfire-automationservices.enabled'}` |
| .dependencies[5] | Value changed | `{'name': 'spotfire-pythonservice', 'repository': 'file://../spotfire-pythonservice/', 'version': '5.0.0', 'condition': 'spotfire-pythonservice.enabled'}` | `{'name': 'spotfire-pythonservice', 'repository': 'file://../spotfire-pythonservice/', 'version': '6.0.0', 'condition': 'spotfire-pythonservice.enabled'}` |
| .dependencies[4] | Value changed | `{'name': 'spotfire-rservice', 'repository': 'file://../spotfire-rservice/', 'version': '5.0.0', 'condition': 'spotfire-rservice.enabled'}` | `{'name': 'spotfire-rservice', 'repository': 'file://../spotfire-rservice/', 'version': '6.0.0', 'condition': 'spotfire-rservice.enabled'}` |
| .dependencies[0] | Value changed | `{'name': 'spotfire-server', 'repository': 'file://../spotfire-server/', 'version': '5.0.0'}` | `{'name': 'spotfire-server', 'repository': 'file://../spotfire-server/', 'version': '6.0.0'}` |


### Chart spotfire-pythonservice changes from 5.0.0 to 6.0.0

values.yaml

| Key | Comment | Old Value | New Value |
| --- | ------- | --------- | --------- |
| .image.tag | Value changed | `15.0.0-v7.0.0` | `15.1.0-v8.0.0` |
| .fluentBitSidecar.image.repository | Value changed | `fluent/fluent-bit` | `cr.fluentbit.io/fluent/fluent-bit` |
| .fluentBitSidecar.securityContext | Value changed |  | `{'allowPrivilegeEscalation': False, 'capabilities': {'drop': ['ALL']}, 'privileged': False, 'runAsNonRoot': True, 'runAsUser': 1000, 'runAsGroup': 1000}` |
| .securityContext | Value changed |  | `{'allowPrivilegeEscalation': False, 'capabilities': {'drop': ['ALL']}, 'privileged': False, 'runAsNonRoot': True, 'runAsUser': 1000}` |
| .podDeletionCost.image.tag | Value changed | `15.0.0-v7.0.0` | `15.1.0-v8.0.0` |
| .fluentBitSidecar.image.digest | Dictionary item added |  |  |
| .serviceAccount.automountServiceAccountToken | Dictionary item added |  |  |
| .podSecurityContext.seccompProfile | Dictionary item added |  |  |
| .podDeletionCost.podAnnotations | Dictionary item added |  |  |
| .podDeletionCost.nodeSelector | Dictionary item added |  |  |
| .podDeletionCost.tolerations | Dictionary item added |  |  |
| .podDeletionCost.affinity | Dictionary item added |  |  |

Chart.yaml

| Key | Comment | Old Value | New Value |
| --- | ------- | --------- | --------- |
| .version | Value changed | `5.0.0` | `6.0.0` |
| .appVersion | Value changed | `15.0.0` | `15.1.0` |
| .dependencies[0].version | Value changed | `5.0.0` | `6.0.0` |


### Chart spotfire-rservice changes from 5.0.0 to 6.0.0

values.yaml

| Key | Comment | Old Value | New Value |
| --- | ------- | --------- | --------- |
| .image.tag | Value changed | `15.0.0-v7.0.0` | `15.1.0-v8.0.0` |
| .fluentBitSidecar.image.repository | Value changed | `fluent/fluent-bit` | `cr.fluentbit.io/fluent/fluent-bit` |
| .fluentBitSidecar.securityContext | Value changed |  | `{'allowPrivilegeEscalation': False, 'capabilities': {'drop': ['ALL']}, 'privileged': False, 'runAsNonRoot': True, 'runAsUser': 1000, 'runAsGroup': 1000}` |
| .securityContext | Value changed |  | `{'allowPrivilegeEscalation': False, 'capabilities': {'drop': ['ALL']}, 'privileged': False, 'runAsNonRoot': True, 'runAsUser': 1000}` |
| .podDeletionCost.image.tag | Value changed | `15.0.0-v7.0.0` | `15.1.0-v8.0.0` |
| .fluentBitSidecar.image.digest | Dictionary item added |  |  |
| .serviceAccount.automountServiceAccountToken | Dictionary item added |  |  |
| .podSecurityContext.seccompProfile | Dictionary item added |  |  |
| .podDeletionCost.podAnnotations | Dictionary item added |  |  |
| .podDeletionCost.nodeSelector | Dictionary item added |  |  |
| .podDeletionCost.tolerations | Dictionary item added |  |  |
| .podDeletionCost.affinity | Dictionary item added |  |  |

Chart.yaml

| Key | Comment | Old Value | New Value |
| --- | ------- | --------- | --------- |
| .version | Value changed | `5.0.0` | `6.0.0` |
| .appVersion | Value changed | `15.0.0` | `15.1.0` |
| .dependencies[0].version | Value changed | `5.0.0` | `6.0.0` |


### Chart spotfire-server changes from 5.0.0 to 6.0.0

values.yaml

| Key | Comment | Old Value | New Value |
| --- | ------- | --------- | --------- |
| .image.tag | Value changed | `15.0.0-v7.0.0` | `15.1.0-v8.0.0` |
| .fluentBitSidecar.image.repository | Value changed | `fluent/fluent-bit` | `cr.fluentbit.io/fluent/fluent-bit` |
| .podDeletionCost.image.tag | Value changed | `15.0.0-v7.0.0` | `15.1.0-v8.0.0` |
| .cliPod.image.tag | Value changed | `15.0.0-v7.0.0` | `15.1.0-v8.0.0` |
| .configJob.image.tag | Value changed | `15.0.0-v7.0.0` | `15.1.0-v8.0.0` |
| .configuration.deployment.defaultDeployment.image.tag | Value changed | `15.0.0-v7.0.0` | `15.1.0-v8.0.0` |
| .haproxy.image.tag | Value changed | `3.2.19` | `3.2.23@sha256:441f189191238aba73965a3efd27ee9784b8a86886d572d6fe879e65247cc385` |
| .log-forwarder.image | Value changed | `{'pullPolicy': 'IfNotPresent'}` | `{'repository': 'cr.fluentbit.io/fluent/fluent-bit', 'tag': '4.2.3', 'digest': 'sha256:a5761fa961cb22dd0875883a4d446b1acd99d4935d77358aa9f50ee177e44fe2', 'pullPolicy': 'IfNotPresent'}` |
| .networkPolicy | Dictionary item added |  |  |
| .fluentBitSidecar.image.digest | Dictionary item added |  |  |
| .serviceAccount.automountServiceAccountToken | Dictionary item added |  |  |
| .podDeletionCost.podAnnotations | Dictionary item added |  |  |
| .podDeletionCost.nodeSelector | Dictionary item added |  |  |
| .podDeletionCost.tolerations | Dictionary item added |  |  |
| .podDeletionCost.affinity | Dictionary item added |  |  |
| .configuration.encryptionPasswordExistingSecret | Dictionary item added |  |  |
| .haproxy.image.repository | Dictionary item added |  |  |
| .toolPassword | Dictionary item removed |  |  |

Chart.yaml

| Key | Comment | Old Value | New Value |
| --- | ------- | --------- | --------- |
| .version | Value changed | `5.0.0` | `6.0.0` |
| .appVersion | Value changed | `15.0.0` | `15.1.0` |
| .dependencies[2].version | Value changed | `5.0.0` | `6.0.0` |


### Chart spotfire-terrservice changes from 5.0.0 to 6.0.0

values.yaml

| Key | Comment | Old Value | New Value |
| --- | ------- | --------- | --------- |
| .image.tag | Value changed | `15.0.0-v7.0.0` | `15.1.0-v8.0.0` |
| .fluentBitSidecar.image.repository | Value changed | `fluent/fluent-bit` | `cr.fluentbit.io/fluent/fluent-bit` |
| .fluentBitSidecar.securityContext | Value changed |  | `{'allowPrivilegeEscalation': False, 'capabilities': {'drop': ['ALL']}, 'privileged': False, 'runAsNonRoot': True, 'runAsUser': 1000, 'runAsGroup': 1000}` |
| .securityContext | Value changed |  | `{'allowPrivilegeEscalation': False, 'capabilities': {'drop': ['ALL']}, 'privileged': False, 'runAsNonRoot': True, 'runAsUser': 1000}` |
| .podDeletionCost.image.tag | Value changed | `15.0.0-v7.0.0` | `15.1.0-v8.0.0` |
| .fluentBitSidecar.image.digest | Dictionary item added |  |  |
| .serviceAccount.automountServiceAccountToken | Dictionary item added |  |  |
| .podSecurityContext.seccompProfile | Dictionary item added |  |  |
| .podDeletionCost.podAnnotations | Dictionary item added |  |  |
| .podDeletionCost.nodeSelector | Dictionary item added |  |  |
| .podDeletionCost.tolerations | Dictionary item added |  |  |
| .podDeletionCost.affinity | Dictionary item added |  |  |

Chart.yaml

| Key | Comment | Old Value | New Value |
| --- | ------- | --------- | --------- |
| .version | Value changed | `5.0.0` | `6.0.0` |
| .appVersion | Value changed | `15.0.0` | `15.1.0` |
| .dependencies[0].version | Value changed | `5.0.0` | `6.0.0` |


### Chart spotfire-webplayer changes from 5.0.0 to 6.0.0

values.yaml

| Key | Comment | Old Value | New Value |
| --- | ------- | --------- | --------- |
| .image.tag | Value changed | `15.0.0-v7.0.0` | `15.1.0-v8.0.0` |
| .fluentBitSidecar.image.repository | Value changed | `fluent/fluent-bit` | `cr.fluentbit.io/fluent/fluent-bit` |
| .fluentBitSidecar.securityContext | Value changed |  | `{'allowPrivilegeEscalation': False, 'capabilities': {'drop': ['ALL']}, 'privileged': False, 'runAsNonRoot': True, 'runAsUser': 1000, 'runAsGroup': 1000}` |
| .securityContext | Value changed |  | `{'allowPrivilegeEscalation': False, 'capabilities': {'drop': ['ALL']}, 'privileged': False, 'runAsNonRoot': True, 'runAsUser': 1000}` |
| .podDeletionCost.image.tag | Value changed | `15.0.0-v7.0.0` | `15.1.0-v8.0.0` |
| .fluentBitSidecar.image.digest | Dictionary item added |  |  |
| .serviceAccount.automountServiceAccountToken | Dictionary item added |  |  |
| .podSecurityContext.seccompProfile | Dictionary item added |  |  |
| .podDeletionCost.podAnnotations | Dictionary item added |  |  |
| .podDeletionCost.nodeSelector | Dictionary item added |  |  |
| .podDeletionCost.tolerations | Dictionary item added |  |  |
| .podDeletionCost.affinity | Dictionary item added |  |  |

Chart.yaml

| Key | Comment | Old Value | New Value |
| --- | ------- | --------- | --------- |
| .version | Value changed | `5.0.0` | `6.0.0` |
| .appVersion | Value changed | `15.0.0` | `15.1.0` |
| .dependencies[0].version | Value changed | `5.0.0` | `6.0.0` |


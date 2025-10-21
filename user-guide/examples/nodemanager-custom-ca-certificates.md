# Adding Custom CA Certificates to Spotfire Nodemanager-based Services

This example shows how to add custom CA certificates to Spotfire services that use the NodeManager, including:

- **Spotfire Automation Services** (`spotfire-automationservices`)
- **Spotfire WebPlayer** (`spotfire-webplayer`)
- **Spotfire Python Service** (`spotfire-pythonservice`)
- **Spotfire Service for R** (`spotfire-rservice`)
- **Spotfire Service for Spotfire Enterprise Runtime for R** (`spotfire-terrservice`)

All these services inherit the custom CA certificate functionality from the base NodeManager image.

## Method 1: Using volumes.certificates (Recommended for persistent storage)

This method uses the dedicated `volumes.certificates` configuration with a PersistentVolumeClaim.

### Step 1: Create a PersistentVolumeClaim with your custom CA certificates

```bash
# First, create a PVC for your certificates
kubectl apply -f - <<EOF
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: custom-ca-certificates-pvc
spec:
  accessModes:
    - ReadOnlyMany
  resources:
    requests:
      storage: 100Mi
EOF

# Then populate it with your certificate files
# (This example assumes you have a way to copy files to the PVC)
```

### Step 2: Configure Helm values to mount the certificates

Create a `values.yaml` file:

```yaml
# Accept End User Agreement
global:
  spotfire:
    acceptEUA: true

# Configure custom CA certificates using dedicated volumes.certificates
volumes:
  certificates:
    existingClaim: "custom-ca-certificates-pvc"
    subPath: ""
```

### Step 3: Deploy the Helm chart

```bash
helm upgrade --install my-automation-services \
  oci://oci.spotfire.com/charts/spotfire-automationservices \
  --values values.yaml
```

## Method 2: Using extraVolumes with ConfigMap (Simple for static certificates)

This alternative method leverages `extraVolumes` and `extraVolumeMounts` to mount a ConfigMap containing your custom CA certificates. Choose this approach if you want a straightforward setup using `kubectl create configmap --from-file` and prefer managing certificates through Kubernetes ConfigMaps.

**Note**: This method is mutually exclusive with Method 1 - use one or the other, not both.

### Step 1: Create a ConfigMap with your certificates

```bash
# Create ConfigMap from certificate files
kubectl create configmap custom-ca-certificates \
  --from-file=my-enterprise-ca.crt \
  --from-file=my-test-ca.crt

# Or create from a directory containing multiple certificates
kubectl create configmap custom-ca-certificates \
  --from-file=/path/to/certificates/
```

### Step 2: Configure Helm values to mount the ConfigMap

Create a `values.yaml` file:

```yaml
# Accept End User Agreement
global:
  spotfire:
    acceptEUA: true

# Configure custom CA certificates using extraVolumes (ConfigMap approach)
extraVolumes:
  - name: custom-ca-volume
    configMap:
      name: custom-ca-certificates

extraVolumeMounts:
  - name: custom-ca-volume
    mountPath: /usr/local/share/ca-certificates
    readOnly: true
```

### Step 3: Deploy the Helm chart

```bash
helm upgrade --install my-automation-services \
  oci://oci.spotfire.com/charts/spotfire-automationservices \
  --values values.yaml
```

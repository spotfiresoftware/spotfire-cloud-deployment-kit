# Installing Python packages directly to a PersistentVolume using a Kubernetes job

The file [deploy-packages-to-pv-with-job.yaml](deploy-packages-to-pv-with-job.yaml) is an example of how to use a Kubernetes Job, PersistentVolumeClaim, and ConfigMap to create and populate a PersistentVolume containing Python packages.

You might need to change some values in the file. For example, change the storageClassName for PersistentVolumeClaim to StorageClass from 'nfs-client' to one that exists in your environment. The full set of commands would look something like the following example:

```bash
# kubectl will create the PersistentVolumeClaim 'packages-pvc' pointing to PersistentVolume containing the installed Python packages.
kubectl apply . -f deploy-packages-to-pv-with-job.yaml

# When you install the spotfire-pythonservice Helm chart, pass in packages-pvc.
helm install my-release --set volumes.packages=packages-pvc <... additional helm install arguments>
```

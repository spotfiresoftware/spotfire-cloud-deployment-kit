# Using custom modules with spotfire-webplayer (or spotfire-automationservices)

To use custom modules with the spotfire-webplayer chart, you can supply a
persistent volume claim to the helm chart during installation. This will let
the webplayer pod know where to find the modules. These modules are usually
bundled as sdn or spk files and need to be unpacked to a persistent volume
before they can be used by the webplayer.

Creating custom webplayer images that include the custom modules is also
possible, but this example doesn't cover that. Using a persistent volume has
the advantage of not requiring you to build and push new custom images for each
type of environment. This is because the custom modules are loaded in runtime
when the pods are started, making it easier to manage and deploy the
spotfire-webplayer chart by using an unmodified image.

Step 1-5 are only needed if you want to unpack the modules to a persistent
volume using a kubernetes job. If you already have the modules unpacked to a
persistent volume, you can skip to step 6, as long as you have a persistent
volume claim that points to the persistent volume. There are many ways to
unpack the modules to a persistent volume, so this example only covers one way
of doing it.

1. Put your spk or sdn files in the `custom-modules/` directory.
2. Use the Dockerfile in this directory to build a docker image with your
   custom modules.
   ```
   docker build -t webplayer-custom-modules .
   ```

3. Push the image to a docker registry so it's available to your kubernetes
   cluster.
   ```
   DOCKER_REGISTRY=your-docker-registry.example.com
   docker tag webplayer-custom-modules:latest ${DOCKER_REGISTRY}/webplayer-custom-modules
   docker push ${DOCKER_REGISTRY}/webplayer-custom-modules
   ```

4. Update the `unpack-modules-to-pvc.yaml` file with the correct storage class,
   docker image name, pvc name.
   ```
   vim unpack-modules-to-pvc.yaml
   ```

5. Run the `unpack-modules-to-pvc.yaml` file to create a job that will unpack
   the modules to the persistent volume.
   ```
   kubectl apply -f unpack-modules-to-pvc.yaml
   kubectl logs job/populate-modules-job
   ```

6. To install spotfire-webplayer, use the `volumes.customModules.existingClaim`
   value and supply the pvc name.
   ```
   helm install spotfire-webplayer tibco/spotfire-webplayer --set volumes.customModules.existingClaim=custom-modules-pvc ...
   ```
   Note: tibco/spotfire-webplayer assumes the helm repo is named spotfire.
   If you have named it something else, you need to use that name instead.

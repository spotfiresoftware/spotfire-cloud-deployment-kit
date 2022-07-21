# How versions are related

There are different version types used in this project: GIT repository, applications, container images, and Helm charts versions.
                                                                           
This table summarizes how these different version types are related within the context of the Cloud Deployment Kit for TIBCO Spotfire recipes.

| version type           | description                                 | defined in                                    | how is defined                                                                                                           | how they are used by the provided Makefiles                                                                                                                             | examples of how it is used                                                                              |
|------------------------|---------------------------------------------|-----------------------------------------------|--------------------------------------------------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------|---------------------------------------------------------------------------------------------------------|
| CDK for TIBCO Spotfire | The release version of this GIT repository  | [versions.mk](../versions.mk)                 | `CLOUD_DEPLOYMENT_KIT_VERSION=1.0.0`                                                                                     | - Tag the CDK for TIBCO Spotfire git repository                                                                                                                         | - `git tag -l`                                                                                          |
| Application            | The version of the main contained component | [versions.mk](../versions.mk)                 | `SPOTFIRE_SERVER_VERSION=12.0.0`                                                                                         | - Extract package from `downloads` directory into the built container<br>- Set `org.opencontainers.image.version` container label<br>- Set `appVersion` in `Chart.yaml` | - `tss-12.0.0.x86_64.tar.gz`<br>- `org.opencontainers.image.version=12.0.0`<br>- `appVersion: "12.0.0"` |
| Container image        | The built container image version           | [containers/Makefile](../containers/Makefile) | composed using the Application version<br>and the CDK version:<br>`<APPLICATION_VERSION>-<CLOUD_DEPLOYMENT_KIT_VERSION>` | - Tag the container image<br>- Refer to the container image tag from the chart `values.yaml`                                                                            | - `tibco/spotfire-server:12.0.0-1.0.0`<br>- `image.tag: "12.0.0-1.0.0"`                                 |
| Helm chart             | The packaged chart version                  | `helm/charts/<chart>/Chart.yaml`              | Chart `version` in respective `Chart.yaml`, example: `1.0.1`                                                             | - Set the packaged chart version                                                                                                                                        | - `spotfire-server-1.0.1.tgz`                                                                           |

The default CDK for TIBCO Spotfire and Application versions are configured in the [versions.mk](../versions.mk) file.

## Build container images with other application versions

You can use other application versions by modifying the related files for each case.

A common case is for building a new container image with the latest released application version.

For this specific case, you can modify the component version in [versions.mk](../versions.mk) (for example, `SPOTFIRE_SERVER_VERSION=12.0.1`),
put that application component version in the `containers/downloads` directory, and, as usual, build the new containers using `make` from the `containers/` directory.

## Build container images using custom tags

If you run `make` from the `containers/` directory without arguments, it tags the built images with the tag `<APPLICATION_VERSION>-<CLOUD_DEPLOYMENT_KIT_VERSION>`.
You can override the second part of the image tag (`<CLOUD_DEPLOYMENT_KIT_VERSION>`) using the `IMAGE_BUILD_ID` argument. For example:

```                    
make IMAGE_BUILD_ID=my-custom-image-0.1 build
```

This is useful when your container recipes deviate from the default ones for a specific Cloud Deployment Kit Version, in order to mark them as custom images.

## Using Helm charts with other container image versions

You can use other container image versions than the default ones configured in the Helm charts. 
For that, you can use your custom `image.tag` value within the corresponding chart `values.yaml` file.

For example, you can set `image.tag=12.0.0-my-custom-image-0.1` in the `values.yaml` or from the `helm` command line to override the default tags.
See the corresponding Helm chart README for the available image tag values.

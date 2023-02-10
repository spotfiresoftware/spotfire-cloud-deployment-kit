# How versions are related

This project uses different version types: GIT repository, applications, container images, and Helm charts versions.
                                                                           
This table summarizes the relationship of the different version types within the context of the Cloud Deployment Kit for TIBCO Spotfire recipes.

| Version type           | Description                                 | Defined in                                    | How it is defined                                                                                                     | How the provided Makefiles use it                                                                                                                                                | Examples of its use                                                                                     |
|------------------------|---------------------------------------------|-----------------------------------------------|-----------------------------------------------------------------------------------------------------------------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|---------------------------------------------------------------------------------------------------------|
| CDK for TIBCO Spotfire | The release version of this GIT repository  | [versions.mk](../versions.mk)                 | `CLOUD_DEPLOYMENT_KIT_VERSION=1.0.0`                                                                                  | - Tag the CDK for TIBCO Spotfire git repository                                                                                                                                  | - `git tag -l`                                                                                          |
| Application            | The version of the main contained component | [versions.mk](../versions.mk)                 | `SPOTFIRE_SERVER_VERSION=12.0.0`                                                                                      | - Extract packages from the `downloads` directory into the built container<br>- Set the `org.opencontainers.image.version` container label<br>- Set `appVersion` in `Chart.yaml` | - `tss-12.0.0.x86_64.tar.gz`<br>- `org.opencontainers.image.version=12.0.0`<br>- `appVersion: "12.0.0"` |
| Container image        | The built container image version           | [containers/Makefile](../containers/Makefile) | Composed using the Application version and the CDK version:<br>`<APPLICATION_VERSION>-<CLOUD_DEPLOYMENT_KIT_VERSION>` | - Tag the container image<br>- Refer to the container image tag from the chart `values.yaml`                                                                                     | - `tibco/spotfire-server:12.0.0-1.0.0`<br>- `image.tag: "12.0.0-1.0.0"`                                 |
| Helm chart             | The packaged chart version                  | `helm/charts/<chart>/Chart.yaml`              | Chart `version` in the respective `Chart.yaml`; example: `1.0.1`                                                      | - Set the packaged chart version                                                                                                                                                 | - `spotfire-server-1.0.1.tgz`                                                                           |

The default CDK for TIBCO Spotfire and Application versions are configured in the [versions.mk](../versions.mk) file.

## Build container images with other application versions

You can use other application versions by modifying the related files for each case. 
For example, you can build a new container image with the latest released application version.

For this specific case, modify the component version in [versions.mk](../versions.mk) (for example, `SPOTFIRE_SERVER_VERSION=12.0.1`),
put that application component version in the `containers/downloads` directory, and then build the new containers using `make` from the `containers/` directory.

## Build container images using custom tags

If you run `make` from the `containers/` directory without arguments, it tags the built images with the tag `<APPLICATION_VERSION>-<CLOUD_DEPLOYMENT_KIT_VERSION>`.
You can override the second part of the image tag (`<CLOUD_DEPLOYMENT_KIT_VERSION>`) using the `IMAGE_BUILD_ID` argument. For example:

```
make IMAGE_BUILD_ID=my-custom-image-0.1 build
```

This strategy is useful to mark your container recipes as custom images when they deviate from the default recipes for a specific Cloud Deployment Kit Version.

## Use Helm charts with other container image versions

You can use other container image versions than the default versions configured in the Helm charts. 
For that, you can use your custom `image.tag` value within the corresponding chart `values.yaml` file.

For example, set `image.tag=12.0.0-my-custom-image-0.1` from the `helm` command line or using the `values.yaml` file to override the default tags.
See the corresponding Helm chart README for the available image tag values.

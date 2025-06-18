# Licenses

There are 2 different Spotfire products that you can use to deploy Spotfire on a [cloud native computing](https://en.wikipedia.org/wiki/Cloud-native_computing) environment:
- The **[Cloud Deployment Kit for Spotfire®](https://github.com/spotfiresoftware/spotfire-cloud-deployment-kit)** (aka Spotfire CDK) is the build system for building the Spotfire® container images and Helm charts. The Spotfire CDK is licensed under the [Apache 2.0 license](https://github.com/spotfiresoftware/spotfire-cloud-deployment-kit/blob/main/LICENSE), but the software components included in the images and charts may have different licenses.
- **[Spotfire on Kubernetes®](../index.md)** is the pre-built official Spotfire® container images and Helm charts, using the Spotfire CDK. This is a commercial product.

Whether you directly consume the **Spotfire on Kubernetes** pre-built images and charts, or you build them using the **Spotfire CDK**, you need to be aware of the licenses that apply to the software components included in these images and charts.

## Spotfire software

When you build or use the Spotfire container images, you fetch and use Spotfire software developed at [Cloud Software Group, Inc](https://www.cloud.com/). Spotfire software running in this container will be governed by the terms of the [Cloud Software Group, Inc. End User Agreement](https://www.cloud.com/legal/terms).

Each of the Spotfire container images includes the applicable Spotfire application license file(s), which include a copy of the Cloud Software Group, Inc. End User Agreement, and the list of included Open Source Software components with their associated licenses. 
This list was generated using third party software as of the date listed in the file. This list may change with specific application versions of the product and may not be complete; it is provided “As-Is.”

See [how to fetch the applicable Spotfire application license file(s) from the container images](https://github.com/spotfiresoftware/spotfire-cloud-deployment-kit/blob/main/containers/README.md#licenses).

## Other software

When you build or use the Spotfire container images, you fetch and use other software components that are subject to their own licenses. See [how to analyze container images to identify included artifacts and their individual licenses](analyze-container-image-licenses.md).

When you build or use the Helm charts, you fetch and use other charts that might fetch other container images, each with their own licenses. 
A partial summary of the third party software and licenses used with the Spotfire CDK and Spotfire on Kubernetes is available in [here](other-software.md).

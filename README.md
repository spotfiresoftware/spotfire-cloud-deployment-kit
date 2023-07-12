# Cloud Deployment Kit for TIBCO Spotfire

## Overview

The **Cloud Deployment Kit for TIBCO Spotfire®** provides a reference and starting point for deploying [TIBCO Spotfire®](https://www.tibco.com/products/tibco-spotfire) using [containers](https://www.docker.com/resources/what-container) and [Helm charts](https://helm.sh/) on a [Kubernetes cluster](http://kubernetes.io/).

This repository contains recipes to build container images and Helm charts for certain **TIBCO Spotfire®** products.
You can extend and customize these recipes and examples.

This repository does not include TIBCO Spotfire® software or other third party software.
This repository contains quick guides, templates, configuration examples, and scripts.

The recipes have been validated with the Spotfire® releases identified in [Spotfire components versions](versions.mk).
They might work for other Spotfire versions with some modifications.
For more information, see [how versions are related](docs/how-versions-are-related.md).

**Note**: TIBCO Spotfire products are commercially licensed products and are subject to the payment of license fees.
You must have a valid license for each of the TIBCO Spotfire applications you choose to build and run in a container.
Additional license fees might be due to TIBCO for the license rights required to deploy a TIBCO product to a Cloud Computing Environment.
Carefully review the [TIBCO Cloud Computing Environment Licensing Policy (“CCEL Policy")](https://terms.tibco.com/#ccel-policy-12012021) to understand the requirements, including how to calculate the number of Processor Units that you must license when a TIBCO product is deployed in a Cloud Computing Environment.

## Prerequisites

- Required TIBCO Spotfire installation packages. If you have a TIBCO account, you can download the packages from [TIBCO eDelivery](https://edelivery.tibco.com/storefront/index.ep).
- Kubernetes 1.24+, a working Kubernetes cluster from a [certified K8s distro](https://www.cncf.io/certification/software-conformance/).
- Helm 3+, for building and deploying the charts.
- An [OCI-compliant](https://opencontainers.org/) container image building tool (for example, `docker`, `podman`, or alternative), for building the container images.

## Components

The following applications have been validated in this _Cloud Deployment Kit (CDK) for TIBCO Spotfire_:
- TIBCO Spotfire® Server
- TIBCO Spotfire® Web Player
- TIBCO Spotfire® Automation Services
- TIBCO Spotfire® Service for Python
- TIBCO Spotfire® Service for R
- TIBCO® Enterprise Runtime for R - Server Edition (TERR™ service)

**Note**: For more information on TIBCO Spotfire® and its components, see the [TIBCO Spotfire® Documentation](https://docs.tibco.com/products/tibco-spotfire/).

Using the provided charts, you can also deploy the following:
- The required Spotfire Server® database schemas on a supported database server (for example, PostgreSQL).
- A reverse proxy ([HAProxy](https://www.haproxy.org/)) for accessing the Spotfire Server cluster service, with session affinity for external HTTP access.
- An [Ingress](https://kubernetes.io/docs/concepts/services-networking/ingress/) with routing rules for accessing the configured reverse proxy.
- Shared storage locations ([Persistent Volumes](https://kubernetes.io/docs/concepts/storage/persistent-volumes/)) for the Spotfire Library import and export, custom jars, deployment packages, and so on.

**Note**: For information on sizing and supported third party software, see the [System requirements for TIBCO Spotfire® products](https://spotfi.re/sr/).

## Basic workflow

1. Fetch the required [Spotfire installation packages](containers/README.md#prerequisites).
2. Build and push the [Spotfire container images](containers/README.md#build-the-images).
3. Build and publish the [Spotfire helm charts](helm/README.md#building-the-charts).
4. Deploy your Spotfire environment using the [Spotfire helm charts](helm/README.md).

# Issues

You are welcome to raise issues and improvements related to this project in the [GitHub Issues tab](https://github.com/TIBCOSoftware/spotfire-cloud-deployment-kit/issues).

For issues related to the TIBCO Spotfire products, use the [TIBCO support channel](https://support.tibco.com/s/).

For improvements related to the TIBCO Spotfire products, use the [TIBCO Ideas portal](https://ideas.tibco.com/).

For issues related to third party products, see their respective documentation.

# License

This project (_Cloud Deployment Kit for TIBCO Spotfire_) is licensed under the [Apache 2.0 License](LICENSE).

## Other software

When you build and use the container images, you fetch and use other software components that are subject to their own licenses. 
See how to [analyze container images to identify included artifacts and their individual licenses](docs/analyze-container-image-licenses.md).

When you build and use the helm charts, you fetch and use other charts that might fetch other container images, each with their own licenses. 
A partial summary of the third party software and licenses used in this project is available [here](docs/third-party-software-licenses.md).

---

Copyright 2022-2023 Cloud Software Group, Inc.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at
[http://www.apache.org/licenses/LICENSE-2.0](http://www.apache.org/licenses/LICENSE-2.0)

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

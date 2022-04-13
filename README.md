# Cloud Deployment Kit for TIBCO Spotfire

## Overview

The purpose of the **Cloud Deployment Kit for TIBCO Spotfire®** is to provide a reference and starting point for the deployment of certain [TIBCO Spotfire® Platform](https://www.tibco.com/products/tibco-spotfire) products using [containers](https://www.docker.com/resources/what-container) and [Helm charts](https://helm.sh/) on a [Kubernetes cluster](http://kubernetes.io/).

This repository contains recipes to build container images and Helm charts for certain **TIBCO Spotfire® Platform** products.
You can extend and customize these recipes and examples.

This repository does not include any TIBCO Spotfire® software or any other third party software.
The repository contains quick guides, templates, configuration examples, and scripts.

The recipes have been validated with the Spotfire® releases identified in [Spotfire components versions](versions.mk).
They could work for some previous Spotfire versions with some modifications.

**Note**: TIBCO Spotfire products are commercially licensed products and are subject to the payment of license fees.
You must have a valid license for each of the TIBCO Spotfire applications you choose to build and run in a container.
Additional license fees may be due to TIBCO for the license rights required to deploy a TIBCO product to a Cloud Computing Environment.
Please carefully review the [TIBCO Cloud Computing Environment Licensing Policy (“CCEL Policy")](https://terms.tibco.com/#ccel-policy-12012021) to understand the requirements, including how to calculate the number of Processor Units which you must license when a TIBCO product is deployed in a Cloud Computing Environment.

## Prerequisites

- Required TIBCO Spotfire installation packages. If you have a TIBCO account, you may download the packages from [TIBCO eDelivery](https://edelivery.tibco.com/storefront/index.ep).
- Kubernetes 1.23+, a working Kubernetes cluster from a [certified K8s distro](https://www.cncf.io/certification/software-conformance/).
- Helm 3+, for building and deploying the charts.
- An [OCI-compliant](https://opencontainers.org/) container image building tool (for example, `docker`, `podman`, `buildah` or alternative), for building the container images.

## Components

The following applications have been validated in this _Cloud Deployment Kit (CDK) for TIBCO Spotfire_:
- TIBCO Spotfire® Server
- TIBCO Spotfire® Service for Python (Python service)
- TIBCO® Enterprise Runtime for R - Server Edition (TERR service)

**Note**: We plan to add recipes for additional Spotfire applications. Stay tuned.

**Note**: For more information on the TIBCO Spotfire® Platform and components, see the [TIBCO Spotfire® Documentation](https://docs.tibco.com/products/tibco-spotfire/).

Using the provided charts, you can also deploy the following:
- The required Spotfire Server® database schemas on a supported database server (e.g. PostgreSQL).
- A reverse proxy ([HAProxy](https://www.haproxy.org/)) for accessing the Spotfire Server cluster service, with session affinity for external HTTP access.
- An [Ingress](https://kubernetes.io/docs/concepts/services-networking/ingress/) with routing rules for accessing the configured reverse proxy.
- Shared storage locations ([Persistent Volumes](https://kubernetes.io/docs/concepts/storage/persistent-volumes/)) for the Spotfire Library import and export, custom jars, deployment packages, etc.

**Note**: For information on recommended sizing and supported third party software, see [System requirements for TIBCO Spotfire® products](https://spotfi.re/sr/).

## Basic workflow

1. Fetch the required [Spotfire installation packages](docker/README.md#prerequisites).
2. Build and push the [Spotfire container images](docker/README.md#build-the-images).
3. Build and publish the [Spotfire helm charts](helm/README.md#build-the-charts).
4. Deploy your Spotfire environment using the [Spotfire helm charts](helm/README.md).

# License

This project (_Cloud Deployment Kit for TIBCO Spotfire_) is licensed under the [Apache 2.0 License](LICENSE).

## Other software

When you build and use the container images, you will be fetching and using other software components that are subject to their own licenses. 
See how to [analyze container images to identify included artifacts and their individual licenses](docs/analyze-container-image-licenses.md).

When you build and use the helm charts, you will be fetching and using other charts that may fetch other container images, each with their own licenses. 
A partial summary of the third party software and licenses used in this project is available [here](docs/third-party-software-licenses.md).

---

Copyright 2022 TIBCO Software Inc.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at
[http://www.apache.org/licenses/LICENSE-2.0](http://www.apache.org/licenses/LICENSE-2.0)

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

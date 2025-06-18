# Welcome to the Spotfire on Kubernetes User Guide

[Spotfire](https://www.spotfire.com/) is a visual data science platform that enhances your analytical capabilities with interactive visualizations and advanced analytics.

**Spotfire on Kubernetes®** is the set of official pre-built container images and Helm charts to deploy Spotfire on any [certified Kubernetes distribution](https://www.cncf.io/certification/software-conformance/) (version >= {{ MIN_KUBERNETES_VERSION }}).
These images and charts are built using the recipes from the [Cloud Deployment Kit for Spotfire](https://github.com/spotfiresoftware/spotfire-cloud-deployment-kit), which is available on GitHub. 

This user guide covers information about how to use Spotfire on Kubernetes.

## Relation between the Spotfire Cloud Deployment Kit and Spotfire on Kubernetes

The **Cloud Deployment Kit for Spotfire®** provides the foundational tools and resources needed to build and extend container images and Helm charts for Spotfire. It is ideal for advanced users who wish to customize their deployment. However, in most cases, using the pre-built container images and Helm charts should be sufficient for deploying Spotfire on Kubernetes.

### When to use what

- **Spotfire on Kubernetes**: Use the pre-built container images and Helm charts for a straightforward deployment of Spotfire on any certified Kubernetes distribution. 
  This is the most common choice, supporting most common configuration scenarios.
- **Cloud Deployment Kit for Spotfire®**: Use this kit if you need to extend or build custom images and charts, to adapt them to your specific needs. 
  Refer to the [Cloud Deployment Kit for Spotfire®](https://github.com/spotfiresoftware/spotfire-cloud-deployment-kit) for detailed guidance.

    Examples of when you might need to extend or customize an image include:
      - Requiring custom or extra ODBC drivers for database connectivity.

## Included in release v{{ SPOTFIRE_CDK_VERSION }}

This release includes container images and Helm charts for the following products:

{% include 'release/table.inc' %}

For the release notes and information about how other Spotfire releases map to the container images and Helm charts versions, see the [Spotfire Cloud Deployment Kit releases page](https://github.com/spotfiresoftware/spotfire-cloud-deployment-kit/releases).

For information on the Spotfire release types (LTS and innovation releases) and their cadence, see the [Spotfire releases overview](https://spotfi.re/lts).

For getting to know about the new features on each Spotfire release, see [What's new in Spotfire®](https://www.spotfire.com/whats-new).

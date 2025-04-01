# Quick start Guide

This quick start guide will describes how to get started with Spotfire containers and helm charts by consuming already built artifacts.

## Install & configure kubectl

You need to have access to a kubernetes cluster.  If needed, install and configure [kubectl](https://kubernetes.io/docs/reference/kubectl/) to use it.

Option A:

- [ ] Know somebody who can give you access to a cluster, configure it.

Option B:

- [ ] Install [Docker Desktop with WSL 2 backend](https://docs.docker.com/desktop/windows/wsl/). 
- [ ] [Configure Docker desktop to use Spotfire Artifactory Server as a registry](https://confluence.tibco.com/pages/viewpage.action?spaceKey=DEV&title=How+to+configure+Docker+Desktop)
- [ ] Check the [Enable Kubernetes](https://docs.docker.com/desktop/kubernetes/) option in Docker Desktop

## Install helm

Install Helm using [official docs](https://helm.sh/docs/intro/install/).

## Install Spotfire

The most simple way to get started is to run the spotfire chart which deploys a database, spotfire server and optionally a set of different services.

Install Spotfire Server chart using the release name `my-release`:
```bash
helm upgrade --install my-release oci://artifactory.spotfire.com/spotfire/main/latest/spotfire-platform \
  --namespace=default \
  --render-subchart-notes \
  --set global.spotfire.acceptEUA=true \
  --set spotfire-webplayer.enabled=true \
  --set spotfire-pythonservices.enabled=false \
  --set spotfire-rservice.enabled=false \
  --set spotfire-terrrservice.enabled=false \
  --set spotfire-server.ingress.enabled=true \
  --set spotfire-server.configuration.site.publicAddress=http://<subdomain>.k8.engrlab.test \
  --set spotfire-server.ingress.hosts[0].host=<subdomain>.k8.engrlab.test
```

- Add `--version <version>` to specify a specific chart version. See `helm/charts/spotfire-platform/Chart.yaml` which version of the spotfire chart that is current. 
- Set a unique subdomain. Remove this option if you are nog using the engrlab.test kubernetes environment. The publicAddress is required.
- Look in the output for what command you need to run to access the environment and get the 'admin' password. You should within a few minutes have an environment available at http(s)://\<subdomain\>.k8.engralab.test/.

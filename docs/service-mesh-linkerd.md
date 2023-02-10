# Example: Service mesh with Linkerd for mTLS communication between pods

This document demonstrates using podAnnotations to inject the [Linkerd](https://linkerd.io/) service mesh. Linkerd transparently adds mutual TLS to any on-cluster TCP communication with no configuration.
For more information, see [Getting started](https://linkerd.io/getting-started/) with Linkerd.

To inject Linkerd, ensure that the resources that use Linkerd have annotations that can be added in one of the following ways.

- explicit: add linkerd.io/inject annotation per resource - See below.
- implicit: add linkerd.io/inject annotation for a namespace - Just annotate the namespace with `linkerd.io/inject: enabled`.

When injecting Linkerd on the namespace level, the config-job does not finish because the Linkerd proxy sidecar on the jobs prevents it from finishing, but the job remains until it is removed manually.

The following example shows how to add Linkerd injection annotations explicitly to all pods in the spotfire-server chart.

```yaml
podAnnotations:
  linkerd.io/inject: enabled

cliPod:
  podAnnotations:
    linkerd.io/inject: enabled

log-forwarder:
  podAnnotations:
    linkerd.io/inject: enabled

haproxy:
  podAnnotations:
    linkerd.io/inject: enabled

# Do not add linkerd annotations for configJob
configJob:
  podAnnotations: {}
```

For service charts, you can just set (.Values.)podAnnotations.

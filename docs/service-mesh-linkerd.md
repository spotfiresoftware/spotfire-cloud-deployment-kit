# Example: Service mesh with linkerd for mTLS communication between pods

This document demonstrates using podAnnotations to inject the Linkerd service mesh. Linkerd transparently adds mutual TLS to any on-cluster TCP communication with no configuration. See [Getting started](https://linkerd.io/getting-started/) with linkerd.

To inject linkerd, ensure that the resources that use linkerd have annotations that can be added in one of the following ways.

- explicit: add linkerd.io/inject annotation per resource - See below.
- implicit: add linkerd.io/inject annotation for a namespace - Just annotate the namespace with `linkerd.io/inject: enabled`.

When injecting linkerd on the namespace level, the config-job does not finish because the linkerd proxy sidecar on the jobs prevents it from finishing, but the job remains until it is removed manually.

The following example shows how to add linkerd injection annotations explicitly to all pods in the spotfire-server chart.

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

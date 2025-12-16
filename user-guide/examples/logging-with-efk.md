# Logging with EFK stack

For application logging, the Spotfire Helm charts are validated with the EFK stack:
- [Elastic](https://www.elastic.co/elasticsearch/)
- [FluentBit](https://fluentbit.io/)
- [Kibana](https://www.elastic.co/kibana/)

This page provides an overview of the steps to get the Spotfire application logging into Elasticsearch and visualize it with Kibana.

**Note:** This is a quick start guide. For more information, see the official documentation of the vendors.

## Prerequisites

- You have deployed Spotfire using the provided Spotfire Helm charts.

## Components

### FluentBit

Optional: You can deploy [FluentBit](https://fluentbit.io/) using the Spotfire Server chart. It is deployed as service called `log-forwarder`.

By default, the Spotfire Server and the Spotfire services send their logs to the `log-forwarder` service, which, in turn, forwards the logs to [stdout](https://docs.fluentbit.io/manual/pipeline/outputs/standard-output).

You can configure the `log-forwarder` service to forward the logs to other destinations.
FluentBit supports output to many services.
For more information, see [FluentBit output plugins](https://docs.fluentbit.io/manual/pipeline/outputs).


### Collect logs temporarily, for example, when troubleshooting, with an additional forwarding target

By default, Spotfire pods keep a small amount of logs on disk, and if there are temporary situations where more information should be kept, for example, for troubleshooting purposes, it is possible to add an additional target for log events if log forwarding is enabled.

In this case, [fluentd](https://docs.fluentd.org/) is added as a log event receiver and all log events are written to disk; one file every 10 minutes. If there is a large amount of log events, a persistent volume or similar is needed to avoid that the fluentd container runs out of disk space. Use [troubleshooting.logcollection.yaml](logging/troubleshooting.logcollection.yaml) as a starting point for a working example.

```bash
helm install logcollection fluent/fluentd --namespace <namespace> --values troubleshooting.logcollection.yaml
```

Then, re-configure the `log-forwarder` service to also forward the Spotfire logs to this temporary fluentd log receiver.

```yaml
spotfire-server:
  log-forwarder:
    config:
      outputs: |
        ... existing outputs
        # temporary output to capture information
        [OUTPUT]
            Name            forward
            Match_Regex     (tss|tsnm)\..*
            Host            logcollection-fluentd
            Port            24224
```

When enough information have been collected, copy the files.

```bash
logcollection_pod=$(kubectl get pods --namespace "<namespace>" -l "app.kubernetes.io/name=fluentd,app.kubernetes.io/instance=logcollection" -o jsonpath="{.items[0].metadata.name}")
kubectl cp --namespace "<namespace>" --container="fluentd" "${logcollection_pod}:/spotfire/logs" "./"
```

#### Cleanup

1. Re-configure the `log-forwarder` service again, and remove the additional forwarding output.

2. Delete the helm `logcollection` installation.
```bash
helm uninstall logcollection --namespace <namespace>
```
### Forward Spotfire logs to Elasticsearch

To forward the logs to Elasticsearch, use the [FluentBit output for Elasticsearch](https://docs.fluentbit.io/manual/pipeline/outputs/elasticsearch).
You can apply the configuration in your Spotfire chart values file using a similar snippet, as in the [log.forwarder.elasticsearch.yaml](logging/log.forwarder.elasticsearch.yaml).

Example:
```bash
helm install --set acceptEUA=true my-spotfire-release . -f log.forwarder.elasticsearch.yaml
```
### Elasticsearch

#### Installing

1. Add the [Elastic charts](https://github.com/elastic/helm-charts) repo:
    ```bash
    helm repo add elastic https://helm.elastic.co
    helm repo update
    ```

2. Install Elasticsearch in its own namespace:
    ```bash
    kubectl create namespace elastic
    helm install elasticsearch elastic/elasticsearch --set replicas=1 --namespace elastic
    ```

    **Note:** You can use just one Elastic pod replica for testing purposes.

For more information, see the [Elasticsearch Helm chart documentation](https://github.com/elastic/helm-charts/blob/main/elasticsearch/README.md)
and the [Elasticsearch documentation](https://www.elastic.co/elasticsearch/).

### Kibana

#### Installing

1. Install Kibana in the elastic namespace:
    ```bash
    helm install kibana elastic/kibana --namespace elastic
    ```

For more information, see the [Kibana Helm chart documentation](https://github.com/elastic/helm-charts/tree/main/kibana)
and the [Kibana documentation](https://www.elastic.co/kibana/).

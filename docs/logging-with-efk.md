# Logging with EFK stack

For application logging, the Spotfire Helm charts are validated with the EFK stack: 
- [Elastic](https://www.elastic.co/elasticsearch/)
- [FluentBit](https://fluentbit.io/)
- [Kibana](https://www.elastic.co/kibana/)

This page provides an overview of the steps to get the Spotfire application logging into Elasticsearch and visualize it with Kibana.

**Note**: This is a quick start guide. For more information, see the official documentation.

## Prerequisites

- You have deployed Spotfire using the provided [Spotfire Helm charts](../helm/README.md).

## Components

### FluentBit

Optional: You can deploy [FluentBit](https://fluentbit.io/) using the Spotfire Server chart. It is deployed as service called `log-forwarder`.

By default, the Spotfire Server and the Spotfire services send their logs to the `log-forwarder` service, which, in turn, forwards the logs to [stdout](https://docs.fluentbit.io/manual/pipeline/outputs/standard-output).

You can configure the `log-forwarder` service to forward the logs to other destinations. 
FluentBit supports output to many services.
For more information, see [FluentBit output plugins](https://docs.fluentbit.io/manual/pipeline/outputs).

### Forward Spotfire logs to Elasticsearch

To forward the logs to Elasticsearch, use the [FluentBit output for Elasticsearch](https://docs.fluentbit.io/manual/pipeline/outputs/elasticsearch).
You can apply the configuration in your Spotfire chart values file using a similar snippet, as in the [log.forwarder.elasticsearch.yaml](examples/logging/log.forwarder.elasticsearch.yaml).

**Example**:
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

    **Note**: You can use just one Elastic pod replica for testing purposes.

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

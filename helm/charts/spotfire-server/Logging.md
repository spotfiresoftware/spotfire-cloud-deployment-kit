# Logging

For application logging, Spotfire charts has been tested with EFK stack (Elastic-Fluentd-Kibana).

Follow the steps to get spotfire application logging in Elasticsearch and visualize them with Kibana.

## Prerequisites

You have deployed Spotfire Platform using the provided [Spotfire helm charts](../../README.md).

## Components

### Elasticsearch

#### Install

1. Add Elasticsearch charts repo.
    ```bash
    helm repo add elastic https://helm.elastic.co
    helm repo update
    ```

2. Install Grafana.
    ```bash
    helm install elasticsearch elastic/elasticsearch
    ```

For more information, see [Elasticsearch site](https://www.elastic.co/) and [elasticsearch helm documentation](https://github.com/elastic/helm-charts/blob/main/elasticsearch/README.md).

### Kibana

#### Install

- Kibana, refer [kibana helm
  documentation](https://github.com/elastic/helm-charts/blob/main/kibana/README.md) for details.

### How to forward logs to elasticsearch

By default, spotfire server sends logs to log-forwarder, which in turn forwards logs to [stdout](https://docs.fluentbit.io/manual/pipeline/outputs/standard-output).

To send logs to [elasticsearch](https://docs.fluentbit.io/manual/pipeline/outputs/elasticsearch), follow below example.

```bash
helm install my-spotfire-release . -f log.forwarder.elasticsearch.yaml 
```
Example value file: [log.forwarder.elasticsearch.yaml](example/logging/log.forwarder.elasticsearch.yaml).

### How to forward logs to other destinations
For other output destinations, see [fluent-bit documentation.](https://docs.fluentbit.io/manual/pipeline/outputs) 

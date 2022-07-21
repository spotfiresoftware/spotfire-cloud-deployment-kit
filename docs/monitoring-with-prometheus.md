# Monitoring with Prometheus and Grafana

For application monitoring, the Spotfire charts are validated with [Prometheus](https://prometheus.io/) and [Grafana](https://grafana.com/).

This page provides an overview of the steps to get Spotfire application metrics in Prometheus and visualize them with Grafana.

**Note**: This a quick start guide. For more information, see the official documentation.

## Prerequisites

- You have deployed Spotfire using the provided [Spotfire Helm charts](../helm/README.md).

## Components

### Prometheus

#### Installing

1. Add the [Prometheus community Helm charts](https://github.com/prometheus-community/helm-charts/) repo.
   ```bash
   helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
   ```

2. Install Prometheus.
   ```bash
   helm install prometheus prometheus-community/prometheus --create-namespace --namespace monitor --set nodeExporter.hostRootfs=false
   ```

3. Get the Prometheus server URL.
   ```bash
   export POD_NAME=$(kubectl get pods --namespace monitor -l "app=prometheus,component=server" -o jsonpath="{.items[0].metadata.name}")
   kubectl --namespace monitor port-forward $POD_NAME 9090 --address 0.0.0.0 > /dev/null &
   ```

For more details about Prometheus, see the [Prometheus Community Helm charts documentation](https://github.com/prometheus-community/helm-charts/blob/main/charts/prometheus/README.md)
and the [Prometheus documentation](https://prometheus.io/).

### Grafana

#### Installing

1. Add the [Grafana chart](https://github.com/grafana/helm-charts/tree/main/charts/grafana) repo.
    ```bash
    helm repo add grafana https://grafana.github.io/helm-charts
    helm repo update
    ```

2. Install Grafana.
    ```bash
    helm install grafana grafana/grafana -n monitor
    ```

3. After Grafana is deployed, get your Grafana UI `admin` user password.
    ```bash
    kubectl get secret --namespace monitor grafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo
    ```

4. Set port-forwarding to access the Grafana URL.
    ```bash
    export POD_NAME=$(kubectl get pods --namespace monitor -l "app.kubernetes.io/name=grafana,app.kubernetes.io/instance=grafana" -o jsonpath="{.items[0].metadata.name}")
    kubectl --namespace monitor port-forward $POD_NAME 3000 --address 0.0.0.0 > /dev/null &
    ```

5. Log in to the Grafana web interface [http://localhost:3000]() with the user `admin` and the password from previous step.

For more information, see the [Grafana Helm chart documentation](https://github.com/grafana/helm-charts/blob/main/charts/grafana/README.md) and the [Grafana documentation](https://grafana.com/oss/grafana/).

#### Configuring

1. [Add a metrics datasource](https://grafana.com/tutorials/grafana-fundamentals/?utm_source=grafana_gettingstarted#add-a-metrics-data-source) pointing to your Prometheus server.
2. [Import a dashboard](https://grafana.com/docs/grafana/latest/dashboards/export-import/) using a previously-exported dashboard as a JSON file, or by dashboard ID.
    - Start exploring with the [Spotfire Platform](examples/monitoring/Spotfire-Platform-grafana-dashboard.json) dashboard example. 
    - Try out other community [Grafana dashboards](https://grafana.com/grafana/dashboards/).
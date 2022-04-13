# Monitoring

This page provides an overview of the steps for monitoring Spotfire Platform with Prometheus and Grafana.

Follow the steps to get spotfire metrics in Prometheus and visualize them with Grafana.

## Prerequisites

You have deployed Spotfire Platform using the provided [Spotfire helm charts](../../README.md).

## Components

### Prometheus

1. Add the [prometheus-community helm charts](https://github.com/prometheus-community/helm-charts/) repo.
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

For more details on Prometheus, see [Prometheus Community charts](https://github.com/prometheus-community/helm-charts/blob/main/charts/prometheus/README.md)
and [Prometheus site](https://prometheus.io/).

### Grafana

#### Install

1. Add Grafana charts repo.
    ```bash
    helm repo add grafana https://grafana.github.io/helm-charts
    helm repo update
    ```

2. Install Grafana.
    ```bash
    helm install grafana grafana/grafana -n monitor
    ```

3. Once deployed, get your Grafana UI `admin` user password.
    ```bash
    kubectl get secret --namespace monitor grafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo
    ```
 
4. Set port-forwarding to access the Grafana URL:
    ```bash
    export POD_NAME=$(kubectl get pods --namespace monitor -l "app.kubernetes.io/name=grafana,app.kubernetes.io/instance=grafana" -o jsonpath="{.items[0].metadata.name}")
    kubectl --namespace monitor port-forward $POD_NAME 3000 --address 0.0.0.0 > /dev/null &
    ```

5. Login to Grafana web interface [http://localhost:3000]() with user `admin` and the password from previous step.

For more information, see the [Grafana chart](https://github.com/grafana/helm-charts/blob/main/charts/grafana/README.md).

#### Configuration

For Grafana dashboard setup,
1. Create datasource pointing to correct Prometheus server.
2. Import configuration using Existing JSON or dashboard ID.
    - See dashboard example for [Spotfire Platform](example/Spotfire-Platform-grafana-dashboard.json).
3. For more dashboards, see it [Grafana dashboards](https://grafana.com/grafana/dashboards/). Examples:
    - [HAProxy dashboard for Grafana ](https://grafana.com/grafana/dashboards/12030)
    - [Kubernetes Monitoring dashboard for Grafana](https://grafana.com/grafana/dashboards/12740)

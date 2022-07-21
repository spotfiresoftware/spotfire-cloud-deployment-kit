# Autoscaling

For application-horizontal autoscaling, the Spotfire charts are validated with [KEDA (Kubernetes Event-driven Autoscaling)](https://keda.sh/docs).

**Note**: This is a quick start guide. For more information, see the official documentation.

## Prerequisites

- You have deployed Spotfire using the provided [Spotfire Helm charts](../helm/README.md).
- You have deployed Prometheus for metrics management. See [Monitoring with Prometheus](monitoring-with-prometheus.md).

## Components

### KEDA

#### Installing

1. Add the [KEDA charts](https://github.com/kedacore/charts/tree/main/keda) repo.
    ```bash
    helm repo add kedacore https://kedacore.github.io/charts
    helm repo update
    ```

2. Install KEDA in its own namespace.
    ```bash
    kubectl create namespace keda
    helm install keda kedacore/keda --namespace keda --set http.timeout=10000
    ```

   **Note**: In some environments, you must increase the _Scalers_ timeout. See [HTTP Timeouts](https://keda.sh/docs/latest/operate/cluster/#http-timeouts).

For more information, see the [KEDA Helm chart documentation](https://github.com/kedacore/charts/tree/main/keda) and the [KEDA documentation](https://keda.sh/docs/latest/deploy/).

# spotfire-umbrella-example

This is an example that you can use as a reference to create an umbrella chart to deploy a complete [TIBCO Spotfire® environment](https://docs.tibco.com/pub/spotfire_server/latest/doc/html/TIB_sfire_server_tsas_admin_help/server/topics/introduction_to_the_tibco_spotfire_environment.html) on a [Kubernetes](http://kubernetes.io/) cluster using the [Helm](https://helm.sh/) package manager.

The chart can deploy the following Spotfire components:

- [spotfire-server](../../charts/spotfire-server/README.md): TIBCO Spotfire Server helm chart.
- [spotfire-webplayer](../../charts/spotfire-webplayer/README.md): TIBCO Spotfire Web Player helm chart.
- [spotfire-automationservices](../../charts/spotfire-automationservices/README.md): TIBCO Spotfire Automation Services helm chart.
- [spotfire-rservice](../../charts/spotfire-rservice/README.md): TIBCO Spotfire Service for R helm chart.
- [spotfire-pythonservice](../../charts/spotfire-pythonservice/README.md): TIBCO Spotfire Service for Python helm chart.
- [spotfire-terrservice](../../charts/spotfire-terrservice/README.md): TIBCO Enterprise Runtime for R - Server Edition helm chart.

### Deploy multiple services with different configuration using aliases

This umbrella chart uses the [alias field in Chart dependencies](https://helm.sh/docs/topics/charts/#alias-field-in-dependencies)
as an example of usage of different Spotfire service instances with different configuration settings within the same deployment.
For example, you might deploy separate Spotfire Web Player pools, or deploy different groups of services belonging to separated Spotfire sites or deployment areas.

Example: With the provided `Chart.yaml`, you can deploy 2 different Web Player pools, identified in the `values.yaml` file by different values for alias.
```yaml
- name: spotfire-webplayer
  repository: file://../spotfire-webplayer/
  version: 0.1.0
  alias: spotfire-webplayer-pool1
  condition: spotfire-webplayer-pool1.enabled
- name: spotfire-webplayer
  repository: file://../spotfire-webplayer/
  version: 0.1.0
  alias: spotfire-webplayer-pool2
  condition: spotfire-webplayer-pool2.enabled
```

**Note**: You can use alias, such as in the default `Chart.yaml` definition, to create more deployments; for example, to deploy different sets of services for different Spotfire sites.

### Postgresql database

By default, spotfire-umbrella-example chart deploys a PostgreSQL database using the [bitnami/postgresql](https://github.com/bitnami/charts/tree/main/bitnami/postgresql) helm chart and automatically configures the Spotfire Server to use it. No extra configuration is needed unless you want to use an external database. See [../database-values](../database-values/) for examples on how to connect to an external database. To disable the PostgreSQL database deployment, set `spotfire-server.postgresql.enabled` to `false`.

Note: Using the PostgreSQL database like this is not recommended for production use. Make sure you know how to back up and restore your data when using this chart for other than testing purposes. Persistance is disabled by default for the PostgreSQL database.
### values-*.yaml example files

Each `values-*.yaml` file in this directory is an example of how to configure the umbrella chart to deploy a specific set of Spotfire services. You can use any of these files as a starting point, modify them, and then install the results:

```bash
helm install my-release spotfire-umbrella-example --set global.spotfire.acceptEUA=true --values values-....yaml
```

If you want to see NOTES.txt output for all the subcharts, use the command line argument `--render-subchart-notes`.

Read the comments in each example file to understand what it does and how to configure it.

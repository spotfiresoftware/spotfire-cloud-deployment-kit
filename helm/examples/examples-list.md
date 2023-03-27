# Helm examples

You can find examples on how to use the helm charts in this location.

## [spotfire-umbrella-example](spotfire-umbrella-example/)

The following example umbrella chart deploys a PostgreSQL Spotfire database, Spotfire Automation Services, Spotfire Web Player, Spotfire Service for Python, and TIBCO Enterprise Runtime for R - Server Edition.

## [database-values](database-values/)

Multiple example values files demonstrate connecting to PostgreSQL, Microsoft SQL Server, and Oracle Spotfire databases using the spotfire-server helm chart. Use any of the files as a starting point; modify and then install the results, using the following command.

```
helm install my-release spotfire-server --set acceptEUA=true --values my-database-values.yaml --values ...`
```
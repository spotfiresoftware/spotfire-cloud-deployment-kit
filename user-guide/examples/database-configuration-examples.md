# Database configuration examples

This page provides examples of how to configure the database connection for the different database types supported by the platform.

For more information, see [the create-db reference](https://docs.tibco.com/pub/spotfire_server/latest/doc/html/TIB_sfire_server_tsas_admin_help/server/topics/create-db.html) in the Spotfire documentation, with the "Examples of creating a Spotfire database schema"-sections for each database type at the end.

## PostgreSQL

=== "Standard"
    ```yaml
    --8<-- "helm/charts/spotfire-server/database-example-values/postgres.yaml"
    ```
=== "Aurora"
    ```yaml
    --8<-- "helm/charts/spotfire-server/database-example-values/aurora-postgres.yaml"
    ```
=== "AWS"
    ```yaml
    --8<-- "helm/charts/spotfire-server/database-example-values/aws-postgres.yaml"
    ```
=== "Azure"
    ```yaml
    --8<-- "helm/charts/spotfire-server/database-example-values/azure-postgres.yaml"
    ```

## Microsoft SQL Server

=== "Standard"
    ```yaml
    --8<-- "helm/charts/spotfire-server/database-example-values/mssql.yaml"
    ```
=== "AWS"
    ``` yaml
    --8<-- "helm/charts/spotfire-server/database-example-values/aws-mssql.yaml"
    ```

## Oracle

=== "Standard"
    ```yaml
    --8<-- "helm/charts/spotfire-server/database-example-values/oracle.yaml"
    ```
=== "AWS"
    ```yaml
    --8<-- "helm/charts/spotfire-server/database-example-values/aws-oracle.yaml"
    ```
=== "Azure"
    ```yaml
    --8<-- "helm/charts/spotfire-server/database-example-values/azure-mssql.yaml"
    ```

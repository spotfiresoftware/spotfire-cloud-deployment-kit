
# Configuring an Amazon relational database service with Spotfire

This document lists steps to configure an Amazon relational database service with the Spotfire CDK on Amazon EKS.

## Prerequisites
- Admin access to the Amazon account where the EKS cluster is deployed.
- Access to EKS cluster.
- Kubectl.
- Helm 3+.


## Create an RDS instance
Create a relational database instance in the AWS account, choosing the correct VPC that is associated with the EKS cluster.<br/>

For more information, see [https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER_CreateDBInstance.html](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER_CreateDBInstance.html).

### Migrate current database to RDS database
#### Option 1. Using the Spotfire CLI command `migrate-db`

1. Scale down the Spotfire Server deployment to terminate active database connections.<br/>``` kubectl scale deploy <ReleaseName>-spotfire-server --namespace=<Namespace> --replicas=0```<br/>
   If Keda autoscaling is enabled for the Spotfire server, see [how to pause autoscaling](https://keda.sh/docs/2.13/concepts/scaling-deployments/#pause-autoscaling) and scale down the Spotfire server deployment to zero.

2. In the Spotfire CLI pod, run the command [create-db](https://docs.tibco.com/pub/spotfire_server/latest/doc/html/TIB_sfire_server_tsas_admin_help/server/topics/create-db.html) to create the database schema on the target RDS database. 

3. Run the command [migrate-db](https://docs.tibco.com/pub/spotfire_server/latest/doc/html/TIB_sfire_server_tsas_admin_help/server/topics/migrate-db.html).

<b>Note:</b> You can deploy the config tool CLI pod by running the command<br/>```kubectl run clipodtemp --restart=Never --rm -i --tty --image spotfire/spotfire-config:<Tag> --namespace=<Namespace> --env=ACCEPT_EUA=Y --command -- /bin/bash```

#### Option 2. Using Amazon Database migration service (AWS DMS)
To migrate from an existing PostgreSQL database to Amazon RDS using AWS DMS, see the instructions at [https://aws.amazon.com/tutorials/move-to-managed/migrate-postgresql-to-amazon-rds/](https://aws.amazon.com/tutorials/move-to-managed/migrate-postgresql-to-amazon-rds/).

## Spotfire deployment

### Option 1: Spotfire deployment with RDS secrets in Kubernetes secrets store
&nbsp;&nbsp;&nbsp;&nbsp;<b>Note:</b> This option is considered more secure.

1. Create a Kubernetes secret using the RDS master/admin user password.

Run the following command, replacing the variables in "<>" with the appropriate values.
```bash
kubectl create secret generic "<RDS admin secret name>" --from-literal=DBSERVER_ADMIN_PASSWORD=<RDS master/admin password>
```


2. Install the `spotfire-server` helm chart with the following additional values. 

Replace the variables in "<>" with the appropriate values.
```bash
helm install my-release . \
  --set database.bootstrap.databaseUrl="jdbc:postgresql://<RDS database instance endpoint>/spotfire" \
  --set database.create-db.adminUsername="<RDS database admin username>" \
  --set database.create-db.adminPasswordExistingSecret.name="<RDS database admin secret name>" \
  --set database.create-db.adminPasswordExistingSecret.key="DBSERVER_ADMIN_PASSWORD" \
  --set database.create-db.databaseUrl="jdbc:postgresql://<RDS database instance endpoint>/" \
  --set database.create-db.spotfiredbDbname=spotfire \
  --set database.create-db.enabled=<Set this to true if the Spotfire database is not created yet and you want to create it. Set this to false if the Spotfire database is migrated and is already created.> \
  ....

```
For more information, see the ["Installing" section in the Readme for the `spotfire-server` helm chart](./../../charts/spotfire-server/README.md#installing).


### Option 2: Spotfire deployment with RDS secrets as helm values

Install the `spotfire-server` helm chart with the following additional values.

Replace the variables in "<>" with the appropriate values.
```bash
helm install my-release . \
  --set database.bootstrap.databaseUrl="jdbc:postgresql://<RDS database instance endpoint>/spotfire" \
  --set database.create-db.adminUsername="<RDS database admin username>" \
  --set database.create-db.adminPassword="<RDS database admin password>" \
  --set database.create-db.databaseUrl="jdbc:postgresql://<RDS database instance endpoint>/" \
  --set database.create-db.spotfiredbDbname=spotfire \
  --set database.create-db.enabled=<Set this to true if the Spotfire database is not created yet and you want to create it. Set this to false if the Spotfire database is migrated and is already created.> \
  ....
```

For more information, see the ["Installing" section in the Readme for the `spotfire-server` helm chart](./../../charts/spotfire-server/README.md#installing).
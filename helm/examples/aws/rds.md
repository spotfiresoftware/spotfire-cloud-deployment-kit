
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

To migrate from existing PostgreSQL database to Amazon RDS see [https://aws.amazon.com/tutorials/move-to-managed/migrate-postgresql-to-amazon-rds/](https://aws.amazon.com/tutorials/move-to-managed/migrate-postgresql-to-amazon-rds/).

## Spotfire deployment

### Option 1: Spotfire deployment with RDS secrets in Kubernetes secrets store
&nbsp;&nbsp;&nbsp;&nbsp;<b>Note:</b> This option is considered more secure.

1. Create a Kubernetes secret using the RDS master/admin user password.

Run the following command, replacing the variables in "<>" with the appropriate values.
```bash
kubectl create secret generic "<rds admin secret name>" --from-literal=DBSERVER_ADMIN_PASSWORD=<rds master/admin password>
```


2. Install the `spotfire-server` helm chart with the following additional values.

Replace the variables in "<>" with the appropriate values.
```bash
helm install my-release . \
  --set database.bootstrap.databaseUrl="jdbc:postgresql://<rds database instance endpoint>/spotfire" \
  --set database.create-db.adminUsername="<rds db admin username>" \
  --set database.create-db.adminPasswordExistingSecret.name="<rds db admin secret name>" \
  --set database.create-db.adminPasswordExistingSecret.key="DBSERVER_ADMIN_PASSWORD" \
  --set database.create-db.databaseUrl="jdbc:postgresql://<rds database instance endpoint>/" \
  --set database.create-db.spotfiredbDbname=spotfire \
  --set database.create-db.enabled=true \
  ....

```
For more information, see the ["Installing" section in the Readme for the `spotfire-server` helm chart](./../../charts/spotfire-server/README.md#installing).


### Option 2: Spotfire deployment with RDS secrets as helm values

Install the `spotfire-server` helm chart with the following additional values.

Replace the variables in "<>" with the appropriate values.
```bash
helm install my-release . \
  --set database.bootstrap.databaseUrl="jdbc:postgresql://<rds database instance endpoint>/spotfire" \
  --set database.create-db.adminUsername="<rds db admin username>" \
  --set database.create-db.adminPassword="<rds db admin password>" \
  --set database.create-db.databaseUrl="jdbc:postgresql://<rds database instance endpoint>/" \
  --set database.create-db.spotfiredbDbname=spotfire \
  --set database.create-db.enabled=true \
  ....
```

For more information, see the ["Installing" section in the Readme for the `spotfire-server` helm chart](./../../charts/spotfire-server/README.md#installing).

# Adding an Information Services datasource driver and template

This document describes the steps to add a new Information Services JDBC data source driver and template to the Spotfire environment.

## Prerequisites
- You have created a Kubernetes persistent volume claim of the desired size.


## Creating a persistent volume claim

If you have not created a persistent volume claim, you can do so with the following steps:

1. Create a YAML file for the PVC, for example, `pvc.yaml`:
    ```yaml
    apiVersion: v1
    kind: PersistentVolumeClaim
    metadata:
      name: my-pvc
    spec:
      accessModes:
        - ReadWriteOnce
      resources:
        requests:
          storage: 1Gi
    ```
2. Apply the PVC configuration:
    ```bash
    kubectl apply -f pvc.yaml 
    ```

## Driver deployment

See [Installing database drivers for Information Designer](https://docs.tibco.com/pub/spotfire_server/latest/doc/html/TIB_sfire_server_tsas_admin_help/server/topics/installing_database_drivers_for_information_designer.html) for additional information.<br>
To make the JDBC driver available to the Spotfire server at `<installation directory>/tomcat/custom-ext-informationservices`, follow these steps:

1. Deploy a BusyBox container with the persistent volume mounted on `/drivers` and copy the driver to the `/drivers` folder.

2. Run the following command, replacing `<NAMESPACE>` and `<PERSISTENT-VOLUME-CLAIM-NAME>` with appropriate values:
    
    ```sh
    kubectl apply -f - << EOF
    apiVersion: v1
    kind: Pod
    metadata:
      name: drivers-deployer
      namespace: <NAMESPACE>
    spec:
      volumes:
        - name: drivers-volume
          persistentVolumeClaim:
            claimName: <PERSISTENT-VOLUME-CLAIM-NAME>
      containers:
        - name: drivers-deployment
          image: busybox
          command: [ "top" ]
          volumeMounts:
            - mountPath: "/drivers"
              subPath: "drivers"
              name: drivers-volume
    EOF
    ```

3. Copy the driver file to the volume mount:
    ```bash
    kubectl cp <driver-file-path> <NAMESPACE>/drivers-deployer:/drivers/<driver-file-name>
    ```

4. To make the driver available from the volume mount, install the Spotfire server chart with the following additional values file `custom-ext-information-services-drivers.yaml`.<br>
    For more information on volumes configuration, see the ['Volume for additional JDBC drivers'-section in the Readme for the `spotfire-server` Helm chart](../helm/charts/spotfire-server/README.md#volume-for-additional-jdbc-drivers).
    
    ```yaml
    spotfire-server:
      volumes:
        customExtInformationservices:
          existingClaim: "<PERSISTENT-VOLUME-CLAIM-NAME>"
          subPath: "drivers"
    ```


## Add a data source template to the Spotfire configuration

1. Refer to the spotfire community article [JDBC Data Access Connectivity Details ](https://spotfi.re/community/jdbc-templates) to determine the correct data source template to add. Create an xml file with the template data. For example, for AWS Athena:
    `<DATA-SOURCE-NAME>-ds-template.xml`
    ```xml
    <jdbc-type-settings>
      <type-name>Amazon Athena JDBCv3</type-name>
      <driver>com.amazon.athena.jdbc.AthenaDriver</driver>
      <connection-url-pattern>jdbc:athena://athena.&lt;Region&gt;.amazonaws.com:443;S3OutputLocation=&lt;S3 output bucket&lt;;Region=&lt;AWS_REGION&gt;</connection-url-pattern>
      <supports-catalogs>true</supports-catalogs>
      <supports-schemas>true</supports-schemas>
      <supports-procedures>false</supports-procedures>
      <always-use-prepared-statement>false</always-use-prepared-statement>
    </jdbc-type-settings>
    ```

2. Create a Kubernetes ConfigMap using the template file. Replace `<TEMPLATE-FILE-PATH>` and `<DATA-SOURCE-NAME>` with appropriate values:
    ```bash
    kubectl create configmap <DATA-SOURCE-NAME>-datasource-template --from-file=<TEMPLATE-FILE-PATH>
    ```

3. Create a new values file and deploy the Spotfire chart with the additional values for Helm. This file uses the newly created ConfigMap as a data source template to add to the Spotfire configuration, and executes the configuration script to add the data source template to the Spotfire configuration. Replace `<DATA-SOURCE-TEMPLATE-NAME>` and `<DATA-SOURCE-NAME>` with appropriate values.<br>
   For more information on configuration script execution, see the ['Configuration' section in the Readme for the `spotfire-server` Helm chart](../helm/charts/spotfire-server/README.md#configuration). For the `add-ds-template` command, refer to the [add-ds-template command-line reference](https://docs.tibco.com/pub/spotfire_server/latest/doc/html/TIB_sfire_server_tsas_admin_help/server/topics/add-ds-template.html).
    
    `ds-template-configuration.yaml`
    ```yaml
    spotfire-server:
      configJob:
        extraVolumeMounts:
          - name: ds-template-config
            mountPath: /opt/spotfire/<DATA-SOURCE-NAME>config
        extraVolumes:
          - name: ds-template-config
            configMap:
              name: <DATA-SOURCE-NAME>-datasource-template
      configuration:
        configurationScripts:
          - name: configure-<DATA-SOURCE-NAME>-ds-template
            script: |
              add-ds-template --bootstrap-config=${BOOTSTRAP_FILE} --configuration=/opt/spotfire/configuration.xml --name="<DATA-SOURCE-TEMPLATE-NAME>" --enabled=true /opt/spotfire/<DATA-SOURCE-NAME>config/<DATA-SOURCE-NAME>-ds-template.xml
    ```
    **Note:** <br>
    1. If you are deploying in an existing environment, you must also set the property `configuration.apply="always"`. For more information on this, see the ['Managing configuration on helm upgrade or installation'-section section in the Readme for the `spotfire-server` Helm chart](../helm/charts/spotfire-server/README.md#managing-configuration-on-helm-upgrade-or-installation).
        ```yaml
        spotfire-server:
          configuration:
            apply: "always"
        ```
    2. The file name `<DATA-SOURCE-NAME>-ds-template.xml` in the `add-ds-template` command must exactly match the name used during the creation of the ConfigMap.

## Installation

```bash
#Helm install spotfire server with ds-template-configuration.yaml and custom-ext-information-services-drivers.yaml

helm install my-release --namespace <Namespace> ...  -f custom-ext-information-services-drivers.yaml -f ds-template-configuration.yaml
```
For more information, see the ['Installing' section in the Readme for the `spotfire-server` Helm chart](../helm/charts/spotfire-server/README.md#installing).

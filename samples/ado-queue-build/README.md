Azure DevOps Queue a Build
==========================

Run long builds when emissions drop below a certain threshold.
--------------------------------------------------------------

This sample demonstrates how to use the Azure DevOps Queue a Build trigger with
a Logic App triggered by Azure Monitor Metrics when the CO2 emissions in the
choses region drop below a certain threshold.

 ![Azure DevOps Queue a Build Logic App](./la-co2-ado-pipeline.png)

Use Case
--------

The use case for this sample is to run long builds when the CO2 emissions in
the chosen region drop below a certain threshold. This is useful if you want to
run builds that are not time critical when the emissions are low.

The sample uses the 
[carbon-appinsights](https://github.com/cloudyspells/carbon-appinsights) project
to send CO2 emissions metrics to Azure Application Insights. The Logic App is
triggered by a metric alert on the `co2e` metric. The Logic App then checks if
the emissions are below a certain threshold and if so, it triggers a
Azure DevOps Queue a Build event to run an Azure DevOps build pipeline.

The sample uses the following Azure resources:

- Azure Monitor Metric Alert
- Azure Logic App
- Azure Logic App Connector for Azure DevOps

Prerequisites
-------------

- An Azure subscription
- An Azure DevOps organization
- A deployment of the
  [carbon-appinsights](https://github.com/cloudyspells/carbon-appinsights) project

Deployment
----------

The sample can be deployed using the Azure CLI. The following command will
deploy the sample. Set up the parameters as described in the
`main.parameters.json` as required for your github environment.

```console
az deployment sub create \
  --location westeurope \
  --template-file main.bicep \
  --parameters @main.parameters.json
```

After the deployment has completed, you need to configure the Logic App to
authenticate with Azure DevOps. To do this, open the Logic App in the Azure Portal
and click on the `Azure DevOps` connector. Then click on `Edit API connection` and
follow the instructions to authenticate with Azure DevOps.

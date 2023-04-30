targetScope = 'subscription'

@description('Lifecycle name for the environment, eg: dev, tst, acc, prd')
param environment string

@description('Project name to use in naming convention')
param projectName string

@description('Azure region / location to use')
param location string

@description('Power BI dataset username')
param pbiUsername string

@description('Power BI dataset Group ID')
param pbiGroupId string

@description('Power BI dataset ID')
param pbiDataSetId string

@description('Alert rule Scope')
param alertRuleScope string

@description('Alert rule region')
param alertRuleRegion string

@description('The low emission trigger threshold in grams per KW/h.')
param lowEmissionTriggerThreshold int = 150

var rgName = 'rg-${projectName}-${environment}'

// Create resource group
resource rg 'Microsoft.Resources/resourceGroups@2020-06-01' = {
  name: rgName
  location: location
}

// deploy the Logic App from the module
module laModule 'modules/refresh-pbi-dataset.bicep' = {
  scope: rg
  name: 'deploy-pbirefresh-la'
  params: {
    logicAppPowerBiConnectionUserName: pbiUsername
    location: location
    pbiGroupId: pbiGroupId
    pbiDataSetId: pbiDataSetId
  }
}

// deploy the alert rule from the module
module alertRuleModule 'modules/alert-rule-low-emissions.bicep' = {
  scope: rg
  name: 'deploy-lowemissions-alert'
  params: {
    location: location
    alertRuleScope: alertRuleScope
    alertRuleRegion: alertRuleRegion
    logicAppResourceId: laModule.outputs.logicAppResourceId
    logicAppName: laModule.outputs.logicAppResourceName
    actionGroupName: 'ag-${projectName}-${environment}-pbirefresh'
    lowEmissionTriggerThreshold: lowEmissionTriggerThreshold
  }
}

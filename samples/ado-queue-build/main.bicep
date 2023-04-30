targetScope = 'subscription'

@description('Lifecycle name for the environment, eg: dev, tst, acc, prd')
param environment string

@description('Project name to use in naming convention')
param projectName string

@description('Azure region / location to use')
param location string

@description('Azure devops build definition ID')
param adoBuildDefId string

@description('Azure devops project name')
param adoProject string

@description('Azure devops organization')
param adoOrganization string

@description('Azure devops project source branch')
param adoSourceBranch string

@description('Alert rule Scope')
param alertRuleScope string

@description('Alert rule region')
param alertRuleRegion string

@description('The low emission trigger threshold in grams per KW/h.')
param lowEmissionTriggerThreshold int

var rgName = 'rg-${projectName}-${environment}-adoqueue'

// Create resource group
resource rg 'Microsoft.Resources/resourceGroups@2020-06-01' = {
  name: rgName
  location: location
}

// deploy the Logic App from the module
module laModule 'modules/ado-queue-build.bicep' = {
  scope: rg
  name: 'deploy-ado-queue-la'
  params: {
    location: location
    adoBuildDefId: adoBuildDefId
    adoOrganization: adoOrganization
    adoProject: adoProject
    adoSourceBranch: adoSourceBranch
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
    actionGroupName: 'ag-${projectName}-${environment}-ado-queue'
    lowEmissionTriggerThreshold: lowEmissionTriggerThreshold
  }
}

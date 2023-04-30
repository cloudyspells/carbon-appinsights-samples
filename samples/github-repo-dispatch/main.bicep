targetScope = 'subscription'

@description('Lifecycle name for the environment, eg: dev, tst, acc, prd')
param environment string

@description('Project name to use in naming convention')
param projectName string

@description('Azure region / location to use')
param location string

@description('GitHub organization name')
param gitHubOrgName string

@description('GitHub repository name')
param gitHubRepoName string

@description('GitHub user name')
param gitHubUserName string

@description('Alert rule Scope')
param alertRuleScope string

@description('Alert rule region')
param alertRuleRegion string

@description('The low emission trigger threshold in grams per KW/h.')
param lowEmissionTriggerThreshold int

var rgName = 'rg-${projectName}-${environment}-ghdispatch'

// Create resource group
resource rg 'Microsoft.Resources/resourceGroups@2020-06-01' = {
  name: rgName
  location: location
}

// deploy the Logic App from the module
module laModule 'modules/github-repo-dispatch.bicep' = {
  scope: rg
  name: 'deploy-pbirefresh-la'
  params: {
    location: location
    gitHubOrgName: gitHubOrgName
    gitHubRepoName: gitHubRepoName
    gitHubUserName: gitHubUserName
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
    actionGroupName: 'ag-${projectName}-${environment}-ghdispatch'
    lowEmissionTriggerThreshold: lowEmissionTriggerThreshold
  }
}

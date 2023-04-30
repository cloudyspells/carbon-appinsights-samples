targetScope = 'resourceGroup'

@description('The name of the alert rule.')
param alertRuleName string = 'Regional emissions below low emission threshold'

@description('The low emission trigger threshold in grams per KW/h.')
param lowEmissionTriggerThreshold int = 150

@description('The name for the action group.')
param actionGroupName string = 'lowco2-ado-queue'

@description('Action group Logic App')
param logicAppName string = 'la-lowco2-ado-queue'

@description('Action group Logic App resource ID')
param logicAppResourceId string

@description('Alert rule Scope')
param alertRuleScope string

@description('Alert rule region')
param alertRuleRegion string

@description('Azure region / location')
param location string = 'westeurope'

// Azure Monitor alert rule
resource alertRule 'Microsoft.Insights/metricAlerts@2018-03-01' = {
  name: alertRuleName
  location: location
  properties: {
    description: 'Alert rule for low CO2 emissions in the ${alertRuleRegion} region.'
    severity: 3
    scopes: [
      alertRuleScope
    ]
    enabled: true
    evaluationFrequency: 'PT15M'
    windowSize: 'PT30M'
    criteria: {
      allOf: [
        {
          name: 'Metric1'
          metricName: '${alertRuleRegion}CarbonIntensity'
          metricNamespace: 'Azure.ApplicationInsights'
          operator: 'LessThan'
          threshold: lowEmissionTriggerThreshold
          timeAggregation: 'Maximum'
          criterionType: 'StaticThresholdCriterion'
        }
      ]
      'odata.type': 'Microsoft.Azure.Monitor.SingleResourceMultipleMetricCriteria'
    }
    autoMitigate: true
    targetResourceRegion: location
    targetResourceType: 'Microsoft.Insights/components'
    actions: [
      {
        actionGroupId: actionGroup.id
      }
    ]
  }
}

// Action group
resource actionGroup 'Microsoft.Insights/actionGroups@2023-01-01' = {
  name: actionGroupName
  location: 'global'
  properties: {
    groupShortName: 'lowco2-ag'
    enabled: true
    logicAppReceivers: [
      {
        name: logicAppName
        resourceId: logicAppResourceId
        callbackUrl: listCallbackURL('${logicAppResourceId}/triggers/manual', '2019-05-01').value
        useCommonAlertSchema: true
      }
    ]
  }
}

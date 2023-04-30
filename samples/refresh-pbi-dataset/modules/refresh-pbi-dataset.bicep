targetScope = 'resourceGroup'

@description('Name for the logic app')
param logicAppName string = 'la-lowco2-refresh-pbi'

@description('Name for the logic app power bi connection')
param logicAppPowerBiConnectionName string = 'powerbi'

@description('User name for the logic app power bi connection')
param logicAppPowerBiConnectionUserName string

@description('Azure region / location for the deployment')
param location string = resourceGroup().location

@description('Power BI Group ID holding the dataset')
param pbiGroupId string = '051b7b6f-d14a-4be3-bd6b-00a80db69d49'

@description('Power BI Dataset ID')
param pbiDataSetId string = 'e95ef83d-e95d-40c7-b899-5edffae3ee66'

resource pbiConnection 'Microsoft.Web/connections@2016-06-01' = {
  name: logicAppPowerBiConnectionName
  location: location
  properties: {
    api: {
      name: 'powerbi'
      displayName: 'Power BI'
      description: 'Power BI is a suite of business analytics tools to analyze data and share insights. Connect to get easy access to the data in your Power BI dashboards, reports and datasets.'
      iconUri: 'https://connectoricons-prod.azureedge.net/releases/v1.0.1596/1.0.1596.2995/powerbi/icon.png'
      id: 'subscriptions/${subscription().subscriptionId}/providers/Microsoft.Web/locations/${location}/managedApis/powerbi'
      type: 'Microsoft.Web/locations/managedApis'
      brandColor: '#F2C811'
    }
    displayName: logicAppPowerBiConnectionUserName
    customParameterValues: {}
    nonSecretParameterValues: {}
    parameterValues: {}
    testLinks: [
      {
        requestUri: '${environment().resourceManager}subscriptions/${subscription().subscriptionId}/resourceGroups/${resourceGroup().name}/providers/Microsoft.Web/connections/${logicAppPowerBiConnectionName}/extensions/proxy/metadata/v201606/alerts?api-version=2016-06-01'
        method: 'get'
      }
    ]
  }
}

resource logicAppResource 'Microsoft.Logic/workflows@2019-05-01' = {
  name: logicAppName
  location: location
  properties: {
    state: 'Enabled'
    definition: {
      '$schema': 'https://schema.management.azure.com/providers/Microsoft.Logic/schemas/2016-06-01/workflowdefinition.json#'
      contentVersion: '1.0.0.0'
      parameters: {
        '$connections': {
          defaultValue: {}
          type: 'Object'
        }
      }
      triggers: {
        manual: {
          type: 'Request'
          kind: 'Http'
          inputs: {
            schema: {
              properties: {
                data: {
                  properties: {
                    context: {
                      properties: {
                        condition: {
                          properties: {
                            allOf: {
                              items: {
                                properties: {
                                  dimensions: {
                                    items: {
                                      properties: {
                                        name: {
                                          type: 'string'
                                        }
                                        value: {
                                          type: 'string'
                                        }
                                      }
                                      required: [
                                        'name'
                                        'value'
                                      ]
                                      type: 'object'
                                    }
                                    type: 'array'
                                  }
                                  metricName: {
                                    type: 'string'
                                  }
                                  metricValue: {
                                    type: 'integer'
                                  }
                                  operator: {
                                    type: 'string'
                                  }
                                  threshold: {
                                    type: 'string'
                                  }
                                  timeAggregation: {
                                    type: 'string'
                                  }
                                }
                                required: [
                                  'metricName'
                                  'dimensions'
                                  'operator'
                                  'threshold'
                                  'timeAggregation'
                                  'metricValue'
                                ]
                                type: 'object'
                              }
                              type: 'array'
                            }
                            windowSize: {
                              type: 'string'
                            }
                          }
                          type: 'object'
                        }
                        conditionType: {
                          type: 'string'
                        }
                        description: {
                          type: 'string'
                        }
                        id: {
                          type: 'string'
                        }
                        name: {
                          type: 'string'
                        }
                        portalLink: {
                          type: 'string'
                        }
                        resourceGroupName: {
                          type: 'string'
                        }
                        resourceId: {
                          type: 'string'
                        }
                        resourceName: {
                          type: 'string'
                        }
                        resourceType: {
                          type: 'string'
                        }
                        subscriptionId: {
                          type: 'string'
                        }
                        timestamp: {
                          type: 'string'
                        }
                      }
                      type: 'object'
                    }
                    properties: {
                      properties: {}
                      type: 'object'
                    }
                    status: {
                      type: 'string'
                    }
                    version: {
                      type: 'string'
                    }
                  }
                  type: 'object'
                }
                schemaId: {
                  type: 'string'
                }
              }
              type: 'object'
            }
          }
        }
      }
      actions: {
        Refresh_a_dataset: {
          runAfter: {}
          type: 'ApiConnection'
          inputs: {
            host: {
              connection: {
                name: '@parameters(\'$connections\')[\'powerbi\'][\'connectionId\']'
              }
            }
            method: 'post'
            path: '/v1.0/myorg/groups/@{encodeURIComponent(\'${pbiGroupId}\')}/datasets/@{encodeURIComponent(\'${pbiDataSetId}\')}/refreshes'
            queries: {
              pbi_source: 'powerAutomate'
            }
          }
        }
      }
      outputs: {}
    }
    parameters: {
      '$connections': {
        value: {
          powerbi: {
            connectionId: pbiConnection.id
            connectionName: 'powerbi'
            id: '/subscriptions/${subscription().subscriptionId}/providers/Microsoft.Web/locations/westeurope/managedApis/powerbi'
          }
        }
      }
    }
  }
}

output logicAppResourceId string = logicAppResource.id
output logicAppResourceName string = logicAppResource.name

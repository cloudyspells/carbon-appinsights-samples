@description('Azure region / location')
param location string = 'westeurope'

@description('Azure logic app name')
param logicAppName string = 'la-co2-ado-pipeline'

@description('Azure devops build definition ID')
param adoBuildDefId string = '1'

@description('Azure devops project name')
param adoProject string = 'bicep-artifacts'

@description('Azure devops organization')
param adoOrganization string = 'cloudyspells'

@description('Azure devops project source branch')
param adoSourceBranch string = 'master'

@description('API Connection Name')
param connections_visualstudioteamservices_name string = 'visualstudioteamservices'

resource adoConnectionResource 'Microsoft.Web/connections@2016-06-01' = {
  name: connections_visualstudioteamservices_name
  location: location
  properties: {
    displayName: 'roderick@cloudyspells.onmicrosoft.com'
    statuses: [
      {
        status: 'Connected'
      }
    ]
    customParameterValues: {}
    nonSecretParameterValues: {}
    createdTime: '2023-04-30T20:08:22.2591098Z'
    changedTime: '2023-04-30T20:08:32.8461118Z'
    api: {
      name: connections_visualstudioteamservices_name
      displayName: 'Azure DevOps'
      description: 'Azure DevOps provides services for teams to share code, track work, and ship software - for any language, all in a single package. It\'s the perfect complement to your IDE.'
      iconUri: 'https://connectoricons-prod.azureedge.net/releases/v1.0.1626/1.0.1626.3238/vsts/icon.png'
      brandColor: '#0078d7'
      id: '/subscriptions/${subscription().subscriptionId}/providers/Microsoft.Web/locations/westeurope/managedApis/${connections_visualstudioteamservices_name}'
      type: 'Microsoft.Web/locations/managedApis'
    }
    testLinks: [
      {
        requestUri: 'https://${environment().resourceManager}/subscriptions/${subscription().subscriptionId}/resourceGroups/${resourceGroup().name}/providers/Microsoft.Web/connections/${connections_visualstudioteamservices_name}/extensions/proxy/_apis/Accounts?api-version=2016-06-01'
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
        Queue_a_new_build: {
          runAfter: {}
          type: 'ApiConnection'
          inputs: {
            body: {
              sourceBranch: adoSourceBranch
            }
            host: {
              connection: {
                name: '@parameters(\'$connections\')[\'visualstudioteamservices\'][\'connectionId\']'
              }
            }
            method: 'post'
            path: '/@{encodeURIComponent(\'${adoProject}\')}/_apis/build/builds'
            queries: {
              account: adoOrganization
              buildDefId: adoBuildDefId
            }
          }
        }
      }
      outputs: {}
    }
    parameters: {
      '$connections': {
        value: {
          visualstudioteamservices: {
            connectionId: adoConnectionResource.id
            connectionName: 'visualstudioteamservices'
            id: '/subscriptions/${subscription().subscriptionId}/providers/Microsoft.Web/locations/westeurope/managedApis/visualstudioteamservices'
          }
        }
      }
    }
  }
}

output logicAppResourceId string = logicAppResource.id
output logicAppResourceName string = logicAppResource.name


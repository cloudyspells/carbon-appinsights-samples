targetScope = 'resourceGroup'

@description('GitHub connection name')
param connections_github_name string = 'github'
@description('GitHub organization name')
param gitHubOrgName string = 'cloudyspells'
@description('GitHub repository name')
param gitHubRepoName string = 'carbon-appinsights-samples'
@description('GitHub user name')
param gitHubUserName string = 'webtonize'
@description('Logic App name')
param logicAppName string = 'la-test-co2-samples2'
@description('Azure region / location')
param location string = 'westeurope'

resource gitHubConnection 'Microsoft.Web/connections@2016-06-01' = {
  name: connections_github_name
  location: location
  properties: {
    displayName: gitHubUserName
    customParameterValues: {}
    nonSecretParameterValues: {}
    api: {
      name: connections_github_name
      displayName: 'GitHub'
      description: 'GitHub is a web-based Git repository hosting service. It offers all of the distributed revision control and source code management (SCM) functionality of Git as well as adding its own features.'
      iconUri: 'https://connectoricons-prod.azureedge.net/releases/v1.0.1549/1.0.1549.2680/${connections_github_name}/icon.png'
      brandColor: '#4078c0'
      id: '/subscriptions/${subscription().subscriptionId}/providers/Microsoft.Web/locations/westeurope/managedApis/${connections_github_name}'
      type: 'Microsoft.Web/locations/managedApis'
    }
    testLinks: []
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
        Create_a_repository_dispatch_event: {
          runAfter: {}
          type: 'ApiConnection'
          inputs: {
            body: {
              event_type: 'logic_app_demo'
            }
            headers: {
              Accept: 'application/vnd.github.v3+json'
            }
            host: {
              connection: {
                name: '@parameters(\'$connections\')[\'github\'][\'connectionId\']'
              }
            }
            method: 'post'
            path: '/repos/@{encodeURIComponent(\'${gitHubOrgName}\')}/@{encodeURIComponent(\'${gitHubRepoName}\')}/dispatches'
          }
        }
      }
      outputs: {}
    }
    parameters: {
      '$connections': {
        value: {
          github: {
            connectionId: gitHubConnection.id
            connectionName: 'github'
            id: '/subscriptions/${subscription().subscriptionId}/providers/Microsoft.Web/locations/westeurope/managedApis/github'
          }
        }
      }
    }
  }
}

output logicAppResourceId string = logicAppResource.id
output logicAppResourceName string = logicAppResource.name

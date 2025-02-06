@allowed(['test', 'prod'])
param environmentName string
param location string

param metricsPublisherPrincipalId string

// resource logAnalysiticsWorkspace 'Microsoft.OperationalInsights/workspaces@2023-09-01' = {
//   location: resourceGroup().location
//   name: 'fakeCompanyLogAnalytics'
// }

resource logAnalysiticsWorkspace 'Microsoft.OperationalInsights/workspaces@2023-09-01' existing = {
  scope: resourceGroup()
  name: 'fakeCompanyLogAnalytics'
}

resource applicationInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: 'fakeCompanyPortal-${environmentName}'
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
    WorkspaceResourceId: logAnalysiticsWorkspace.id
  }
}

var metricsPublisherWellKnownId = '3913510d-42f4-4e42-8a64-420c390055eb'

resource metricsPublisherRoleDefinition 'Microsoft.Authorization/roleDefinitions@2022-05-01-preview' existing = {
  name: metricsPublisherWellKnownId
}

resource monitoringMetricsPublisherRoleAssignment 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid(applicationInsights.name, metricsPublisherPrincipalId, metricsPublisherRoleDefinition.id)
  scope: applicationInsights
  properties: {
    principalId: metricsPublisherPrincipalId
    roleDefinitionId: metricsPublisherRoleDefinition.id
  }
}

var metricDetails = [
  {
    metricName: 'Failed requests'
    metricIdentifier: 'requests/failed'
  }
  {
    metricName: 'Failed dependencies'
    metricIdentifier: 'dependencies/failed'
  }
]

resource failuresAlert 'Microsoft.Insights/metricAlerts@2018-03-01' = [for metricDetail in metricDetails: if (environmentName == 'prod') {
  name: 'Rule for ${metricDetail.metricName}'
  location: 'global'
  properties: {
    severity: 3
    enabled: true
    evaluationFrequency: 'PT5M'
    windowSize: 'PT5M'
    scopes: [
      applicationInsights.id
    ]
    criteria: {
      'odata.type': 'Microsoft.Azure.Monitor.SingleResourceMultipleMetricCriteria'
      allOf: [
        {
          threshold: 1
          name: metricDetail.metricName
          metricNamespace: 'microsoft.insights/components'
          metricName: metricDetail.metricIdentifier
          operator: 'GreaterThan'
          timeAggregation: 'Count'
          criterionType: 'StaticThresholdCriterion'
        }
      ]
    }
  }
}]

@allowed(['test', 'prod'])
param environmentName string
param location string

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

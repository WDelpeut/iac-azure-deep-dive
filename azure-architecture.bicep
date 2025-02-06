type websiteConfigurationSettingsType = {
  awesomeFeatureEnabled: bool
  @description('Please make sue you do not increase the count too much!')
  @minValue(1)
  @maxValue(5)
  awesomeFeatureCount: int

  @minLength(5)
  @maxLength(25)
  awesomeFeatureDisplayName: string
}

@allowed(['test', 'prod'])
param environmentName string

param websiteConfigurationSettings websiteConfigurationSettingsType

param location string = resourceGroup().location

var serverFarmSkuName = environmentName == 'prod' ? 'P2V3' : 'B1'

resource serverFarm 'Microsoft.Web/serverfarms@2024-04-01' = {
  name: 'fakeCompanyPortal-${environmentName}'
  location: location
  sku: {
    name: serverFarmSkuName
  }
}

resource website 'Microsoft.Web/sites@2024-04-01' = {
  name: 'fakeCompanyPortal-wes-${environmentName}'
  location: location
  properties: {
    serverFarmId: serverFarm.id
  }
}

var featureCountIsEven = websiteConfigurationSettings.awesomeFeatureCount % 2 == 0
var calculatedAwesomeFeatureEnabled = websiteConfigurationSettings.awesomeFeatureEnabled && featureCountIsEven

resource websiteSettings 'Microsoft.Web/sites/config@2024-04-01' = {
  parent: website
  name: 'appsettings'
  properties: {
    enableAwesomeFeature: string(calculatedAwesomeFeatureEnabled)
    awesomeFeatureCount: string(websiteConfigurationSettings.awesomeFeatureCount)
    awesomeFeatureDisplayName: websiteConfigurationSettings.awesomeFeatureDisplayName
  }
}

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

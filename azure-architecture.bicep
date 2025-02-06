@allowed(['test', 'prod'])
param environmentName string
param location string = resourceGroup().location

import { websiteConfigurationSettingsType } from './modules/appService.bicep'
param websiteConfigurationSettings websiteConfigurationSettingsType

module appServiceModule 'modules/appService.bicep' = {
  name: 'appServiceDeployment'
  params: {
    environmentName: environmentName
    location: location
    websiteConfigurationSettings: websiteConfigurationSettings
  }
}

module applicationInsightsModule 'modules/applicationInisghts.bicep' = {
  name: 'applicationInsightsDeployment'
  params: {
    environmentName: environmentName
    location: location
    metricsPublisherPrincipalId: appServiceModule.outputs.websiteManagedIdentityPrincipalId
  }
}

module sqlDatabaseModule 'modules/sqlDatabase.bicep' = {
  name: 'sqlDatabaseDeployment'
  params: {
    environmentName: environmentName
    location: location
    administratorManagedIdentityName: appServiceModule.outputs.websiteManagedIdentityName
    administratorManagedIdentityClientId: appServiceModule.outputs.websiteManagedIdentityClientId
  }
}

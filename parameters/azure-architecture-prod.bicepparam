using 'azure-architecture.bicep'

param environmentName =  'prod'

param websiteConfigurationSettings = {
  awesomeFeatureCount: 3
  awesomeFeatureDisplayName: 'EverythingPurpleFeature'
  awesomeFeatureEnabled: true
}

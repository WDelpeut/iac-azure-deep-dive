using '../azure-architecture.bicep'

param environmentName =  'test'

param websiteConfigurationSettings = {
  awesomeFeatureCount: 2
  awesomeFeatureDisplayName: 'EverythingPurpleFeature'
  awesomeFeatureEnabled: true
}

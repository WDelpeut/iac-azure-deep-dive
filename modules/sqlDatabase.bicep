@allowed(['test', 'prod'])
param environmentName string
param location string

param administratorManagedIdentityName string
param administratorManagedIdentityClientId string

resource sqlServer 'Microsoft.Sql/servers@2024-05-01-preview' = {
  name: 'fakeCompanySqlServer-wes-${environmentName}'
  location: location
  properties: {
    administrators: {
      administratorType: 'ActiveDirectory'
      azureADOnlyAuthentication: true
      login: administratorManagedIdentityName
      sid: administratorManagedIdentityClientId
      tenantId: subscription().tenantId
    }
  }

  resource sqlDatabase 'databases' = {
    name: 'fakeCompanyDatabase-${environmentName}'
    location: location
    sku: {
      name: 'Basic'
    }
  }
}

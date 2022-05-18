param region string

resource logs 'Microsoft.OperationalInsights/workspaces@2021-12-01-preview' = {
  name: 'logs'
  location: region
  properties: {
    sku: {
      name: 'PerGB2018'
    }
  }
}

output id string = logs.id

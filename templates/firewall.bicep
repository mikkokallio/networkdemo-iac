param region string
param subnetId string

resource pipfw 'Microsoft.Network/publicIpAddresses@2020-08-01' = {
  name: 'pip-firewall'
  location: region
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}

resource azureFirewallName_resource 'Microsoft.Network/azureFirewalls@2020-05-01' = {
  name: 'azfw-hub'
  location: region
  tags: {}
  zones: []
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig-fw'
        properties: {
          subnet: {
            id: subnetId
          }
          publicIPAddress: {
            id: pipfw.id
          }
        }
      }
    ]
    sku: {
      tier: 'Standard'
    }
  }
}

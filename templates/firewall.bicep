param region string
param hub string

resource pip 'Microsoft.Network/publicIpAddresses@2020-08-01' = {
  name: 'pip-firewall'
  location: region
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}

resource firewall 'Microsoft.Network/azureFirewalls@2020-05-01' = {
  name: 'firewall-hub'
  location: region
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig'
        properties: {
          subnet: {
            id: '${hub}/subnets/AzureFirewallSubnet'
          }
          publicIPAddress: {
            id: pip.id
          }
        }
      }
    ]
    sku: {
      tier: 'Standard'
    }
  }
}

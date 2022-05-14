param region string

resource hub 'Microsoft.Network/virtualNetworks@2019-11-01' = {
  name: 'vnet-hub'
  location: region
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/23'
      ]
    }
    subnets: [
      {
        name: 'GatewaySubnet'
        properties: {
          addressPrefix: '10.0.0.0/26'
        }
      }
      {
        name: 'AzureBastionSubnet'
        properties: {
          addressPrefix: '10.0.0.64/26'
        }
      }
    ]
  }
}

resource fwsubnet 'Microsoft.Network/virtualNetworks/subnets@2021-05-01' = {
  parent: hub
  name: 'AzureFirewallSubnet'
  properties: {
    addressPrefix: '10.0.0.128/26'
    privateEndpointNetworkPolicies: 'Enabled'
    privateLinkServiceNetworkPolicies: 'Enabled'
  }
}

output fwSubnetId string = fwsubnet.id
output vnetId string = hub.id
output vnetName string = hub.name
//output bastionSubnetId string = bastionsubnet.id
output bastionSubnetName string = '${hub.name}/subnets/AzureBastionSubnet'
//output subi object = hub.subnets.

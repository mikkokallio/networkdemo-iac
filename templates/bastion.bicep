param region string
param hub string

resource pip 'Microsoft.Network/publicIPAddresses@2020-08-01' = {
  name: 'pip-bastion'
  location: region
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}

resource bastion 'Microsoft.Network/bastionHosts@2021-08-01' = {
  name: 'bastion-hub'
  location: region
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig'
        properties: {
          subnet: {
            id: '${hub}/subnets/AzureBastionSubnet'
          }
          publicIPAddress: {
            id: pip.id
          }
        }
      }
    ]
  }
}

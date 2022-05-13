@minLength(3)
@maxLength(24)
@description('Provide a name to use as a suffix in the resources.')
param projectName string

@minLength(3)
@maxLength(24)
@description('Provide an Azure region for deploying the resources.')
param region string




resource hub 'Microsoft.Network/virtualNetworks@2019-11-01' = {
  name: 'vnet-hub'
  location: region
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/22'
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
        name: 'BastionSubnet'
        properties: {
          addressPrefix: '10.0.0.64/26'
        }
      }
      {
        name: 'AzureFirewallSubnet'
        properties: {
          addressPrefix: '10.0.0.128/26'
        }
      }
    ]
  }
}

resource spoke01 'Microsoft.Network/virtualNetworks@2019-11-01' = {
  name: 'vnet-spoke01'
  location: region
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.2.0/24'
      ]
    }
    subnets: [
      {
        name: 'Subnet-1'
        properties: {
          addressPrefix: '10.0.2.0/25'
        }
      }
      {
        name: 'Subnet-2'
        properties: {
          addressPrefix: '10.0.2.128/25'
        }
      }
    ]
  }
}

resource spoke02 'Microsoft.Network/virtualNetworks@2019-11-01' = {
  name: 'vnet-spoke02'
  location: region
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.3.0/24'
      ]
    }
    subnets: [
      {
        name: 'Subnet-1'
        properties: {
          addressPrefix: '10.0.3.0/25'
        }
      }
      {
        name: 'Subnet-2'
        properties: {
          addressPrefix: '10.0.3.128/25'
        }
      }
    ]
  }
}

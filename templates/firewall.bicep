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
    networkRuleCollections: [
      {
        name: 'rules'
        properties: {
          priority: 2000
          action: {
            type: 'Allow'
          }
          rules: [
            {
              name: 'all'
              protocols: [
                'TCP'
              ]
              sourceAddresses: [
                '10.0.0.0/16'
              ]
              destinationAddresses: [
                '10.0.0.0/16'
              ]
              destinationPorts: [
                '22'
              ]
            }
            {
              name: 'allow_ping'
              protocols: [
                'ICMP'
              ]
              sourceAddresses: [
                '10.0.0.0/16'
              ]
              destinationAddresses: [
                '10.0.0.0/16'
              ]
              destinationPorts: [
                '*'
              ]
            }
          ]
        }
      }
    ]
  }
}

output ip string = pip.properties.ipAddress

param location string
param resourceGroup string
param azureFirewallName string
param azureFirewallTier string
param vnetName string
param vnetAddressSpace string
param subnetAddressSpace string
param zones array
param subnetId string
param managementSubnetId string
param publicIpAddressName string
param publicIpZones array

var networkApiVersion = '?api-version=2019-09-01'

resource publicIpAddressName_resource 'Microsoft.Network/publicIpAddresses@2020-08-01' = {
  name: publicIpAddressName
  location: location
  tags: {}
  sku: {
    name: 'Standard'
  }
  zones: publicIpZones
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}

resource azureFirewallName_resource 'Microsoft.Network/azureFirewalls@2020-05-01' = {
  name: azureFirewallName
  location: location
  tags: {}
  zones: zones
  properties: {
    ipConfigurations: [
      {
        name: publicIpAddressName
        properties: {
          subnet: {
            id: subnetId
          }
          publicIPAddress: {
            id: resourceId(resourceGroup, 'Microsoft.Network/publicIPAddresses', publicIpAddressName)
          }
        }
      }
    ]
    sku: {
      tier: azureFirewallTier
    }
  }
  dependsOn: [
    resourceId(resourceGroup, 'Microsoft.Network/publicIpAddresses', publicIpAddressName)
  ]
}
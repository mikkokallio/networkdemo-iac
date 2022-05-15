param name string
param vnetId string
param vnetName string

resource dnszone 'Microsoft.Network/privateDnsZones@2018-09-01' existing = {
  name: name
}

resource dnslink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  name: 'dnslink-${vnetName}'
  location: 'global'
  parent: dnszone
  properties: {
    registrationEnabled: true
    virtualNetwork: {
      id: vnetId
    }
  }
}

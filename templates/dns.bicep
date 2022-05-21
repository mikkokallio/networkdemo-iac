param hubId string
param spokeIds array
param dnsZone string

@description('Deploy a private DNS zone to resolve e.g. VM names.')
resource dnszone 'Microsoft.Network/privateDnsZones@2018-09-01' = {
  name: dnsZone
  location: 'global'
}

resource dnslink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = [for i in range(0, length(spokeIds)): {
  name: 'dnslink-${i + 1}'
  location: 'global'
  parent: dnszone
  properties: {
    registrationEnabled: true
    virtualNetwork: {
      id: spokeIds[i]
    }
  }
}]

resource hubdnslink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  name: 'dnslink-hub'
  location: 'global'
  parent: dnszone
  properties: {
    registrationEnabled: true
    virtualNetwork: {
      id: hubId
    }
  }
}

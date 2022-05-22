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

resource dnslink_hub 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
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

resource dnszone_blob 'Microsoft.Network/privateDnsZones@2018-09-01' = {
  name: 'privatelink.blob.core.windows.net'
  location: 'global'
}

resource dnszone_vault 'Microsoft.Network/privateDnsZones@2018-09-01' = {
  name: 'privatelink.vaultcore.azure.net'
  location: 'global'
}

resource dnslink_vault 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = [for i in range(0, length(spokeIds)): {
  name: 'dnslink-vault-${i}'
  parent: dnszone_vault
  location: 'global'
  properties: {
    virtualNetwork: {
      id: spokeIds[i]
    }
    registrationEnabled: false
  }
}]

resource dnslink_vault_hub 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  name: 'dnslink-vault-hub'
  location: 'global'
  parent: dnszone_vault
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: hubId
    }
  }
}

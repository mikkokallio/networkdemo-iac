param spokeNumber string
param ipSpace string
param region string
param hubName string
param routetableId string

resource spoke 'Microsoft.Network/virtualNetworks@2019-11-01' = {
  name: 'vnet-spoke-${spokeNumber}'
  location: region
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.${ipSpace}.0/24'
      ]
    }
    subnets: [
      {
        name: 'subnet-web'
        properties: {
          addressPrefix: '10.0.${ipSpace}.0/25'
          routeTable: {
            id: routetableId
          }
        }
      }
      {
        name: 'subnet-app'
        properties: {
          addressPrefix: '10.0.${ipSpace}.128/25'
        }
      }
    ]
  }
}

resource hub 'Microsoft.Network/virtualNetworks@2019-11-01' existing = {
  name: hubName
}

resource linkToSpoke 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2021-08-01' = {
  parent: hub
  name: 'link-hub-spoke-${spokeNumber}'
  properties: {
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
    allowGatewayTransit: false
    useRemoteGateways: false
    remoteVirtualNetwork: {
      id: spoke.id
    }
  }
}

resource linkFromSpoke 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2021-08-01' = {
  parent: spoke
  name: 'link-spoke-hub-${spokeNumber}'
  properties: {
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
    allowGatewayTransit: false
    useRemoteGateways: false
    remoteVirtualNetwork: {
      id: hub.id
    }
  }
}

output id string = spoke.id

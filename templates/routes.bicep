param region string
//param ip string

resource routetable 'Microsoft.Network/routeTables@2020-11-01' = {
  name: 'hub-spoke-routes'
  location: region
  properties: {
    disableBgpRoutePropagation: false
    routes: [
      {
        name: 'spoke-transit'
        properties: {
          addressPrefix: '10.0.0.0/16'
          nextHopType: 'VirtualAppliance'
          nextHopIpAddress: '10.0.0.132' // This is unreliable, could change?
          hasBgpOverride: false
        }
      }
    ]
  }
}

output id string = routetable.id

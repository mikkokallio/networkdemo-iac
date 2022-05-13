param name string
param ipSpace string
param region string

resource spoke 'Microsoft.Network/virtualNetworks@2019-11-01' = {
  name: name
  location: region
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.${ipSpace}.0/24'
      ]
    }
    subnets: [
      {
        name: 'subnet-01'
        properties: {
          addressPrefix: '10.0.${ipSpace}.0/25'
        }
      }
      {
        name: 'subnet-02'
        properties: {
          addressPrefix: '10.0.${ipSpace}.128/25'
        }
      }
    ]
  }
}

output id string = spoke.id

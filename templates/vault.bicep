param region string
//param hub string

resource keyvault 'Microsoft.KeyVault/vaults@2021-10-01' = {
  name: 'keyvault-networkdemo3'
  location: region
  properties: {
    enabledForDeployment: true
    enabledForTemplateDeployment: false
    enabledForDiskEncryption: false
    enableRbacAuthorization: true
    tenantId: tenant().tenantId
    sku: {
      name: 'standard'
      family: 'A'
    }
    publicNetworkAccess: 'Enabled'
    enableSoftDelete: true
    softDeleteRetentionInDays: 90
    networkAcls: {
      defaultAction: 'Deny'
      bypass: 'AzureServices'
    }
  }
}

/*resource symbolicname 'Microsoft.Compute/sshPublicKeys@2021-11-01' = {
  name: 'string'
  location: region
  tags: {
    tagName1: 'tagValue1'
    tagName2: 'tagValue2'
  }
  properties: {
    publicKey: 'string'
  }
}*/

resource secret 'Microsoft.KeyVault/vaults/secrets@2019-09-01' = {
  name: 'sshkey'
  parent: keyvault
  properties: {
    value: 'test' //keys.privateKey
  }
}

/*resource endpoint 'Microsoft.Network/privateEndpoints@2021-03-01' = {
  location: region
  name: 'endpoint-keyvault'
  properties: {
    subnet: {
      id: '${hub}/subnets/ManagementSubnet'
    }
    privateLinkServiceConnections: [
      {
        name: 'endpoint-keyvault'
        properties: {
          privateLinkServiceId: keyvault.id
          groupIds: [
            'vault'
          ]
        }
      }
    ]
  }
}*/

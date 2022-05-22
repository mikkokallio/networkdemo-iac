param region string

resource keyvault 'Microsoft.KeyVault/vaults@2021-10-01' = {
  name: 'keyvault-networkdemo2'
  location: region
  properties: {
    enabledForDeployment: true
    enabledForTemplateDeployment: false
    enabledForDiskEncryption: false
    enableRbacAuthorization: true
    //accessPolicies: accessPolicies
    tenantId: tenant().tenantId
    sku: {
      name: 'standard'
      family: 'A'
    }
    publicNetworkAccess: 'Disabled'
    enableSoftDelete: true
    softDeleteRetentionInDays: 90
    networkAcls: {
      defaultAction: 'Deny'
      bypass: 'AzureServices'
    }
  }
}

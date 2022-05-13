@minLength(3)
@maxLength(24)
@description('Provide an Azure region for deploying the resources.')
param region string

param adminUsername string

@secure()
param adminPassword string // TODO: Replace with SSH setup

resource hub 'Microsoft.Network/virtualNetworks@2019-11-01' = {
  name: 'vnet-hub'
  location: region
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/22'
      ]
    }
    subnets: [
      {
        name: 'GatewaySubnet'
        properties: {
          addressPrefix: '10.0.0.0/26'
        }
      }
      {
        name: 'BastionSubnet'
        properties: {
          addressPrefix: '10.0.0.64/26'
        }
      }
    ]
  }
}

resource fwsubnet 'Microsoft.Network/virtualNetworks/subnets@2021-05-01' = {
  parent: hub
  name: 'AzureFirewallSubnet'
  properties: {
    addressPrefix: '10.0.0.128/26'
    privateEndpointNetworkPolicies: 'Enabled'
    privateLinkServiceNetworkPolicies: 'Enabled'
  }
}

resource spoke01 'Microsoft.Network/virtualNetworks@2019-11-01' = {
  name: 'vnet-spoke01'
  location: region
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.2.0/24'
      ]
    }
    subnets: [
      {
        name: 'Subnet-1'
        properties: {
          addressPrefix: '10.0.2.0/25'
        }
      }
      {
        name: 'Subnet-2'
        properties: {
          addressPrefix: '10.0.2.128/25'
        }
      }
    ]
  }
}

resource spoke02 'Microsoft.Network/virtualNetworks@2019-11-01' = {
  name: 'vnet-spoke02'
  location: region
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.3.0/24'
      ]
    }
    subnets: [
      {
        name: 'Subnet-1'
        properties: {
          addressPrefix: '10.0.3.0/25'
        }
      }
      {
        name: 'Subnet-2'
        properties: {
          addressPrefix: '10.0.3.128/25'
        }
      }
    ]
  }
}

resource pipfw 'Microsoft.Network/publicIpAddresses@2020-08-01' = {
  name: 'pip-firewall'
  location: region
  tags: {}
  sku: {
    name: 'Standard'
  }
  zones: []
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}

resource azureFirewallName_resource 'Microsoft.Network/azureFirewalls@2020-05-01' = {
  name: 'azfw-hub'
  location: region
  tags: {}
  zones: []
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig-fw'
        properties: {
          subnet: {
            id: fwsubnet.id
          }
          publicIPAddress: {
            id: pipfw.id
          }
        }
      }
    ]
    sku: {
      tier: 'Standard'
    }
  }
}

var subnetRef = '${spoke01.id}/subnets/Subnet-1'

resource nic1 'Microsoft.Network/networkInterfaces@2021-03-01' = {
  name: 'nic-vm-spoke01-linux'
  location: region
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          subnet: {
            id: subnetRef
          }
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: pipvm01.id
            properties: {
              deleteOption: 'Detach'
            }
          }
        }
      }
    ]
    networkSecurityGroup: {
      id: nsg1.id
    }
  }
}

resource nsg1 'Microsoft.Network/networkSecurityGroups@2019-02-01' = {
  name: 'nsg-vm-spoke01'
  location: region
  properties: {
    securityRules: [
      {
        name: 'SSH'
        properties: {
          'priority': 300
          'protocol': 'Tcp'
          'access': 'Allow'
          'direction': 'Inbound'
          'sourceAddressPrefix': '*'
          'sourcePortRange': '*'
          'destinationAddressPrefix': '*'
          'destinationPortRange': '22'
        }
      }
    ]
  }
}

resource pipvm01 'Microsoft.Network/publicIpAddresses@2020-08-01' = {
  name: 'pip-vm-spoke01'
  location: region
  sku: {
    name: 'Basic'
  }
  properties: {
    publicIPAllocationMethod: 'Dynamic'
  }
}

resource vm01 'Microsoft.Compute/virtualMachines@2021-07-01' = {
  name: 'vm-spoke01'
  location: region
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_B1s'
    }
    storageProfile: {
      osDisk: {
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: 'Premium_LRS'
        }
        deleteOption: 'Delete'
      }
      imageReference: {
        publisher: 'canonical'
        offer: '0001-com-ubuntu-server-focal'
        sku: '20_04-lts-gen2'
        version: 'latest'
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: nic1.id
          properties: {
            deleteOption: 'Detach'
          }
        }
      ]
    }
    osProfile: {
      computerName: 'vm-spoke01'
      adminUsername: adminUsername
      adminPassword: adminPassword
//      linuxConfiguration: {
//        disablePasswordAuthentication: true
//        ssh: {
//          publicKeys: [
//            {
//              path: '/home/${adminUsername}/.ssh/authorized_keys'
//              keyData: adminPublicKey
//            }
//          ]
//        }
//      }
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: true
      }
    }
  }
}

output adminUsername string = adminUsername

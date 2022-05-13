@minLength(3)
@maxLength(24)
@description('Provide an Azure region for deploying the resources.')
param region string = resourceGroup().location

param storageAccountName string = 'toylaunch${uniqueString(resourceGroup().id)}'

param adminUsername string

param deployFirewall bool = false

@secure()
param adminPassword string // TODO: Replace with SSH setup

module hub 'hub.bicep' = {
  name: 'vnet-hub'
  params: {
    region: region
  }
}

module spoke01 'spoke.bicep' = {
  name: 'vnet-spoke01'
  params: {
    name: 'vnet-spoke01'
    ipSpace: '2' // 10.0.x.0
    region: region
  }
}

module spoke02 'spoke.bicep' = {
  name: 'vnet-spoke02'
  params: {
    name: 'vnet-spoke02'
    ipSpace: '3' // 10.0.x.0
    region: region
  }
}

module firewall 'firewall.bicep' = if (deployFirewall) {
  name: 'fw-hub'
  params: {
    region: region
    subnetId: hub.outputs.fwSubnetId
  }
}

var subnetRef = '${spoke01.outputs.id}/subnets/subnet-01'

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

param region string
param ordinal string
param adminUsername string
param adminPassword string
param subnetId string

resource nic 'Microsoft.Network/networkInterfaces@2021-03-01' = {
  name: 'nic-vm-spoke-${ordinal}'
  location: region
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig'
        properties: {
          subnet: {
            id: subnetId
          }
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: pip.id
            properties: {
              deleteOption: 'Detach'
            }
          }
        }
      }
    ]
    networkSecurityGroup: {
      id: nsg.id
    }
  }
}

resource nsg 'Microsoft.Network/networkSecurityGroups@2019-02-01' = {
  name: 'nsg-vm-spoke-${ordinal}'
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

resource pip 'Microsoft.Network/publicIpAddresses@2020-08-01' = {
  name: 'pip-vm-spoke-${ordinal}'
  location: region
  sku: {
    name: 'Basic'
  }
  properties: {
    publicIPAllocationMethod: 'Dynamic'
  }
}

resource vm 'Microsoft.Compute/virtualMachines@2021-07-01' = {
  name: 'vm-spoke-${ordinal}'
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
          id: nic.id
          properties: {
            deleteOption: 'Detach'
          }
        }
      ]
    }
    osProfile: {
      computerName: 'vm-spoke-${ordinal}'
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

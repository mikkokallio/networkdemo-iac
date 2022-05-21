param region string
param vmNumber string
param adminUsername string
param adminPassword string
param subnetId string
param logsId string
param storageId string

resource nic 'Microsoft.Network/networkInterfaces@2021-03-01' = {
  name: 'nic-vm-spoke-${vmNumber}'
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
        }
      }
    ]
    networkSecurityGroup: {
      id: nsg.id
    }
  }
}

resource nsg 'Microsoft.Network/networkSecurityGroups@2019-02-01' = {
  name: 'nsg-vm-spoke-${vmNumber}'
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

resource vm 'Microsoft.Compute/virtualMachines@2021-07-01' = {
  name: 'vm-spoke-${vmNumber}'
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
      computerName: 'vm-spoke-${vmNumber}'
      adminUsername: adminUsername
      adminPassword: adminPassword
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: true
      }
    }
  }
}

resource extensionNW 'Microsoft.Compute/virtualMachines/extensions@2021-11-01' = {
  name: '${vm.name}/AzureNetworkWatcherExtension'
  location: region
  properties: {
    publisher: 'Microsoft.Azure.NetworkWatcher'
    type: 'NetworkWatcherAgentLinux'
    typeHandlerVersion: '1.4'
    autoUpgradeMinorVersion: true
  }
}

resource extensionAMA 'Microsoft.Compute/virtualMachines/extensions@2021-11-01' = {
  name: '${vm.name}/AzureMonitorLinuxAgent'
  location: region
  properties: {
    publisher: 'Microsoft.Azure.Monitor'
    type: 'AzureMonitorLinuxAgent'
    typeHandlerVersion: '1.5'
    autoUpgradeMinorVersion: true
    enableAutomaticUpgrade: true
  }
}

resource extensionDA 'Microsoft.Compute/virtualMachines/extensions@2018-10-01' = {
  name: '${vm.name}/DependencyAgentLinux'
  location: region
  properties: {
    publisher: 'Microsoft.Azure.Monitoring.DependencyAgent'
    type: 'DependencyAgentLinux'
    typeHandlerVersion: '9.10'
    autoUpgradeMinorVersion: true
  }
}

resource extensionOMS 'Microsoft.Compute/virtualMachines/extensions@2018-10-01' = {
  name: '${vm.name}/OMSAgentForLinux'
  location: region
  properties: {
    publisher: 'Microsoft.EnterpriseCloud.Monitoring'
    type: 'OMSAgentForLinux'
    typeHandlerVersion: '1.7'
    autoUpgradeMinorVersion: true
    settings: {
      workspaceId: reference(logsId, '2015-03-20').customerId
      azureResourceId: vm.id
      stopOnMultipleConnections: true
    }
    protectedSettings: {
      workspaceKey: listKeys(logsId, '2015-03-20').primarySharedKey
    }
  }
}

/*resource insights 'Microsoft.OperationsManagement/solutions@2015-11-01-preview' = {
  location: region
  name: 'insights-vm-spoke-${vmNumber}'
  properties: {
    workspaceResourceId: logsId
  }
  plan: {
    name: 'VMInsights(${split(logsId, '/')[8]})'
    product: 'OMSGallery/VMInsights'
    publisher: 'Microsoft'
  }
}*/

module flowlog 'flowlog.bicep' = {
  name: 'flowlog-${vm.name}'
  scope: resourceGroup('NetworkWatcherRG')
  params: {
    region: region
    nsgId: nsg.id
    vmName: vm.name
    storageId: storageId
    logsId: logsId
  }
}

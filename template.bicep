param virtualMachines_vm_spoke_01_name string = 'vm-spoke-01'

resource virtualMachines_vm_spoke_01_name_AzureNetworkWatcherExtension 'Microsoft.Compute/virtualMachines/extensions@2021-11-01' = {
  name: '${virtualMachines_vm_spoke_01_name}/AzureNetworkWatcherExtension'
  location: 'northeurope'
  properties: {
    autoUpgradeMinorVersion: true
    publisher: 'Microsoft.Azure.NetworkWatcher'
    type: 'NetworkWatcherAgentLinux'
    typeHandlerVersion: '1.4'
  }
}
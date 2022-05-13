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

module vm01 'vm.bicep' = {
  name: 'vm-01'
  params: {
    ordinal: '01'
    region: region
    adminPassword: adminPassword
    adminUsername: adminUsername
    subnetId: '${spoke01.outputs.id}/subnets/subnet-01'
  }
}

module vm02 'vm.bicep' = {
  name: 'vm-02'
  params: {
    ordinal: '02'
    region: region
    adminPassword: adminPassword
    adminUsername: adminUsername
    subnetId: '${spoke02.outputs.id}/subnets/subnet-01'
  }
}

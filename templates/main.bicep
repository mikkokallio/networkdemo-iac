@minLength(3)
@maxLength(24)
@description('Choose an Azure region for deploying the resources.')
param region string = resourceGroup().location
@description('Choose whether an Azure Firewall is deployed in the hub vnet.')
param deployFirewall bool = true
@description('Choose whether an Azure Bastion is deployed in the hub vnet.')
param deployBastion bool = true
//@description('Choose whether a VPN Gateway is deployed in the hub vnet.')
//param deployGateway bool = true
@minValue(1)
@maxValue(4)
@description('Choose how many spoke vnets (with a VM each) are deployed.')
param numberOfSpokes int = 3
@description('Choose a name for you private DNS zone.')
param dnsZone string = 'networkdemo.com'
@description('Choose an admin username for accessing the spoke VMs.')
param adminUsername string
@secure()
@description('Choose an admin password for accessing the spoke VMs.')
param adminPassword string // TODO: Replace with SSH setup

@description('Deploy a central hub vnet for connectivity resources.')
module hub 'hub.bicep' = {
  name: 'vnet-hub'
  params: {
    region: region
  }
}

@description('Deploy spoke vnets, each peered to the hub and with a VM.')
module spoke 'spoke.bicep' = [for i in range(1, numberOfSpokes): {
  name: 'vnet-spoke-0${i}'
  params: {
    spokeNumber: '0${i}'
    ipSpace: '${i + 1}' // 10.0.x.0
    hubName: hub.outputs.vnetName
    region: region
    routetableId: routes.outputs.id
  }
}]

@description('Deploy a VM in each spoke vnet.')
module vm 'vm.bicep' = [for i in range(0, numberOfSpokes): {
  name: 'vm-spoke-0${i + 1}'
  params: {
    vmNumber: '0${i + 1}'
    region: region
    adminPassword: adminPassword
    adminUsername: adminUsername
    subnetId: '${spoke[i].outputs.id}/subnets/subnet-web'
    logsId: logs.outputs.id
    storageId: storage.outputs.id
  }
}]

@description('Deploy a bastion host in the hub for accessing spoke VMs.')
module bastion 'bastion.bicep' = if (deployBastion) {
  name: 'bastion-hub'
  params: {
    region: region
    hub: hub.outputs.vnetId
  }
}

@description('Deploy a firewall in the hub.')
module firewall 'firewall.bicep' = if (deployFirewall) {
  name: 'firewall-hub'
  params: {
    region: region
    hub: hub.outputs.vnetId
    logsId: logs.outputs.id
  }
}

@description('Deploy a private DNS zone and link vnets to it.')
module dns 'dns.bicep' = {
  name: dnsZone
  params: {
    dnsZone: dnsZone
    hubId: hub.outputs.vnetId
    spokeIds: [for i in range(0, numberOfSpokes): spoke[i].outputs.id]
  }
}

@description('Deploy a route table to enable spoke-spoke traffic.')
module routes 'routes.bicep' = {
  name: 'routetable'
  params: {
    region: region
  }
}

@description('Deploy a Log Analytics workspace to store logs from the firewall and VMs.')
module logs 'logs.bicep' = {
  name: 'logs'
  params: {
    region: region
  }
}

@description('Deploy a storage account to store logs and other data.')
module storage 'storage.bicep' = {
  name: 'storage'
  params: {
    region: region
  }
}

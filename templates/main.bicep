@minLength(3)
@maxLength(24)
@description('Choose an Azure region for deploying the resources.')
param region string = resourceGroup().location

//param storageAccountName string = 'storage${uniqueString(resourceGroup().id)}'

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
    dnsZone: dnsZone
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
    dnsZone: dnsZone
    adminPassword: adminPassword
    adminUsername: adminUsername
    routetableId: routes.outputs.id
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

@description('Deploy a private DNS zone to resolve e.g. VM names.')
resource dnszone 'Microsoft.Network/privateDnsZones@2018-09-01' = {
  name: dnsZone
  location: 'global'
}

@description('Deploy a route table to enable spoke-spoke traffic.')
module routes 'routes.bicep' = {
  name: 'routetable'
  params: {
    region: region
    //ip: firewall.outputs.ip
  }
}

@description('Deploy a Log Analytics workspace to store logs from the firewall and VMs.')
module logs 'logs.bicep' = {
  name: 'logs'
  params: {
    region: region
  }
}

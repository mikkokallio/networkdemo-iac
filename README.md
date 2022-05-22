# networkdemo-iac

1. `az login`
2. `az group create --location northeurope --resource-group rg-networkdemo`
3. `az configure --defaults group=rg-networkdemo`
4. `az deployment group create --template-file ./templates/main.bicep`

To avoid entering parameters manually every time you run the template, you can put the values in the command like so:

az deployment group create --template-file ./templates/main.bicep --parameters adminUsername=<username> adminPassword=<password> deployWatcher=false

## Incorporating deployment json to bicep

az bicep decompile --file .\template.json

## Features

The main template deploys the following assets to Azure:
* A hub vnet with Azure Bastion, Azure Firewall, and VPN Gateway (TBA!)
* Firewall rules that allow spoke-spoke traffic (ping and ssh).
* One or more spoke vnets that are peered bi-directionally with the hub.
* In each spoke vnet, two subnets and a VM with the network watcher and AMA extensions enabled.
* Routes to enable spoke-spoke traffic.
* A Log Analytics workspace for firewall and VM logs and storage account for NSG flow logs and other data.
* A DNS zone that is linked to the hub and all spokes.

## Scenarios

* Network Watcher and flow logs
* Routing in a hub-spoke architecture
* Securing a storage account with a private endpoint and accessing it through a private network

## Bugs

* Firewall deployment isn't idempotent. Attempting to run the deployment again results in an error.
* VM insights doesn't work properly.

## Disclaimers

* The template deploys all resources in the same resource group regardless of their lifecycle. This is not a recommended practice, but it is used here so that it is easy to clean up the resources after use.
* This is not a production-grade setup. Rather, it is mainly intended for learning, testing, and demoing basic networking concepts in Azure.

## Todo

* VPN gateway
* Key vault with private endpoint (in progress)
* Use key vault for SSH
* VM enable logging to Log Analytics
* Block public access to storage and put e.g. private storage endpoint in dedicated subnet in the hub and add DNS zone
* Add simple apps in VMs to generate some traffic
* Use deployment script
* Firewall workbook
* Experiment with Azure DNS Private Resolver or Firewall as DNS Proxy
* NSGs in subnets by default, move flow logs to those
* Enable tagging
* Load balancing
* Some support for hybrid connectivity and Arc
* Consider a mock implementation of landing zone architecture with segmentation into rg-management, rg-connectivity, and rg-lz for different types of landing zones / spokes.
* Spokes could have some variety in the workloads, e.g. App Service or AKS. 
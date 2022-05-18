# networkdemo-iac

1. `az login`
2. `az group create --location northeurope --resource-group rg-networkdemo`
3. `az configure --defaults group=rg-networkdemo`
4. `az deployment group create --template-file ./templates/main.bicep`

## Incorporating deployment json to bicep

az bicep decompile --file .\template.json

## Features

The main template deploys the following assets to Azure:
* A hub vnet with Azure Bastion, Azure Firewall, and VPN Gateway (TBA!)
* Firewall rules that allow spoke-spoke traffic (ping and ssh).
* One or more spoke vnets that are peered bi-directionally with the hub.
* In each spoke vnet, two subnets and a VM with the network watcher and AMA extensions enabled.
* Routes to enable spoke-spoke traffic.
* A Log Analytics workspace for firewall logs.
* A DNS zone that is linked to the hub and all spokes.

## Bugs

* The deployment fails with the error The zone 'networkdemo.com' does not exist in resource group 'rg-networkdemo' of subscription 'xyz', but running the deployment again solves the issue.
* Firewall deployment isn't idempotent. Attempting to run the deployment again results in an error.

## Disclaimers

* The template deploys all resources in the same resource group regardless of their lifecycle. This is not a recommended practice, but it is used here so that it is easy to clean up the resources after use.
* This is not a production-grade setup. Rather, it is mainly intended for learning, testing, and demoing basic networking concepts in Azure.

## Todo

* VPN gateway
* Storage for network watcher
* Key vault for SSH setup
* Deploy MMA in VMs and enable logging to Log Analytics
* Add resources with private endpoints and related DNS zones
* Add simple apps in VMs to generate some traffic
* Use deployment script
* Firewall workbook
* Experiment with Azure DNS Private Resolver or Firewall as DNS Proxy
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
* Firewall rules that allow spoke-spoke traffic.
* One or more spoke vnets that are peered bi-directionally with the hub.
* In each spoke vnet, two subnets and a VM with the network watcher extension enabled.
* Routes to enable spoke-spoke traffic.
* A DNS zone that is linked to the hub and all spokes.

## Bugs

* The deployment fails with the error The zone 'networkdemo.com' does not exist in resource group 'rg-networkdemo' of subscription 'xyz', but running the deployment again solves the issue.

## Todo

* VPN gateway
* Storage for network watcher
* Log Analytics for FW
* Key vault for SSH setup
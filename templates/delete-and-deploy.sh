az group delete --name rg-networkdemo --no-wait
az group create --location northeurope --resource-group rg-networkdemo
az configure --defaults group=rg-networkdemo
az deployment group create --template-file ./templates/main.bicep

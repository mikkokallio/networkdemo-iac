az group delete --name rg-networkdemo3 --no-wait
az group create --location northeurope --resource-group rg-networkdemo2
az configure --defaults group=rg-networkdemo2
az deployment group create --template-file ./templates/main.bicep

az group delete --name rg-networkdemo2 --no-wait
az group create --location northeurope --resource-group rg-networkdemo
az configure --defaults group=rg-networkdemo
az deployment group create --template-file ./templates/main.bicep

az group delete --name rg-networkdemo --no-wait
az group create --location northeurope --resource-group rg-networkdemo3
az configure --defaults group=rg-networkdemo3
az deployment group create --template-file ./templates/main.bicep

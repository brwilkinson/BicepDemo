param storageAccountInfo object

resource storageaccount 'Microsoft.Storage/storageAccounts@2021-04-01' = {
  name: storageAccountInfo.name
  location: resourceGroup().location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
}





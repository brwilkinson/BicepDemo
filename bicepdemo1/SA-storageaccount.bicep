param storageAccountInfo object

resource storageAccount 'Microsoft.Storage/storageAccounts@2021-02-01' = {
  name: 'sa${storageAccountInfo.name}'
  location: resourceGroup().location
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
  }
}

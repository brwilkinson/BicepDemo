
var storageaccount = {
  name: 'storage5489123'
}

resource storageAccount 'Microsoft.Storage/storageAccounts@2021-04-01' = {
  name: storageaccount.name
  location: resourceGroup().location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
}

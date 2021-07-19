param deploymentInfo object

var storageAccountInfo = deploymentInfo.storageAccountInfo

module SA 'SA-storageaccount.bicep' = [for (sa, index) in storageAccountInfo: {
  name: sa.name
  params: {
    storageAccountInfo: sa
  }
}]

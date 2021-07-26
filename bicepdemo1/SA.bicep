param deploymentInfo object
param stage object

var saInfo = deploymentInfo.saInfo

module SA 'SA-storageaccount.bicep' = [for (sa, index) in saInfo: {
  name: sa.name
  params: {
    storageAccountInfo: sa
  }
}]

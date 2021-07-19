param publicIPInfo object

resource publicIPAddress 'Microsoft.Network/publicIPAddresses@2019-11-01' = {
  name: 'pip-${publicIPInfo.name}'
  location: resourceGroup().location
  properties: {
    publicIPAllocationMethod: 'Dynamic'
  }
}

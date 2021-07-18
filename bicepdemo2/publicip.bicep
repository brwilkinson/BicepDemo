param publicIPInfo object

resource publicip 'Microsoft.Network/publicIPAddresses@2021-02-01' = {
  name: publicIPInfo.name
  location: resourceGroup().location
  
}

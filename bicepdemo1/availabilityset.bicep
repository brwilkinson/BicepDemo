
var availabilityset = {
  name: 'as1'
}

resource availabilitySet 'Microsoft.Compute/availabilitySets@2020-12-01' = {
  name: availabilityset.name
  location: resourceGroup().location
}

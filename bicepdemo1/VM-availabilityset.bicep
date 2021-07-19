
param availabilitySetInfo object

resource availabilitySet 'Microsoft.Compute/availabilitySets@2021-03-01' = {
  name: 'as-${availabilitySetInfo.name}'
  location: resourceGroup().location
}

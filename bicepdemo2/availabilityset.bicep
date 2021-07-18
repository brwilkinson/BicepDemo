param availabilitysetInfo object

resource availabilityset 'Microsoft.Compute/availabilitySets@2021-03-01' = {
  name: availabilitysetInfo.name
  location: resourceGroup().location
}

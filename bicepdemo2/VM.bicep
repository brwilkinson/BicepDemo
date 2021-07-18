param deploymentInfo object

var vmInfo = deploymentInfo.vmInfo

module AS 'availabilityset.bicep' = [for (as, index) in vmInfo: {
  name: as.name
  params: {
    availabilitysetInfo: as
  }
}]

module PIP 'publicip.bicep' = [for (pip, index) in vmInfo: {
  name: pip.name
  params: {
    publicIPInfo: pip
  }
}]

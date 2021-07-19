param deploymentInfo object

var vmInfo = deploymentInfo.vmInfo

module AS 'VM-availabilityset.bicep' = [for (vm, index) in vmInfo: {
  name: 'dp-as-${vm.name}'
  params: {
    availabilitySetInfo: vm
  }
}]

module PIP 'VM-publicip.bicep' = [for (vm, index) in vmInfo: {
  name: 'dp-pip-${vm.name}'
  params: {
    publicIPInfo: vm
  }
}]

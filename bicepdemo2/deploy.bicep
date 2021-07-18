param deploymentInfo object

module SA 'SA.bicep' = {
  name: 'dp_SA'
  params: {
    deploymentInfo: deploymentInfo
  }
}

module VM 'VM.bicep' = {
  name: 'dp_VM'
  params: {
  deploymentInfo: deploymentInfo
  }
}


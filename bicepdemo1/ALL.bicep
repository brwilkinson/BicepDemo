param deploymentInfo object
param stage object

module SA 'SA.bicep' = if (stage.SA == 1) {
  name: 'dp-SA'
  params: {
    deploymentInfo: deploymentInfo
    stage: stage
  }
}

module VM 'VM.bicep' = if (stage.VM == 1) {
  name: 'dp-VM'
  params: {
    deploymentInfo: deploymentInfo
    stage: stage
  }
}

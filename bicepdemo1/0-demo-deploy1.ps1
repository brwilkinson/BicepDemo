$artifacts1 = $psscriptroot
$rgname = 'bicepdemo1'
$region = 'CentralUS'
Write-Warning -Message "Path is: [$artifacts1]"
Write-Warning -Message "RG is: [$rgname] in Region: [$region]"
break

New-AzResourceGroup -Name $rgname -Location $region -Force

# Create a layer above to orchestrate everything and provide features flags to use in Pipelines

$MyParametersDeployALL = @{
    ResourceGroupName     = $rgname
    TemplateParameterFile = "$artifacts1\param-env1.json"
    Verbose               = $true
    WhatIf                = $false
}

# Orchestrate the deployment of all resources - VM and Storage or other
New-AzResourceGroupDeployment @MyParametersDeployALL -TemplateFile $artifacts1\ALL.bicep

# Deploy Single layer, inner dev loop - VM only
New-AzResourceGroupDeployment @MyParametersDeployALL -TemplateFile $artifacts1\VM.bicep

# Deploy Single layer, inner dev loop - Storage only
New-AzResourceGroupDeployment @MyParametersDeployALL -TemplateFile $artifacts1\SA.bicep


$artifacts = $psscriptroot
$rgname = 'bicepdemo'
$region = 'CentralUS'
Write-Warning -Message "Path is: [$artifacts]"
Write-Warning -Message "RG is: [$rgname] in Region: [$region]"
break

# This demo takes 1 hour...creating templates from scratch.

New-AzResourceGroup -Name $rgname -Location $region -Force

# Single Resources, create files and build out the templates
New-Item -Path @(
    "$artifacts\VM-availabilityset.bicep",
    "$artifacts\VM-publicip.bicep", 
    "$artifacts\SA-storageaccount.bicep"
)

#region Single Resources as Modules

New-AzResourceGroupDeployment -ResourceGroupName $rgname -TemplateFile $artifacts\VM-availabilityset.bicep
Get-AzResource -ResourceGroupName $rgname
bicep build $artifacts\VM-availabilityset.bicep

New-AzResourceGroupDeployment -ResourceGroupName $rgname -TemplateFile $artifacts\VM-publicip.bicep -WhatIf
New-AzResourceGroupDeployment -ResourceGroupName $rgname -TemplateFile $artifacts\SA-storageaccount.bicep -WhatIf

#endregion




#region Call into Modules to build App Environments - Including array processing

New-Item -Path $artifacts\VM.bicep, $artifacts\SA.bicep, $artifacts\ALL.bicep

# Group resources together to build related collections of resources
New-AzResourceGroupDeployment -ResourceGroupName $rgname -TemplateFile $artifacts\VM.bicep -WhatIf

New-AzResourceGroupDeployment -ResourceGroupName $rgname -TemplateFile $artifacts\SA.bicep

# Create a layer above to orchestrate everything and provide features flags to use in Pipelines

$MyParametersDeployALL = @{
    ResourceGroupName     = $rgname
    TemplateParameterFile = "$artifacts\param-env.json"
    Verbose               = $true
    WhatIf                = $true
}

# Orchestrate the deployment of all resources
New-AzResourceGroupDeployment @MyParametersDeployALL -TemplateFile $artifacts\ALL.bicep

# Deploy Single layer, inner dev loop
New-AzResourceGroupDeployment @MyParametersDeployALL -TemplateFile $artifacts\VM.bicep

#endregion




#region    What else can I do with Bicep ?

Bicep --help

<#
    Examples:
      bicep build file.json

    Examples:
      bicep decompile file.json
      bicep decompile file.json --stdout
      bicep decompile file.json --outdir dir1
      bicep decompile file.json --outfile file.bicep
#>

# Compile a Bicep file to ARM json, check if there are any errors

bicep build $artifacts\VM.bicep

# Decompile a ARM json to a Bicep file

# 

bicep decompile $artifacts\webfarm.json

# Now Build that new Bicep file, without Deploying it.

bicep build $artifacts\aks.bicep --outfile $artifacts\aksNew.json

#endregion What else can I do with Bicep ?

# cleanup files
Get-ChildItem -Path $artifacts -Filter *.bicep | Remove-Item -Confirm
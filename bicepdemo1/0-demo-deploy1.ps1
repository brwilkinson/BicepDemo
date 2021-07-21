$artifacts1 = $psscriptroot
$rgname = 'bicepdemo1'
$region = 'CentralUS'
Write-Warning -Message "Path is: [$artifacts1]"
Write-Warning -Message "RG is: [$rgname] in Region: [$region]"
break


New-AzResourceGroup -Name $rgname -Location $region -Force

<#
New-Item -Path $artifacts1\VM-availabilityset.bicep, $artifacts1\VM-publicip.bicep, $artifacts1\SA-storageaccount.bicep

# Single Resources as Modules

New-AzResourceGroupDeployment -ResourceGroupName $rgname -TemplateFile $artifacts1\VM-availabilityset.bicep
bicep build $artifacts1\VM-availabilityset.bicep
Get-AzResource -ResourceGroupName $rgname

New-AzResourceGroupDeployment -ResourceGroupName $rgname -TemplateFile $artifacts1\VM-publicip.bicep -WhatIf

New-AzResourceGroupDeployment -ResourceGroupName $rgname -TemplateFile $artifacts1\SA-storageaccount.bicep -WhatIf


# Call into Modules to build App Environments - Including array processing

New-Item -Path $artifacts1\VM.bicep, $artifacts1\SA.bicep, $artifacts1\ALL.bicep


# Group resources together to build related collections of resources
New-AzResourceGroupDeployment -ResourceGroupName $rgname -TemplateFile $artifacts1\VM.bicep -WhatIf

New-AzResourceGroupDeployment -ResourceGroupName $rgname -TemplateFile $artifacts1\SA.bicep

#>

# Create a layer above to orchestrate everything and provide features flags to use in Pipelines

$MyParametersDeployALL = @{
    ResourceGroupName     = $rgname
    TemplateParameterFile = "$artifacts1\param-env1.json"
    Verbose               = $true
    WhatIf                = $false
}

# Orchestrate the deployment of all resources
New-AzResourceGroupDeployment @MyParametersDeployALL -TemplateFile $artifacts1\ALL.bicep

# Deploy Single layer, inner dev loop
New-AzResourceGroupDeployment @MyParametersDeployALL -TemplateFile $artifacts1\VM.bicep

# Deploy Single layer, inner dev loop
New-AzResourceGroupDeployment @MyParametersDeployALL -TemplateFile $artifacts1\SA.bicep


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

bicep build $artifacts1\VM.bicep

# Decompile a ARM json to a Bicep file

# 

bicep decompile $artifacts1\webfarm.json

# Now Build that new Bicep file, without Deploying it.

bicep build $artifacts1\aks.bicep --outfile $artifacts1\aksNew.json

#endregion What else can I do with Bicep ?

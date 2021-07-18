$artifacts = $psscriptroot
$rgname = 'bicepdemo1'
$region = 'CentralUS'
Write-Warning -Message "Path is: [$artifacts]"
Write-Warning -Message "RG is: [$rgname] in Region: [$region]"
break

New-Item -Path $artifacts\availabilityset.bicep, $artifacts\storageaccount.bicep, $artifacts\publicip.bicep

New-AzResourceGroup -Name $rgname -Location $region

# Single Resources as Modules

New-AzResourceGroupDeployment -ResourceGroupName $rgname -TemplateFile $artifacts\availabilityset.bicep
New-AzResourceGroupDeployment -ResourceGroupName $rgname -TemplateFile $artifacts\publicip.bicep

New-AzResourceGroupDeployment -ResourceGroupName $rgname -TemplateFile $artifacts\storageaccount.bicep


# Call into Modules to build App Environments - Including array processing

New-Item -Path $artifacts\VM.bicep, $artifacts\SA.bicep, $artifacts\ALL.bicep

New-AzResourceGroupDeployment -ResourceGroupName $rgname -TemplateFile $artifacts\VM.bicep

New-AzResourceGroupDeployment -ResourceGroupName $rgname -TemplateFile $artifacts\SA.bicep

# What else can I do with Bicep ?

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


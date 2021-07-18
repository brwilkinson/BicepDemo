$artifacts = $psscriptroot
write-warning -Message "Path is: [$artifacts]"
break

$rgname = 'bicepdemo2'

New-AzResourceGroup -Name $rgname -Location 'CentralUS'

New-AzResourceGroupDeployment -ResourceGroupName $rgname -TemplateFile $artifacts\availabilityset.bicep

New-AzResourceGroupDeployment -ResourceGroupName $rgname -TemplateFile $artifacts\storageaccount.bicep

New-AzResourceGroupDeployment -ResourceGroupName $rgname -TemplateFile $artifacts\publicip.bicep

New-AzResourceGroupDeployment -ResourceGroupName $rgname -TemplateFile $artifacts\VM.bicep

New-AzResourceGroupDeployment -ResourceGroupName $rgname -TemplateFile $artifacts\SA.bicep
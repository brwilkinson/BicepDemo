<#
.SYNOPSIS
    Short description
.DESCRIPTION
    Long description
.EXAMPLE
    PS C:\> <example usage>
    Explanation of what the example does
.INPUTS
    Inputs (if any)
.OUTPUTS
    Output (if any)
.NOTES
    General notes
#>

Function global:Start-AzDeploy
{
    [CmdletBinding()]
    param (
        [string] $Artifacts = (Get-Item -Path "$PSScriptRoot\.."),

        [alias('TF')]
        [string] $TemplateFile = "$Artifacts\01-deploy-ALL.json",
        
        [parameter(mandatory)]
        [alias('DP')]
        [validateset('P0', 'S1', 'S2', 'S3', 'D3', 'D4', 'T5', 'U6', 'P7', 'G0', 'G1', 'M0', 'A0')]
        [string] $Deployment,

        [validateset('WEB', 'PSO', 'HUB', 'ABC', 'AOA', 'HAA')]
        [alias('AppName')]
        [string] $App = 'AOA',

        [validateset('AEU2', 'ACU1', 'AEU1', 'AWU2')]
        [String] $Prefix = 'ACU1',

        [alias('ComputerName')]
        [string] $CN = '.',

        # When deploying VM's, this is a subset of AppServers e.g. AppServers, SQLServers, ADPrimary
        [string] $DeploymentName = ($Prefix + '-' + $App + '-' + $Deployment + '-' + (Get-ChildItem $TemplateFile).BaseName),

        [Switch] $SubscriptionDeploy,

        [switch] $WhatIf,

        [validateset('ResourceIdOnly', 'FullResourcePayloads')]
        [String] $WhatIfFormat = 'ResourceIdOnly'
    )

    $Global = @{ }

    # Read in the Rolegroups Lookup.
    $RolesGroupsLookup = Get-Content -Path $Artifacts\tenants\$App\Global-Config.json | ConvertFrom-Json -Depth 10 | ForEach-Object RolesGroupsLookup
    $Global.Add('RolesGroupsLookup', ($RolesGroupsLookup | ConvertTo-Json -Compress -Depth 10))

    # Read in the Prefix Lookup for the Region.
    $PrefixLookup = Get-Content $Artifacts\release\prefix.json | ConvertFrom-Json
    $Global.Add('PrefixLookup', ($PrefixLookup | ConvertTo-Json -Compress -Depth 10))

    $ResourceGroupLocation = $PrefixLookup | Foreach $Prefix | ForEach-Object location

    $GlobalGlobal = Get-Content -Path $Artifacts\tenants\$App\Global-Global.json | ConvertFrom-Json -Depth 10 | ForEach-Object Global
    $Regional = Get-Content -Path $Artifacts\tenants\$App\Global-$Prefix.json | ConvertFrom-Json -Depth 10 | ForEach-Object Global

    $ResourceGroupName = $prefix + '-' + $GlobalGlobal.OrgName + '-' + $App + '-RG-' + $Deployment

    # Convert any objects back to string so they are not deserialized
    $GlobalGlobal | Get-Member -MemberType NoteProperty | ForEach-Object {

        if ($_.Definition -match 'PSCustomObject')
        {
            $Object = $_.Name
            $String = $GlobalGlobal.$Object | ConvertTo-Json -Compress -Depth 10
            $GlobalGlobal.$Object = $String
        }
    }

    # Convert any objects back to string so they are not deserialized
    $Regional | Get-Member -MemberType NoteProperty | ForEach-Object {

        if ($_.Definition -match 'PSCustomObject')
        {
            $Object = $_.Name
            $String = $Regional.$Object | ConvertTo-Json -Compress -Depth 10
            $Regional.$Object = $String
        }
    }

    # Merge regional with Global
    $Regional | Get-Member -MemberType NoteProperty | ForEach-Object {
        $Property = $_.Name
        $Value = $Regional.$Property
        $GlobalGlobal | Add-Member NoteProperty -Name $Property -Value $Value
    }

    $GlobalGlobal | Get-Member -MemberType NoteProperty | ForEach-Object {
        $Property = $_.Name
        $Global.Add($Property, $GlobalGlobal.$Property)
    }
    $Global.Add('CN', $CN)

    # $Global

    #region Only needed for extensions such as DSC or Script extension
    $StorageAccountName = $Global.SAName
    $StorageAccount = Get-AzStorageAccount | Where-Object { $_.StorageAccountName -eq $StorageAccountName }
    $StorageContainerName = "$Prefix-$App-stageartifacts-$env:USERNAME".ToLowerInvariant()
    $TemplateURIBase = $StorageAccount.Context.BlobEndPoint + $StorageContainerName
    Write-Verbose "Storage Account is: [$StorageAccountName] and containeris: [$StorageContainerName]" -Verbose

    $SASParams = @{
        Container  = $StorageContainerName 
        Context    = $StorageAccount.Context
        Permission = 'r'
        ExpiryTime = (Get-Date).AddHours(4)
    }
    $queryString = (New-AzStorageContainerSASToken @SASParams).Substring(1)
    $Global.Add('_artifactsLocation', $TemplateURIBase)
    $Global.Add('_artifactsLocationSasToken', "?${queryString}")
    #endregion

    $TemplateArgs = @{ }
    $OptionalParameters = @{ }
    $OptionalParameters['Global'] = $Global
    $OptionalParameters['Environment'] = $Deployment.substring(0, 1)
    $OptionalParameters['DeploymentID'] = $Deployment.substring(1, 1)

    $TemplateParametersFile = "$Artifacts\tenants\$App\$Prefix.$Deployment.parameters.json"
    Write-Warning -Message "Using parameter file: [$TemplateParametersFile]"
    $TemplateArgs.Add('TemplateParameterFile', $TemplateParametersFile)

    Write-Warning -Message "Using template file: [$TemplateFile]"
    $TemplateFile = Get-Item -Path $TemplateFile | ForEach-Object FullName

    Write-Warning -Message "Using template File: [$TemplateFile]"
    $TemplateArgs.Add('TemplateFile', $TemplateFile)

    $OptionalParameters.getenumerator() | ForEach-Object {
        Write-Verbose $_.Key -Verbose
        Write-Warning $_.Value
    }

    $TemplateArgs.getenumerator() | Where-Object Key -NE 'queryString' | ForEach-Object {
        Write-Verbose $_.Key -Verbose
        Write-Warning $_.Value
    }

    $Common = @{
        Name     = $DeploymentName
        Location = $ResourceGroupLocation
        Verbose  = $true
    }

    switch ($Deployment) 
    {
        # Tenant
        'A0' 
        {
            Write-Output 'A0'
            if ($WhatIf)
            {
                $Common.Remove('Name')
                $Common['ResultFormat'] = $WhatIfFormat
                Get-AzTenantDeploymentWhatIfResult @Common @TemplateArgs @OptionalParameters
            }
            else 
            {
                New-AzTenantDeployment @Common @TemplateArgs @OptionalParameters
            }
        }

        # ManagementGroup
        'M0' 
        {
            Write-Output 'M0'
            if ($WhatIf)
            {
                $Common.Remove('Name')
                $Common['ResultFormat'] = $WhatIfFormat
                Get-AzManagementGroupDeploymentWhatIfResult @Common @TemplateArgs @OptionalParameters
            }
            else 
            {
                New-AzManagementGroupDeployment @Common @TemplateArgs @OptionalParameters
            }
        }

        Default 
        {
            # Subscription
            if ($SubscriptionDeploy -OR $Deployment -eq 'G0')
            {
                if ($WhatIf)
                {
                    $Common.Remove('Name')
                    $Common['ResultFormat'] = $WhatIfFormat
                    Get-AzSubscriptionDeploymentWhatIfResult @Common @TemplateArgs @OptionalParameters
                }
                else 
                {
                    New-AzSubscriptionDeployment @Common @TemplateArgs @OptionalParameters
                }
            }
            # ResourceGroup
            else
            {
                $Common.Remove('Location')
                $Common['ResourceGroupName'] = $ResourceGroupName
                if ($WhatIf)
                {
                    $Common.Remove('Name')
                    $Common['ResultFormat'] = $WhatIfFormat
                    Get-AzResourceGroupDeploymentWhatIfResult @Common @TemplateArgs @OptionalParameters
                }
                else 
                {
                    New-AzResourceGroupDeployment @Common @TemplateArgs @OptionalParameters
                }
            }
        }
    }
} # Start-AzDeploy 

New-Alias -Name AzDeploy -Value Start-AzDeploy -Force -Scope Global
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

        [validateset('ADF', 'PSO', 'HUB', 'ABC', 'AOA', 'HAA')]
        [alias('AppName')]
        [string] $App = 'AOA',

        [validateset('AEU2', 'ACU1', 'AEU1', 'AWU2')]
        [String] $Prefix = 'ACU1',

        [alias('ComputerName')]
        [string] $CN = '.',

        # When deploying VM's, this is a subset of AppServers e.g. AppServers, SQLServers, ADPrimary
        [string] $DeploymentName = ($Prefix + '-' + $Deployment + '-' + $App + '-' + (Get-ChildItem $TemplateFile).BaseName),

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

    $ResourceGroupLocation = $PrefixLookup | Where-Object Prefix -EQ $Prefix | ForEach-Object location

    $GlobalGlobal = Get-Content -Path $Artifacts\tenants\$App\Global-Global.json | ConvertFrom-Json -Depth 10 | ForEach-Object Global
    $Regional = Get-Content -Path $Artifacts\tenants\$App\Global-$Prefix.json | ConvertFrom-Json -Depth 10 | ForEach-Object Global

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

    $Global

    # Only needed for extensions such as DSC or Script extension
    $StorageContainerName = "$Prefix-$App-stageartifacts-$env:USERNAME".ToLowerInvariant()

    $StorageAccountName = $Global.SAName
    Write-Verbose "Storage Account is: [$StorageAccountName] and containeris: [$StorageContainerName]" -Verbose

    

} # Start-AzDeploy 

New-Alias -Name AzDeploy -Value Start-AzDeploy -Force -Scope Global
$PrefixLookup = @{}
Get-AzLocation | ForEach-Object {
    $parts = $_.displayname -split '\s' ;
    
    # Build the Naming Standard based on the name parts
    $NameFormat = $($Parts[0][0] + $Parts[1][0] ) + $(if ($parts[2]) { $parts[2][0] }else { 1 })
    $Prefix = 'A' + $NameFormat

    $PrefixLookup[$Prefix] = [pscustomobject]@{
        displayname  = $_.displayname; 
        location     = $_.location; 
        first        = $Parts[0]; 
        second       = $parts[1]; 
        third        = $parts[2]; 
        Name         = $NameFormat
        NameOverRide = ''       # Column for any name collisions to create "manual" override
        PREFIX       = $Prefix # Add the 'A' for Azure to the front of the Name
    } 
}

$PrefixLookup | ConvertTo-Json | Set-Content -Path $PSScriptRoot\..\release\prefix.json

# There are 3 overrides which you can manually update available on the link below
# https://brwilkinson.github.io/AzureDeploymentFramework/docs/Naming_Standards_Prefix.html

<#
- 3 Name overrides are currently in place
    - Brazil Southeast    BS1 --> BSE
    - North Europe        NE1 --> NEU
    - West Europe         WE1 --> WEU
#>


param (
    [String]$App = 'HAA'
)

[System.Collections.Specialized.OrderedDictionary]$ht = @{}
Get-AzRoleDefinition | Sort-Object -Property Name | ForEach-Object {
    
    $ht += @{$_.Name = [pscustomobject]@{ Id = $_.ID; Description = $_.Description } }
}
$Artifacts = Get-Item -Path $PSScriptRoot\..

$GlobalConfigPath = "$Artifact\tenants\$App\Global-Config.json"
if (Test-Path -Path $GlobalConfigPath)
{
    $GlobalConfig = Get-Content -Path $Artifacts\tenants\$App\Global-Config.json | ConvertFrom-Json
}
else
{
    $GlobalConfig = [PSCustomObject]@{}
}

$GlobalConfig | Add-Member -Name RolesGroupsLookup -MemberType NoteProperty -Value $ht -Force
$GlobalConfig | ConvertTo-Json -Depth 5 | Set-Content -Path $Artifacts\tenants\$App\Global-Config.json


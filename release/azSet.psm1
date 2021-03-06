function Global:AzSet
{
    param (
        [parameter(Mandatory)]
        [string]$Enviro,
        [parameter(Mandatory)]
        [validateset('ABC', 'WEB', 'AOA', 'HUB', 'PSO', 'HAA')]
        [string]$App
    )
    # F5 to load
    $BICEP = Get-Item -Path "$PSScriptRoot\.."
    $Global:Current = @{App = $App; DP = $Enviro }
    if (!(Test-Path BICEP:\)) { New-PSDrive -PSProvider FileSystem -Root $BICEP -Name BICEP -scope Global}
    Import-Module -Name BICEP:\release\Start-AzDeploy.ps1 -Scope Global -Force
    $env:Enviro = "${App} ${Enviro}" # add this to track on prompt (oh-my-posh env variable)
    Write-Verbose "ArtifactStagingDirectory is [$BICEP] and App is [$App] and Enviro is [$env:Enviro]" -Verbose
    Write-Verbose 'Sample Command: [AzDeploy @Current -Prefix ACU1 -TF BICEP:\bicep\AKS.bicep]' -Verbose
    prompt
}
# Helper script for VSTS Releases

param (
    [ValidateSet('WEB', 'PSO', 'ABC', 'HUB', 'AOA')]
    [String]$APP = 'AOA',
    
    [String]$Env,
    
    [string]$Prefix = 'AZC1',
    
    [String]$stage = 'ALL',
    
    [switch]$SubscriptionDeploy,
    
    [switch]$FullUpload
)

. $PSScriptRoot\Start-AzDeploy.ps1
$Artifacts = Get-Item -Path "$PSScriptRoot\.."

$templatefile = "$Artifacts\$stage.json"

$Params = @{
    App          = $APP
    Deployment   = $Env 
    Prefix       = $Prefix
    Artifacts    = $Artifacts
    TemplateFile = $templatefile
}

Start-AzDeploy @Params -FullUpload:$FullUpload -VSTS -SubscriptionDeploy:$SubscriptionDeploy # -LogAzDebug:$LogAzDebug
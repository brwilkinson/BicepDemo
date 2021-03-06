# Helper script for VSTS Releases

param (
    [ValidateSet('WEB', 'PSO', 'ABC', 'HUB', 'AOA')]
    [String]$APP = 'AOA',
    
    [String]$Env,
    
    [string]$Prefix = 'AZC1',
    
    [String]$stage = 'ALL',
    
    [switch]$SubscriptionDeploy
    
    # [switch]$FullUpload
)

. $PSScriptRoot\Start-AzDeploy.ps1
$Artifacts = Get-Item -Path "$PSScriptRoot\.."

$templatefile = "$Artifacts\bicep\$stage.bicep"

$Params = @{
    App          = $APP
    Deployment   = $Env 
    Prefix       = $Prefix
    Artifacts    = $Artifacts
    TemplateFile = $templatefile
}

Start-AzDeploy @Params -SubscriptionDeploy:$SubscriptionDeploy # -LogAzDebug:$LogAzDebug -FullUpload:$FullUpload -VSTS
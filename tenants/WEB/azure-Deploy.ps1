param (
    [string]$Enviro = 'S1',
    [string]$App = 'WEB'
)
Import-Module -Name "$PSScriptRoot\..\..\release\azSet.psm1" -Force
AzSet -Enviro $enviro -App $App
break
# F8 to run individual steps

#region Note this file is here to get to you you started, you can run ALL of this from the command line
# Put that import-module line above in your profile,...then..
# once you know these commands you just run the following in the commandline AzSet -Enviro D3 -App AOA
# Then you can execute from Terminal.
#endregion

#region    Pre-reqs
# Create Global Storage Account, for artifacts
. BICEP:\prereqs\1-CreateStorageAccountGlobal.ps1 @Current

# Export all role defintions
. BICEP:\prereqs\0-Get-RoleDefinitionTable.ps1 @Current

# Bootstrap Hub RGs and Keyvaults
. BICEP:\prereqs\1-CreateHUBKeyVaults.ps1 @Current
# then add localadmin cred manually in primary region.

# Create Global Web Create
. BICEP:\prereqs\2-CreateUploadWebCertAdminCreds.ps1 @Current

# Sync the keyvault from CentralUS to EastUS2 (Primary Region to Secondary Region [auto detected])
. BICEP:\prereqs\3-Start-AzureKVSync.ps1

# Create Service principal for Env. + add GH secret or AZD Service connections
# Infra in Github
Set-Location -Path BICEP:\
. BICEP:\prereqs\4-Start-CreateServicePrincipalGH.ps1 @Current -Prefix ACU1 -Environments $Enviro    # D3, P0, G0, G1, S1, T5, P7
. BICEP:\prereqs\4-Start-CreateServicePrincipalGH.ps1 @Current -Prefix AEU2 -Environments $Enviro    # P0, S1, T5, P7

# App pipelines in AZD
. BICEP:\prereqs\4-Start-CreateServicePrincipal.ps1 @Current -Prefix ACU1 -Environments $Enviro      # D3, P0, G0, G1, S1, T5, P7
. BICEP:\prereqs\4-Start-CreateServicePrincipal.ps1 @Current -Prefix AEU2 -Environments $Enviro      # P0, S1, T5, P7

#endregion Pre-reqs

# Deploy Environment

<# Subscription Deploy #>

# Global  sub deploy for @Current - Orchestration
AzDeploy @Current -Prefix ACU1 -TF BICEP:\bicep\00-dp-sub-InitialRG.bicep -SubscriptionDeploy     #<-- Deploys from Pipelines Region 1 - Sample GH
AzDeploy @Current -Prefix AEU2 -TF BICEP:\bicep\00-dp-sub-InitialRG.bicep -SubscriptionDeploy     #<-- Deploys from Pipelines Region 2 - Sample ADO

# Subscription deploy for @Current - Individual layers - This is your Inner Dev Loop
AzDeploy @Current -Prefix ACU1 -TF BICEP:\bicep\sub-RG.bicep -SubscriptionDeploy
AzDeploy @Current -Prefix ACU1 -TF BICEP:\bicep\sub-RBAC.bicep -SubscriptionDeploy

<# ResourceGroup Deploy #>

# RG deploy for @Current - Orchestration
AzDeploy @Current -Prefix ACU1 -TF BICEP:\bicep\01-dp-rg-ALLRG.bicep      #<-- Deploys from Pipelines Region 1 - Sample GH
AzDeploy @Current -Prefix AEU2 -TF BICEP:\bicep\01-dp-rg-ALLRG.bicep      #<-- Deploys from Pipelines Region 2 - Sample ADO

# RG deploy for @Current - Individual layers - This is your Inner Dev Loop - Deploy directly to Sandbox/Test
AzDeploy @Current -Prefix ACU1 -TF BICEP:\bicep\OMS.bicep
AzDeploy @Current -Prefix ACU1 -TF BICEP:\bicep\SA.bicep
AzDeploy @Current -Prefix ACU1 -TF BICEP:\bicep\ACR.bicep
AzDeploy @Current -Prefix ACU1 -TF BICEP:\bicep\AppServicePlan.bicep
AzDeploy @Current -Prefix ACU1 -TF BICEP:\bicep\AppServiceContainer.bicep

# added bonus - Even more precise deployment - Even better inner dev loop
AzDeploy @Current -Prefix ACU1 -TF BICEP:\bicep\SA.bicep                  # Deploy all storage accounts
AzDeploy @Current -Prefix ACU1 -TF BICEP:\bicep\SA.bicep -CN diag         # Deploy only the 'diag' storage account
AzDeploy @Current -Prefix ACU1 -TF BICEP:\bicep\SA.bicep -CN diag1,diag2  # Deploy only the 'diag1' and 'diag2' storage accounts
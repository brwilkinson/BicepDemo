param (
    [string]$Enviro = 'G0',
    [string]$App = 'WEB'
)
import-module -Name "$PSScriptRoot\..\..\release\azSet.psm1" -force
AzSet -Enviro $enviro -App $App

break
# F8 to run individual steps

#############################
# Note this file is here to get to you you started, you can run ALL of this from the command line
# Put that import-module line above in your profile,...then..
# once you know these commands you just run the following in the commandline AzSet -Enviro D3 -App AOA
# Then you can execute most of these from Terminal.
# Everything that works in here or Terminal, also works in a Pipeline.
#############################

# Pre-reqs
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
set-location -path BICEP:\
. BICEP:\prereqs\4-Start-CreateServicePrincipalGH.ps1 @Current -Prefix ACU1 -Environments $Enviro    # D3, P0, G0, G1, S1, T5, P7
. BICEP:\prereqs\4-Start-CreateServicePrincipalGH.ps1 @Current -Prefix AEU2 -Environments $Enviro    # P0, S1, T5, P7

# App pipelines in AZD
. BICEP:\prereqs\4-Start-CreateServicePrincipal.ps1 @Current -Prefix ACU1 -Environments $Enviro      # D3, P0, G0, G1, S1, T5, P7
. BICEP:\prereqs\4-Start-CreateServicePrincipal.ps1 @Current -Prefix AEU2 -Environments $Enviro      # P0, S1, T5, P7

##########################################################
# Deploy Environment

# Global  sub deploy for $env:Enviro
AzDeploy @Current -Prefix ACU1 -TF BICEP:\bicep\00-dp-sub-InitialRG.bicep -SubscriptionDeploy     #<-- Deploys from Pipelines Region 1
AzDeploy @Current -Prefix AEU2 -TF BICEP:\bicep\00-dp-sub-InitialRG.bicep -SubscriptionDeploy     #<-- Deploys from Pipelines Region 2

AzDeploy @Current -Prefix ACU1 -TF BICEP:\bicep\sub-RBAC.bicep -SubscriptionDeploy

# $env:Enviro RG deploy
AzDeploy @Current -Prefix ACU1 -TF BICEP:\bicep\01-dp-rg-ALLRG.bicep      #<-- Deploys from Pipelines Region 1
AzDeploy @Current -Prefix AEU2 -TF BICEP:\bicep\01-dp-rg-ALLRG.bicep      #<-- Deploys from Pipelines Region 2

AzDeploy @Current -Prefix ACU1 -TF BICEP:\bicep\NSG.hub.bicep
AzDeploy @Current -Prefix AEU2 -TF BICEP:\bicep\NSG.hub.bicep

AzDeploy @Current -Prefix ACU1 -TF BICEP:\bicep\NSG.spoke.bicep
AzDeploy @Current -Prefix AEU2 -TF BICEP:\bicep\NSG.spoke.bicep

AzDeploy @Current -Prefix ACU1 -TF BICEP:\bicep\DNSPrivate.bicep
AzDeploy @Current -Prefix ACU1 -TF BICEP:\bicep\VNET.bicep
AzDeploy @Current -Prefix ACU1 -TF BICEP:\templates-base\06-azuredeploy-WAF.json   #todo

AzDeploy @Current -Prefix AEU2 -TF BICEP:\bicep\DNSPrivate.bicep
AzDeploy @Current -Prefix AEU2 -TF BICEP:\bicep\VNET.bicep
AzDeploy @Current -Prefix AEU2 -TF BICEP:\templates-base\06-azuredeploy-WAF.json    #todo

AzDeploy @Current -Prefix ACU1 -TF BICEP:\bicep\OMS.bicep
AzDeploy @Current -Prefix ACU1 -TF BICEP:\templates-base\23-azuredeploy-Dashboard.json    #todo

AzDeploy @Current -Prefix ACU1 -TF BICEP:\bicep\NetworkWatcher.bicep
AzDeploy @Current -Prefix ACU1 -TF BICEP:\bicep\NetworkFlowLogs.bicep

AzDeploy @Current -Prefix AEU2 -TF BICEP:\bicep\NetworkWatcher.bicep
AzDeploy @Current -Prefix AEU2 -TF BICEP:\bicep\NetworkFlowLogs.bicep

AzDeploy @Current -Prefix ACU1 -TF BICEP:\bicep\SA.bicep

AzDeploy @Current -Prefix ACU1 -TF BICEP:\bicep\KV.bicep
AzDeploy @Current -Prefix AEU2 -TF BICEP:\bicep\KV.bicep

AzDeploy @Current -Prefix ACU1 -TF BICEP:\templates-base\09-azuredeploy-APIM.json

AzDeploy @Current -Prefix ACU1 -TF BICEP:\templates-base\02-azuredeploy-FrontDoor.json
AzDeploy @Current -Prefix AEU2 -TF BICEP:\templates-base\02-azuredeploy-FrontDoor.json

AzDeploy @Current -Prefix ACU1 -TF BICEP:\templates-base\14-azuredeploy-AKS.json -FullUpload -vsts

# $env:Enviro AppServers Deploy
AzDeploy @Current -Prefix ACU1 -TF BICEP:\templates-base\05-azuredeploy-VMApp.json -DeploymentName ADPrimary
AzDeploy @Current -Prefix ACU1 -TF BICEP:\templates-base\05-azuredeploy-VMApp.json -DeploymentName ADSecondary
# $env:Enviro AppServers Deploy
AzDeploy @Current -Prefix ACU1 -TF BICEP:\templates-base\05-azuredeploy-VMApp.json -DeploymentName InitialDOP
AzDeploy @Current -Prefix AEU2 -TF BICEP:\templates-base\05-azuredeploy-VMApp.json -DeploymentName InitialDOP

AzDeploy @Current -Prefix ACU1 -TF BICEP:\templates-base\05-azuredeploy-VMApp.json -DeploymentName AppServers
AzDeploy @Current -Prefix ACU1 -TF BICEP:\templates-base\05-azuredeploy-VMApp.json -DeploymentName AppServersLinux

##########################################################
# Stage and Upload DSC Resource Modules for AA
. BICEP:\1-PrereqsToDeploy\5.0-UpdateDSCModulesMain.ps1 -DownloadLatest 0

## these two steps only after 01-azuredeploy-OMS.json has been deployed, which includes the Automation account.

# Using Azure Automation Pull Mode to host configurations - upload DSC Modules, prior to deploying AppServers
. BICEP:\1-PrereqsToDeploy\5.0-UpdateDSCModulesMainAA.ps1 @Current -Prefix ACU1 -AAEnvironment P0
. BICEP:\1-PrereqsToDeploy\5.0-UpdateDSCModulesMainAA.ps1 @Current -Prefix AEU2 -AAEnvironment P0

# upload mofs for a particular configuration, prior to deploying AppServers
AzMofUpload @Current -Prefix ACU1 -AAEnvironment G1 -Roles IMG -NoDomain
AzMofUpload @Current -Prefix ACU1 -AAEnvironment P0 -Roles SQLp,SQLs


# ASR deploy
AzDeploy @Current -Prefix ACU1 -TF BICEP:\templates-base\21-azuredeploy-ASRSetup.json -SubscriptionDeploy -FullUpload
@allowed([
  'AZE2'
  'AZC1'
  'AEU2'
  'ACU1'
])
param Prefix string = 'AZE2'

@allowed([
  'I'
  'D'
  'U'
  'P'
  'S'
  'G'
  'A'
])
param Environment string = 'D'

@allowed([
  '0'
  '1'
  '2'
  '3'
  '4'
  '5'
  '6'
  '7'
  '8'
  '9'
])
param DeploymentID string = '1'
param Stage object
param Extensions object
param Global object
param DeploymentInfo object

@secure()
param vmAdminPassword string

@secure()
param devOpsPat string

@secure()
param sshPublic string

var Deployment = '${Prefix}-${Global.OrgName}-${Global.Appname}-${Environment}${DeploymentID}'
var subscriptionId = subscription().subscriptionId
var VnetID = resourceId('Microsoft.Network/virtualNetworks', '${Deployment}-vn')
var snWAF01Name = 'snWAF01'
var SubnetRefGW = '${VnetID}/subnets/${snWAF01Name}'
var networkId = concat(Global.networkid[0], string((Global.networkid[1] - (2 * int(DeploymentID)))))
var networkIdUpper = concat(Global.networkid[0], string((1 + (Global.networkid[1] - (2 * int(DeploymentID))))))
var OMSworkspaceName = replace('${Deployment}LogAnalytics', '-', '')
var OMSworkspaceID = resourceId('Microsoft.OperationalInsights/workspaces/', OMSworkspaceName)
var appServiceplanInfo = DeploymentInfo.appServiceplanInfo

resource Deployment_asp_appServiceplanInfo_Name 'Microsoft.Web/serverfarms@2019-08-01' = [for item in appServiceplanInfo: if (item.deploy == 1) {
  name: '${Deployment}-asp${item.Name}'
  location: resourceGroup().location
  kind: item.kind
  properties: {
    perSiteScaling: item.perSiteScaling
    maximumElasticWorkerCount: (contains(item, 'maxWorkerCount') ? item.maxWorkerCount : json('null'))
    reserved: item.reserved
    targetWorkerCount: item.skucapacity
  }
  sku: {
    name: item.skuname
    tier: item.skutier
    capacity: item.skucapacity
  }
}]
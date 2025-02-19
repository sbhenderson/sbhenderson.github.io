@description('Azure Region to deploy resources')
param location string = resourceGroup().location // Location for all resources
@description('Unique suffix string for identification')
param webAppName string = uniqueString(resourceGroup().id) // Generate unique String for web app name
@description('App Service Plan SKU. Be aware that deploying to a production sku from the Bicep doesn`t seem to work. Use the Azure Portal or az cli command to promote it to a production sku.')
@allowed([
  'B3'
  'P1v3'
  'P2v3'
  'P3v3'
])
param appServicePlanSku string = 'B3' // The SKU of App Service Plan

var appServicePlanName = toLower('AppServicePlan-${webAppName}')
var webSiteName = toLower('appservice-${webAppName}')
var storageAccountName = toLower('storage-${webAppName}')
var template='c2VydmljZXM6CiAgdHJhZWZpazoKICAgIGltYWdlOiBjdXN0b21UcmFlZmlrOmxhdGVzZXQKICAgIHJlc3RhcnQ6IHVubGVzcy1zdG9wcGVkCiAgICBwb3J0czoKICAgICAgLSAiODA6ODAiCiAgICAgIC0gIjQ0Mzo0NDMiCiAgcmFiYml0bXE6CiAgICBpbWFnZTogcmFiYml0bXE6bWFuYWdlbWVudCAgICAKICAgIGhvc3RuYW1lOiByYWJiaXRtcTEKICAgIHJlc3RhcnQ6IHVubGVzcy1zdG9wcGVkCiAgICB2b2x1bWVzOgogICAgICAtIHJhYmJpdG1xOi92YXIvbGliL3JhYmJpdG1xCiAgZGF0YWJhc2U6CiAgICBpbWFnZTogZGF0YWJhc2UtZW5naW5lOmxhdGVzdAogICAgcmVzdGFydDogdW5sZXNzLXN0b3BwZWQKICAgIHZvbHVtZXM6CiAgICAgIC0gZGF0YWJhc2VkYXRhOi92YXIvbGliL3lvdXJlbmdpbmVkYXRhCiAgYXBwbGljYXRpb246CiAgICBpbWFnZTogeW91ci1hcHBsaWNhdGlvbjpsYXRlc3QKICAgIHJlc3RhcnQ6IHVubGVzcy1zdG9wcGVkCiAgICBkZXBlbmRzX29uOgogICAgICAtIHJhYmJpdG1xCiAgICAgIC0gZGF0YWJhc2UKICAgIHZvbHVtZXM6CiAgICAgIC0gZGF0YTovZGF0YQogIAp2b2x1bWVzOgogIHJhYmJpdG1xOiAjYnV0IEknbSBub3QgcGVyc2lzdGluZyBpbiB0aGlzIHNldHVwCiAgZGF0YWJhc2VkYXRhOgogIGRhdGE6'

resource storageAccount 'Microsoft.Storage/storageAccounts@2023-05-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    publicNetworkAccess: 'Enabled'
    supportsHttpsTrafficOnly: true
    accessTier: 'Hot'
    allowSharedKeyAccess: true
    largeFileSharesState: 'Enabled'
    networkAcls: {
      resourceAccessRules: []
      bypass: 'Logging, Metrics, AzureServices'
      virtualNetworkRules: []
      ipRules: [
      ]
      defaultAction: 'Allow'
    }
    encryption: {
      requireInfrastructureEncryption: false
      services: {
        file: {
          keyType: 'Account'
          enabled: true
        }
        blob: {
          keyType: 'Account'
          enabled: true
        }
      }
      keySource: 'Microsoft.Storage'
    }
  }
}
resource storageAccountFileServices 'Microsoft.Storage/storageAccounts/fileServices@2023-05-01' = {
  parent: storageAccount
  name: 'default'
  properties: {
    protocolSettings: {
      smb: {}
    }
    cors: {
      corsRules: []
    }
    shareDeleteRetentionPolicy: {
      enabled: true
      days: 14
    }
  }
}

resource storageAccount_1 'Microsoft.Storage/storageAccounts/fileServices/shares@2023-05-01' = {
  parent: storageAccountFileServices
  name: 'data'
  properties: {
    accessTier: 'Hot'
    shareQuota: 102400
    enabledProtocols: 'SMB'
  }
}
resource storageAccount_2 'Microsoft.Storage/storageAccounts/fileServices/shares@2023-05-01' = {
  parent: storageAccountFileServices
  name: 'databasedata'
  properties: {
    accessTier: 'Hot'
    shareQuota: 102400
    enabledProtocols: 'SMB'
  }
}

resource appServicePlan 'Microsoft.Web/serverfarms@2023-12-01' = {
  name: appServicePlanName
  location: location
  kind: 'linux'
  properties: {
    perSiteScaling: false
    elasticScaleEnabled: false
    maximumElasticWorkerCount: 1
    isSpot: false
    reserved: true
    isXenon: false
    hyperV: false
    targetWorkerCount: 0
    targetWorkerSizeId: 0
    zoneRedundant: false
  }
  sku: {
    name: appServicePlanSku
  }
}

resource appService 'Microsoft.Web/sites@2023-12-01' = {
  name: webSiteName
  location: location
  kind: 'app,linux,container'
  properties: {
    serverFarmId: appServicePlan.id
    redundancyMode: 'None'
    siteConfig: {
      numberOfWorkers: 1
      linuxFxVersion: 'COMPOSE|${template}'
      alwaysOn: true
      http20Enabled: true      
      azureStorageAccounts:{
        data: {
          type: 'AzureFiles'
          accountName: storageAccountName
          shareName: 'data'
          mountPath: '/data'
          accessKey: storageAccount.listKeys().keys[0].value
          protocol: 'Smb'
        }
        databasedata: {
          type: 'AzureFiles'
          accountName: storageAccountName
          shareName: 'databasedata'
          mountPath: '/databasedata'
          protocol: 'Smb'
          accessKey: storageAccount.listKeys().keys[0].value
        }
      }
      appSettings: [
        {
          name: 'DOCKER_ENABLE_CI'
          value: 'true'
        }
        {
          name: 'DOCKER_REGISTRY_SERVER_PASSWORD'
          value: 'password'
        }
        {
          name: 'DOCKER_REGISTRY_SERVER_URL'
          value: 'https://registry.azurecr.io'
        }
        {
          name: 'DOCKER_REGISTRY_SERVER_USERNAME'
          value: 'username'
        }
        {
          name: 'WEBSITE_HTTPLOGGING_RETENTION_DAYS'
          value: '10'
        }
        {
          name: 'WEBSITES_ENABLE_APP_SERVICE_STORAGE'
          value: 'false'//this relates to the /home area
        }
      ]
    }    
  }
  dependsOn: [
    storageAccount_1
    storageAccount_2
  ]
}

@description('The name of the Synapse Workspace.')
param synapseWorkspaceName string

@description('The name of the default storage account for the Synapse Workspace.')
param storageAccountName string

@description('The location for the Synapse Workspace and storage resources.')
param location string = 'westus'

// Create Storage Account
resource storageAccount 'Microsoft.Storage/storageAccounts@2023-05-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: 'Standard_RAGRS'
  }
  kind: 'StorageV2'
  properties: {
    allowCrossTenantReplication: false
    minimumTlsVersion: 'TLS1_2'
    allowBlobPublicAccess: false
    isHnsEnabled: true
    supportsHttpsTrafficOnly: true
    encryption: {
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
    accessTier: 'Hot'
  }
}

// Blob Services for Storage Account
resource blobService 'Microsoft.Storage/storageAccounts/blobServices@2023-05-01' = {
  parent: storageAccount
  name: 'default'
  properties: {
    cors: {
      corsRules: []
    }
    deleteRetentionPolicy: {
      allowPermanentDelete: false
      enabled: false
    }
  }
}

// Synapse Workspace
resource synapseWorkspace 'Microsoft.Synapse/workspaces@2021-06-01' = {
  name: synapseWorkspaceName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    defaultDataLakeStorage: {
      resourceId: storageAccount.id
      accountUrl: 'https://${storageAccount.name}.dfs.core.windows.net'
      filesystem: 'default'
    }
    sqlAdministratorLogin: 'sqladminuser'
    publicNetworkAccess: 'Enabled'
    azureADOnlyAuthentication: false
    trustedServiceBypassEnabled: true
  }
}

resource firewallRule 'Microsoft.Synapse/workspaces/firewallRules@2021-06-01' = {
  parent: synapseWorkspace
  name: 'allowAll'
  properties: {
    startIpAddress: '0.0.0.0'
    endIpAddress: '255.255.255.255'
  }
}

resource sparkPool 'Microsoft.Synapse/workspaces/bigDataPools@2021-06-01' = {
  parent: synapseWorkspace
  name: 'default'
  location: location
  properties: {
    nodeSize: 'Small' // Adjust node size if needed (e.g., Medium, Large)
    nodeSizeFamily: 'MemoryOptimized'
    autoScale: {
      enabled: false
    }
    nodeCount: 3
    autoPause: {
      enabled: true
      delayInMinutes: 15 // Auto-pause delay
    }
    sparkVersion: '3.4' // Adjust the Spark version as needed
    sessionLevelPackagesEnabled: false
    dynamicExecutorAllocation: {
      enabled: false
    }
  }
}

// Outputs
output storageAccountId string = storageAccount.id
output synapseWorkspaceId string = synapseWorkspace.id

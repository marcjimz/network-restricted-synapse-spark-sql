@description('Name of the SQL Virtual Machine.')
param sqlVmName string

@description('Admin username for the SQL Virtual Machine.')
param sqlAdminUsername string

@description('Admin password for the SQL Virtual Machine.')
@secure()
param sqlAdminPassword string

@description('The location into which the SQL Virtual Machine should be deployed.')
param location string

@description('Resource ID of the subnet where the SQL Virtual Machine will be deployed.')
param subnetId string

@description('Resource ID of the public IP address to associate with the SQL Virtual Machine.')
param publicIpId string

@description('Size of the Virtual Machine.')
param vmSize string = 'Standard_B2s'

param allowedDestinationPorts array = [
  1433 // SQL Server port
]

resource networkSecurityGroup 'Microsoft.Network/networkSecurityGroups@2020-11-01' = {
  name: '${sqlVmName}-nsg'
  location: location
  properties: {
    securityRules: [
      // Allow traffic from Azure services
      {
        name: 'AllowAzureServices'
        properties: {
          priority: 100
          direction: 'Inbound'
          access: 'Allow'
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRanges: allowedDestinationPorts
          sourceAddressPrefix: 'AzureCloud' // Service tag for Azure services
          destinationAddressPrefix: '*'
        }
      }
      // Deny all other inbound traffic
      {
        name: 'DenyAllInbound'
        properties: {
          priority: 200
          direction: 'Inbound'
          access: 'Deny'
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
        }
      }
    ]
  }
}

resource networkInterface 'Microsoft.Network/networkInterfaces@2022-11-01' = {
  name: '${sqlVmName}-nic'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          subnet: {
            id: subnetId
          }
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: publicIpId
          }
        }
      }
    ]
    networkSecurityGroup: {
      id: networkSecurityGroup.id
    }
  }
}

resource virtualMachine 'Microsoft.Compute/virtualMachines@2023-09-01' = {
  name: sqlVmName
  location: location
  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }
    storageProfile: {
      imageReference: {
        publisher: 'MicrosoftSQLServer'
        offer: 'sql2019-ws2022'
        sku: 'standard' // Adjust as needed (e.g., Standard, Enterprise)
        version: 'latest'
      }
      osDisk: {
        createOption: 'FromImage'
      }
    }
    osProfile: {
      computerName: sqlVmName
      adminUsername: sqlAdminUsername
      adminPassword: sqlAdminPassword
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: networkInterface.id
        }
      ]
    }
  }
}

resource sqlVirtualMachine 'Microsoft.SqlVirtualMachine/sqlVirtualMachines@2023-01-01-preview' = {
  name: sqlVmName
  location: location
  properties: {
    virtualMachineResourceId: virtualMachine.id
    sqlManagement: 'Full'
    sqlServerLicenseType: 'PAYG'
    leastPrivilegeMode: 'Enabled'
    serverConfigurationsManagementSettings: {
      sqlConnectivityUpdateSettings: {
        connectivityType: 'PUBLIC' // Can be 'PRIVATE' for internal-only connections
        port: 1433
        sqlAuthUpdateUserName: sqlAdminUsername
        sqlAuthUpdatePassword: sqlAdminPassword
      }
    }
  }
}

output vmName string = virtualMachine.name
output publicIpId string = publicIpId

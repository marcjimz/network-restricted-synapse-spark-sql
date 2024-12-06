// Define the parameters for the deployment
@description('Name of the virtual network.')
param vnetName string = 'CoreVnet'

@description('Name of the subnet to be created within the VNet.')
param subnetName string = 'default'

@description('Address prefix for the virtual network.')
param vnetAddressPrefix string = '10.1.0.0/16'

@description('Address prefix for the subnet.')
param subnetAddressPrefix string = '10.1.0.0/24'

@description('Name of the public IP address resource.')
param publicIpName string = 'core-vnet-ip'

@description('The location into which the resources should be deployed.')
param location string = resourceGroup().location

// Create the virtual network
resource vnet 'Microsoft.Network/virtualNetworks@2023-11-01' = {
  name: vnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetAddressPrefix
      ]
    }
    subnets: [
      {
        name: subnetName
        properties: {
          addressPrefix: subnetAddressPrefix
        }
      }
    ]
  }
}

// Get the subnet reference
resource subnet 'Microsoft.Network/virtualNetworks/subnets@2023-11-01' existing = {
  parent: vnet
  name: subnetName
}

// Create a public IP address
resource publicIp 'Microsoft.Network/publicIPAddresses@2023-11-01' = {
  name: publicIpName
  location: location
  sku: {
    name: 'Basic'
  }
  properties: {
    publicIPAllocationMethod: 'Dynamic'
  }
}

// Outputs
output vnetId string = vnet.id
output subnetId string = subnet.id
output publicIpAddressId string = publicIp.id

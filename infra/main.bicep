// Execute this main file to deploy a secure environment with a SQL VM, Synapse Workspace, and related resources.

// Parameters
@minLength(2)
@maxLength(12)
@description('Name for the deployment prefix to derive the names of dependent resources.')
param deploymentName string = 'demo'

@description('The location into which the resources should be deployed.')
param location string = resourceGroup().location

@description('Set of tags to apply to all resources.')
param tags object = {}

@description('Resource name of the virtual network to deploy the resources into.')
param vnetName string

@description('Resource group name of the virtual network to deploy the resources into.')
param vnetRgName string

@description('Name of the subnet to deploy into.')
param subnetName string

@description('The admin username for the SQL VM.')
param sqlAdminUsername string

@description('The admin password for the SQL VM.')
@secure()
param sqlAdminPassword string

// Variables
var name = toLower('${deploymentName}')
var uniqueSuffix = substring(uniqueString(resourceGroup().id), 0, 7)

var vnetResourceId = '/subscriptions/${subscription().subscriptionId}/resourceGroups/${vnetRgName}/providers/Microsoft.Network/virtualNetworks/${vnetName}'
var subnetResourceId = '${vnetResourceId}/subnets/${subnetName}'

// Deploy the network (VNet, NSG, and subnet)
module network 'dependencies/network.bicep' = {
  name: 'network-${name}-${uniqueSuffix}-deployment'
  params: {
    location: location
    vnetName: 'CoreVnet-${name}' // Customize the VNet name
    subnetName: 'default-${name}' // Customize the Subnet name
    vnetAddressPrefix: '10.1.0.0/16' // Example address space for VNet
    subnetAddressPrefix: '10.1.0.0/24' // Example address prefix for Subnet
    publicIpName: 'core-vnet-ip-${name}' // Customize the Public IP name
  }
}

// Deploy the SQL Virtual Machine
module sqlVm 'dependencies/sqlvm.bicep' = {
  name: 'sqlvm-${name}-${uniqueSuffix}-deployment'
  params: {
    location: location
    sqlVmName: 'sqlvm-${name}' // Customize the SQL VM name
    sqlAdminUsername: sqlAdminUsername
    sqlAdminPassword: sqlAdminPassword
    subnetId: network.outputs.subnetId // Reference the Subnet ID from the network module
    publicIpId: network.outputs.publicIpAddressId // Reference the Public IP ID from the network module
  }
}

module synapse 'dependencies/synapseworkspace.bicep' = {
  name: 'synapse-${name}-${uniqueSuffix}-deployment'
  params: {
    synapseWorkspaceName: 'synapse-${name}-${uniqueSuffix}'
    storageAccountName: 'synapseworkspace${uniqueSuffix}'
    location: location
  }
}

// Outputs
output vnetId string = network.outputs.vnetId
output sqlVmName string = sqlVm.outputs.vmName
output synapseWorkspaceId string = synapse.outputs.synapseWorkspaceId

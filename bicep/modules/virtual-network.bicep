@description('Location for the network.')
param location string = resourceGroup().location

@description('Base name for the network.')
param name string = resourceGroup().name

var dnsLabelPrefix = toLower(name)
var addressPrefix = '10.0.0.0/16'
var virtualNetworkName = name
var networkSecurityGroupName = '${name}-nsgAllowRemoting'

var subnetName = '${name}-subnet'

var subnets = [
  {
    name: '${subnetName}-jumpbox'
    properties: {
      addressPrefix: '10.0.0.0/24'
      networkSecurityGroup: {
        id: networkSecurityGroup.id
      }
    }
  }
  {
    name: '${subnetName}-internal'
    properties: {
      addressPrefix: '10.0.1.0/24'
      privateEndpointNetworkPolicies: 'Disabled'
      privateLinkServiceNetworkPolicies: 'Enabled'
    }
  }
]

resource networkSecurityGroup 'Microsoft.Network/networkSecurityGroups@2022-07-01' = {
  name: networkSecurityGroupName
  location: location
  properties: {
    securityRules: [
      {
        name: 'RemoteConnection'
        properties: {
          description: 'Allow SSH'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '22'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 100
          direction: 'Inbound'
        }
      }
    ]
  }
}

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2022-07-01' = {
  name: virtualNetworkName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        addressPrefix
      ]
    }
    subnets: subnets
  }
}

output virtualNetworkName string = virtualNetwork.name
output subnets array = virtualNetwork.properties.subnets
output dnsLabelPrefix string = dnsLabelPrefix
output networkSercurityGroupId string = networkSecurityGroup.id

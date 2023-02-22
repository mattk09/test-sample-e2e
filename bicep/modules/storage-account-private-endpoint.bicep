@description('Base name for the storage account.')
param name string = resourceGroup().name

@description('Location for the storage account.')
param location string = resourceGroup().location

@description('Existing virtual network name to use for a private endpoint.')
param virtualNetworkName string

@description('Existing storage account name to use for a private endpoint.')
param storageAccountName string


var blobPrivateDnsZoneName = 'privatelink.blob.${environment().suffixes.storage}'
var tablePrivateDnsZoneName = 'privatelink.table.${environment().suffixes.storage}'

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2022-07-01' existing = {
  name: virtualNetworkName
}

resource storageAccount 'Microsoft.Storage/storageAccounts@2022-09-01' existing = {
  name: storageAccountName
}

resource privateBlobEndpoint 'Microsoft.Network/privateEndpoints@2022-07-01' = {
  name: '${name}-privateBlobEndpoint'
  location: location
  properties: {
    subnet: {
      id: virtualNetwork.properties.subnets[1].id
    }
    privateLinkServiceConnections: [
      {
        name: '${name}-blob-ServiceConnection'
        properties: {
          privateLinkServiceId: storageAccount.id
          groupIds: [
            'blob'
          ]
          privateLinkServiceConnectionState: {
            status: 'Approved'
            description: 'Auto-Approved'
            actionsRequired: 'None'
          }
        }
      }
    ]
  }
}

resource privateTableEndpoint 'Microsoft.Network/privateEndpoints@2022-07-01' = {
  name: '${name}-privateTableEndpoint'
  location: location
  properties: {
    subnet: {
      id: virtualNetwork.properties.subnets[1].id
    }
    privateLinkServiceConnections: [
      {
        name: '${name}-table-ServiceConnection'
        properties: {
          privateLinkServiceId: storageAccount.id
          groupIds: [
            'table'
          ]
          privateLinkServiceConnectionState: {
            status: 'Approved'
            description: 'Auto-Approved'
            actionsRequired: 'None'
          }
        }
      }
    ]
  }
}

resource blobPrivateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: blobPrivateDnsZoneName
  location: 'global'
}

resource tablePrivateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: tablePrivateDnsZoneName
  location: 'global'
}

resource blobPrivateDnsZoneLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  parent: blobPrivateDnsZone
  name: '${virtualNetwork.name}-blob-link'
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: virtualNetwork.id
    }
  }
}

resource tablePrivateDnsZoneLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  parent: tablePrivateDnsZone
  name: '${virtualNetwork.name}-table-link'
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: virtualNetwork.id
    }
  }
}

resource privateBlobEndpointDns 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2022-07-01' = {
  name: '${privateBlobEndpoint.name}/blob-PrivateDnsZoneGroup'
  properties:{
    privateDnsZoneConfigs: [
      {
        name: blobPrivateDnsZoneName
        properties:{
          privateDnsZoneId: blobPrivateDnsZone.id
        }
      }
    ]
  }
}


resource privateTableEndpointDns 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2022-07-01' = {
  name: '${privateTableEndpoint.name}/blob-PrivateDnsZoneGroup'
  properties:{
    privateDnsZoneConfigs: [
      {
        name: blobPrivateDnsZoneName
        properties:{
          privateDnsZoneId: blobPrivateDnsZone.id
        }
      }
      {
        name: tablePrivateDnsZoneName
        properties:{
          privateDnsZoneId: tablePrivateDnsZone.id
        }
      }
    ]
  }
}

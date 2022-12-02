param location string

param storageAccountName string
param storageAccountAllowedSubnets array = []

@allowed([
  'Standard_LRS'
  'Standard_GRS'
])
param storageAccountSku string

param vnetIntegrated bool
param virtualNetworkName string = ''
param virtualNetworkResourceGroup string = ''

//// Deployment ////

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2021-02-01' existing = if(vnetIntegrated) {
  name: virtualNetworkName
  scope: resourceGroup(virtualNetworkResourceGroup)
}

resource virtualNetworkSubnets 'Microsoft.Network/virtualNetworks/subnets@2021-02-01' existing = [for subnet in storageAccountAllowedSubnets : if(vnetIntegrated) {
  name: subnet
  parent: virtualNetwork
}]

resource storageAccount 'Microsoft.Storage/storageAccounts@2021-04-01' = {
  name: storageAccountName
  location: location
  kind: 'StorageV2'
  sku: {
    name: storageAccountSku
  }
  properties: {
    supportsHttpsTrafficOnly: true
    minimumTlsVersion: 'TLS1_2'
    networkAcls: {
      defaultAction: bool(vnetIntegrated) ? 'Deny' : 'Allow'
      virtualNetworkRules: [for i in range(0, length(storageAccountAllowedSubnets)): {
        id: virtualNetworkSubnets[i].id
      }]
    }
  }
}

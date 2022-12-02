param privateDnsZoneName string
param targetVnets array

resource privatezone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  location: 'Global'
  name: privateDnsZoneName
}

resource vnets 'Microsoft.Network/virtualNetworks@2021-05-01' existing = [for vnet in targetVnets: {
  name: vnet.name
}]

resource vnetlink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = [for (vnet, index) in targetVnets : if (!empty(targetVnets)){
  parent: privatezone
  name: '${vnet.name}-link'
  location: 'Global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: vnets[index].id
    }
  }
}]

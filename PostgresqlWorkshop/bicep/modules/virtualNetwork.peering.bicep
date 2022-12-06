param virtualNetworkName string
param remoteVirtualNetworkName string

param peeringName string
param allowVirtualNetworkAccess bool
param allowForwardedTraffic bool
param allowGatewayTransit bool
param useRemoteGateways bool

resource vnet 'Microsoft.Network/virtualNetworks@2021-03-01' existing = {
  name: virtualNetworkName
}

resource remotevnet 'Microsoft.Network/virtualNetworks@2021-03-01' existing = {
  name: remoteVirtualNetworkName
}
resource peering 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2021-03-01' = {
  parent: vnet
  name: peeringName
  properties: {
    remoteVirtualNetwork: {
      id: remotevnet.id
    }
    allowVirtualNetworkAccess: allowVirtualNetworkAccess
    allowForwardedTraffic: allowForwardedTraffic
    allowGatewayTransit: allowGatewayTransit
    useRemoteGateways: useRemoteGateways
  }
}

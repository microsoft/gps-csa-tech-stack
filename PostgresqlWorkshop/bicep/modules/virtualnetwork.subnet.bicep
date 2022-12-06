param virtualNetworkName string
param subnets array


resource virtualNetwork 'Microsoft.Network/virtualNetworks@2021-05-01' existing = {
  name: virtualNetworkName
}

resource nsg 'Microsoft.Network/networkSecurityGroups@2021-03-01' existing = [ for subnet in subnets: if (!empty(subnet.networkSecurityGroupName)) {
  name: subnet.networkSecurityGroupName
  scope: resourceGroup(subnet.networkSecurityGroupNameResourceGroupName)
}]

resource subnet 'Microsoft.Network/virtualnetworks/subnets@2021-05-01' = [ for (subnet, index) in subnets: {
  parent: virtualNetwork
  name: subnet.name
  properties: {
    addressPrefix: subnet.addressPrefix
    delegations: contains(subnet, 'delegations') ? subnet.delegations : null
    networkSecurityGroup: contains(subnet, 'networkSecurityGroupName') ? {
      id: nsg[index].id
    } : null
    privateEndpointNetworkPolicies: contains(subnet, 'privateEndpointNetworkPolicies') ? subnet.privateEndpointNetworkPolicies : null
    privateLinkServiceNetworkPolicies: contains(subnet, 'privateLinkServiceNetworkPolicies') ? subnet.privateLinkServiceNetworkPolicies : null
  }
}]

param virtualNetworkName string
param addressPrefixes array
param dnsServers array = []
param subnets array

resource nsg 'Microsoft.Network/networkSecurityGroups@2021-03-01' existing = [ for subnet in subnets: if (contains(subnet, 'networkSecurityGroupName')) {
  name: subnet.networkSecurityGroupName
  scope: resourceGroup(subnet.networkSecurityGroupResourceGroupName)
}]

resource vnet 'Microsoft.Network/virtualNetworks@2021-02-01' = {
  name: virtualNetworkName
  location: resourceGroup().location
  properties: {
    addressSpace: {
      addressPrefixes: addressPrefixes
    }
    dhcpOptions: {
      dnsServers: !empty(dnsServers) ? dnsServers : []
    }
    subnets: [ for (subnet, index) in subnets: {
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
  }
}

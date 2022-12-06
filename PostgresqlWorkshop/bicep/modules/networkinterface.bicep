param location string

// Virtual Network
param vnetName string
param subnetName string

// Load Balancer
param isLoadBalanced string
param loadBalancerName string = ''
param backendPoolName string = ''

// Public IP
param publicIpAddressName string = ''

// Virtual Machine
param vmName string

// Nic
param enableAcceleratedNetworking bool
param enableIPForwarding bool = false
@allowed([
  'Dynamic'
  'Static'
])
param privateIPAllocationMethod string
param privateIPAddress string

resource vnet 'Microsoft.Network/virtualNetworks@2021-03-01' existing = {
  name: vnetName
}

resource subnet 'Microsoft.Network/virtualNetworks/subnets@2021-03-01' existing = {
  parent: vnet
  name: subnetName
}

resource loadBalancer 'Microsoft.Network/loadBalancers@2021-03-01' existing = if (bool(isLoadBalanced)) {
  name: loadBalancerName
}

resource publicIp 'Microsoft.Network/publicIPAddresses@2021-05-01' existing = {
  name: publicIpAddressName
}

resource nic 'Microsoft.Network/networkInterfaces@2021-03-01' = {
  name: '${vmName}-nic'
  location: location
  properties: {
    enableAcceleratedNetworking: enableAcceleratedNetworking
    enableIPForwarding: enableIPForwarding
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          primary: true
          privateIPAllocationMethod: privateIPAllocationMethod
          privateIPAddress: privateIPAllocationMethod == 'Static' ? privateIPAddress : null
          publicIPAddress: {
            id: !empty(publicIpAddressName) ? publicIp.id : null
          }
          privateIPAddressVersion: 'IPv4'
          subnet: {
            id: subnet.id
          }
          loadBalancerBackendAddressPools: bool(isLoadBalanced) ? [
            {
              id: '${loadBalancer.id}/backendAddressPools/${backendPoolName}'
            }
          ] : []
        }
      }
    ]
  }
}

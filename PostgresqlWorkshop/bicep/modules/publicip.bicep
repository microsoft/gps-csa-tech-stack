param location string
param name string
@allowed([
  'Standard'
  'Basic'
])
param skuName string
@allowed([
  'Regional'
  'Global'
])
param skuTier string
@allowed([
  'Static'
  'Dynamic'
])
param publicIPAllocationMethod string

resource publicip 'Microsoft.Network/publicIPAddresses@2021-05-01' = {
  name: '${name}-ip'
  location: location
  sku: {
    name: skuName
    tier: skuTier
  }
  properties:{
    publicIPAddressVersion: 'IPv4'
    publicIPAllocationMethod: publicIPAllocationMethod
  }
}

output publicIpAddress string = publicip.properties.ipAddress

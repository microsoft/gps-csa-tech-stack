param location string
param name string
param securityRules array

resource nsg 'Microsoft.Network/networkSecurityGroups@2021-05-01' = {
  name: name
  location: location
  properties: {
    securityRules: [for securityRule in securityRules: {
      name: securityRule.name
      properties: {
        protocol: securityRule.protocol
        direction: securityRule.direction
        access: securityRule.access
        priority:securityRule.priority
        sourceAddressPrefix: securityRule.sourceAddressPrefix
        sourceAddressPrefixes: securityRule.sourceAddressPrefixes
        sourcePortRange: securityRule.sourcePortRange
        sourcePortRanges: securityRule.sourcePortRanges
        destinationAddressPrefix: securityRule.destinationAddressPrefix
        destinationAddressPrefixes: securityRule.destinationAddressPrefixes
        destinationPortRange: securityRule.destinationPortRange
        destinationPortRanges: securityRule.destinationPortRanges
        description: securityRule.description
      }
    }]
  }
}

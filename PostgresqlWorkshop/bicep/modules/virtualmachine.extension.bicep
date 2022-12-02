param vmName string
param extensionName string
param location string = resourceGroup().location
param publisher string
param type string
param typeHandlerVersion string
param autoUpgradeMinorVersion bool
param forceUpdateTag string = ''
param settings object = {}
@secure()
param protectedSettings object = {}
param supressFailures bool = false
param enableAutomaticUpgrade bool


resource extension 'Microsoft.Compute/virtualMachines/extensions@2021-11-01' = {
  name: '${vmName}/${extensionName}'
  location: location
  properties: {
    publisher: publisher
    type: type
    typeHandlerVersion: typeHandlerVersion
    autoUpgradeMinorVersion: autoUpgradeMinorVersion
    enableAutomaticUpgrade: enableAutomaticUpgrade
    forceUpdateTag: !empty(forceUpdateTag) ? forceUpdateTag : null
    settings: !empty(settings) ? settings : null
    protectedSettings: !empty(protectedSettings) ? protectedSettings : null
    suppressFailures: supressFailures
  }
}

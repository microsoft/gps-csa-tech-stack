// Virtual Machine
param vmName string
param zone string
param vmSize string
param imagePublisher string
param imageOffer string
param imageSku string
@allowed([
  'Windows'
  'Linux'
])
param osType string
@allowed([
  'Premium_LRS'
  'Standard_LRS'
  'StandardSSD_LRS'
])
param storageSku string
param adminUsername string
@secure()
param adminPassword string

resource nic 'Microsoft.Network/networkInterfaces@2021-03-01' existing = {
  name: '${vmName}-nic'
}

resource vm 'Microsoft.Compute/virtualMachines@2021-07-01' = {
  name: vmName
  location: resourceGroup().location
  zones: !empty(zone) ? [
    zone
  ] : []
  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }
    storageProfile: {
      imageReference: {
        publisher: imagePublisher
        offer: imageOffer
        sku: imageSku
        version: 'latest'
      }
      osDisk: {
        createOption: 'FromImage'
        osType: osType
        name: '${vmName}-osdisk'
        caching: 'ReadWrite'
        managedDisk: {
          storageAccountType: storageSku
        }
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: nic.id
        }
      ]
    }
    osProfile:  osType == 'Windows' ? {
      computerName: vmName
      adminUsername: adminUsername
      adminPassword: adminPassword
      windowsConfiguration: {
        enableAutomaticUpdates: true
        provisionVMAgent: true
        patchSettings: {
          enableHotpatching: false
          patchMode: 'AutomaticByOS'
        }
      }
    } : {
      computerName: vmName
      adminUsername: adminUsername
      adminPassword: adminPassword
    }
  }
}

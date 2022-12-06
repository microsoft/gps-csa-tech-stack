
resource "azurerm_resource_group" "hdrg" {
  name     = "hdrg"
  location = "eastasia"
}

module "hd-vnet" {
  source     = "../modules/vnet"
  vnetName   = "hdvnet"
  region     = azurerm_resource_group.hdrg.location
  rgName     = azurerm_resource_group.hdrg.name
  subnetName = "hdsubnet"

  depends_on = [
    azurerm_resource_group.hdrg,
  ]
}


module "hd-master" {
  source       = "../modules/vmVnet"
  vmNamePrefix = "hdmaster"
  vmcount      = 2
  vnetName     = module.hd-vnet.vnetName
  vnetRG       = azurerm_resource_group.hdrg.name
  subnetName   = module.hd-vnet.subnetName
  rgLocation   = azurerm_resource_group.hdrg.location
  rgName       = azurerm_resource_group.hdrg.name
  public_ip    = true
  spot         = true
  kvName       = "kvexample888"
  kvRG         = "exampleRG"
  # kvLocation = "eastasia"
  kvKeyName = "pubkey-test"
  vmSize    = "Standard_D4S_v3"

  depends_on = [
    module.hd-vnet,
    azurerm_resource_group.hdrg,
  ]
}

module "hd-dn-vmss1" {
  source       = "../modules/vmssVnet"
  rgLocation   = azurerm_resource_group.hdrg.location
  rgName       = azurerm_resource_group.hdrg.name
  spot         = "true"
  vmcount      = 2
  vmNamePrefix = "hd-dn"
  vmSize       = "Standard_D4s_v3"
  vnetName     = module.hd-vnet.vnetName
  subnetName   = module.hd-vnet.subnetName
  vnetRG       = module.hd-vnet.vnetRG
  kvName       = "kvexample888"
  kvRG         = "exampleRG"
  # kvLocation = "eastasia"
  kvKeyName   = "pubkey-test"
  healthPort  = "22"
healthProbeProtocol = "tcp"
healthProbePath = "/"

  depends_on = [
    module.hd-vnet,
    azurerm_resource_group.hdrg
  ]
}
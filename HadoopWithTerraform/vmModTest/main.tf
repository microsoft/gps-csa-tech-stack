
#创建资源组
resource "azurerm_resource_group" "hdrg" {
  name     = "testrg"
  location = "eastasia"
}

#引用vnet模块创建VNet和subnet
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


#创建多台虚机
module "testvm" {
  source       = "../modules/vmVnet"
  vmNamePrefix = "testvm"
  #指定虚机的数目
  vmcount      = 2
  vnetName     = module.hd-vnet.vnetName
  vnetRG       = azurerm_resource_group.hdrg.name
  subnetName   = module.hd-vnet.subnetName
  rgLocation   = azurerm_resource_group.hdrg.location
  rgName       = azurerm_resource_group.hdrg.name
  #是否创建公网IP
  public_ip    = true
  #是否为Spot实例
  spot         = true
  # image_offer = "0001-com-ubuntu-server-focal"
  # image_publisher = "Canonical"
  # image_sku = "20_04-lts"
  kvName       = "kvexample888"
  kvRG         = "exampleRG"
  kvKeyName = "pubkey-test"
  vmSize    = "Standard_D2S_v3"

  depends_on = [
    module.hd-vnet,
    azurerm_resource_group.hdrg,
  ]
}

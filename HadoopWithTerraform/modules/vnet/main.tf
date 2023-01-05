
data "azurerm_resource_group" "rg" {
  name = var.rgName
}

# Create virtual network
resource "azurerm_virtual_network" "modVnet" {
  name                = var.vnetName
  address_space       = [var.addressSpace]
  location            = var.region
  resource_group_name = data.azurerm_resource_group.rg.name
}

# Create subnet
resource "azurerm_subnet" "modSubnet" {
  name                 = var.subnetName
  resource_group_name  = data.azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.modVnet.name
  address_prefixes     = [var.subnetAddressSpace]
}

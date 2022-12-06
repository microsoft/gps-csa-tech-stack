output "vnetName" {
  value = azurerm_virtual_network.modVnet.name
}
  
output "subnetName" {
  value = azurerm_subnet.modSubnet.name
}

output "vnetRG" {
  value = azurerm_virtual_network.modVnet.resource_group_name
}
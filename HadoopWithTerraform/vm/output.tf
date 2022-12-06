output "resource_group_name" {
  value = azurerm_resource_group.rg.name
}

output "public_ip_address" {
  value = azurerm_linux_virtual_machine.myterraformvm.public_ip_address
}

# output "tls_private_key" {
#   value     = azurerm_key_vault.kvexample.secrectsprivate_key_pem
#   sensitive = true
# }
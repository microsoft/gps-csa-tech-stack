# output "resource_group_name" {
#   value = azurerm_resource_group.rg.name
# }

output "instances" {
  value = azurerm_linux_virtual_machine_scale_set.vmssHD.instances
}
# output "tls_private_key" {
#   value     = azurerm_key_vault.kvexample.secrectsprivate_key_pem
#   sensitive = true
# }
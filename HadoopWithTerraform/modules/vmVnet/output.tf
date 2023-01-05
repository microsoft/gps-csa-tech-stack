output "vmName" {
  value = [ for vm in azurerm_linux_virtual_machine.VMs: vm.name]
}

output "public_ip_address" {
  value = azurerm_linux_virtual_machine.VMs[0].public_ip_address
}

output "nsgName" {
  value = azurerm_network_security_group.mynsg.name
}
# output "tls_private_key" {
#   value     = azurerm_key_vault.kvexample.secrectsprivate_key_pem
#   sensitive = true
# }
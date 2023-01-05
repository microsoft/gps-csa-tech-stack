provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "example" {
  name     = "examplerg"
  location = "eastasia"
}


data "azurerm_key_vault" "kvexample" {
  name                = "kvexample888"
  resource_group_name = "examplerg"
}

data "azurerm_key_vault_secret" "sshkey" {
  name         = "pubkey-test"
  key_vault_id = data.azurerm_key_vault.kvexample.id
}

resource "azurerm_linux_virtual_machine" "linuxserver1" {
    resource_group_name = azurerm_resource_group.example.name
    name = "linuxserver1"
    vm_hostname = "linuxserver1"
    size = "Standard_B1s"
    admin_ssh_key {
        username = "myadmin"
        public_key = data.azurerm_key_vault_secret.sshkey.value
    }
    admin_username = "myadmin"
    disable_password_authentication = true
    os_type = "linux"
    os_disk_size_gb = 30
    vm_os_simple = "CentOS"
    public_ip = true
    public_ip_dns = "linuxserver111"
    vnet_subnet_id  = azurerm_subnet.myterraformsubnet.id
  
}

# Create virtual network
resource "azurerm_virtual_network" "myterraformnetwork" {
  name                = "myVnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

# Create subnet
resource "azurerm_subnet" "myterraformsubnet" {
  name                 = "mySubnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.myterraformnetwork.name
  address_prefixes     = ["10.0.1.0/24"]
}

output "linux_vm_public_name" {
    value = module.linuxserver1.public_ip_dns_name
}

output "linux_vm_pip" {
    value = module.linuxserver1.public_ip_address
}
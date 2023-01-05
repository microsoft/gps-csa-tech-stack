

data "azurerm_resource_group" "rg" {
  name = var.rgName
}

# Create virtual network
data "azurerm_virtual_network" "modVnet" {
  name                = var.vnetName
  resource_group_name = var.vnetRG
}

# Create subnet
data "azurerm_subnet" "modSubnet" {
  name = var.subnetName
  virtual_network_name = var.vnetName
  resource_group_name = var.vnetRG
}

data "azurerm_key_vault" "kvName" {
  name                = var.kvName
  resource_group_name = var.kvRG
}

data "azurerm_key_vault_secret" "sshkey" {
  name         = var.kvKeyName
  key_vault_id = data.azurerm_key_vault.kvName.id
}


resource "azurerm_linux_virtual_machine_scale_set" "vmssHD" {
  name = "${var.vmNamePrefix}-vmss"
  location = var.rgLocation
  resource_group_name = var.rgName

  sku = var.vmSize
  instances = var.vmcount
  admin_username = "azureuser"

  admin_ssh_key {
    username = "azureuser"
    public_key = data.azurerm_key_vault_secret.sshkey.value
  }

  os_disk {
    storage_account_type = "Standard_LRS"
    caching = "ReadWrite"
  }

  network_interface {
    name = "vmssnic"
    primary = true

    ip_configuration {
      name = "ipconfig1"
      primary = true
      subnet_id = data.azurerm_subnet.modSubnet.id
    }
  }
  source_image_reference {
    publisher = "OpenLogic"
    offer     = "CentOS"
    sku       = "7_9"
    version   = "latest"
  }
  priority = var.spot ? "Spot" : "Regular"
  eviction_policy = var.spot ? "Delete" : null

}


# # Create public IPs

# resource "azurerm_public_ip" "vmssPip" {
#   name                = "${var.vmNamePrefix}-vmss-PIP"
#   location            = var.rgLocation
#   resource_group_name = var.rgName
#   allocation_method   = "Static"
# }

# resource "azurerm_lb" "vmssLB" {
#   name                = "${var.vmNamePrefix}-vmss-LB"
#   location            = var.rgLocation
#   resource_group_name = var.rgName

#   frontend_ip_configuration {
#     name                 = "PublicIPAddress"
#     public_ip_address_id = azurerm_public_ip.vmssPip.id
#   }
# }


# resource "azurerm_lb_backend_address_pool" "bpepool" {
#   location            = var.rgLocation
#   resource_group_name = var.rgName
#   name                = "BackEndAddressPool"
# }

# resource "azurerm_lb_nat_pool" "lbnatpool" {
#   resource_group_name = var.rgName
#   name                           = "ssh"
#   loadbalancer_id                = azurerm_lb.vmssLB.id
#   protocol                       = "Tcp"
#   frontend_port_start            = 50000
#   frontend_port_end              = 50119
#   backend_port                   = 22
#   frontend_ip_configuration_name = "PublicIPAddress"
# }

# resource "azurerm_lb_probe" "vmssLBProbe" {
#   resource_group_name = var.rgName
#   loadbalancer_id     = azurerm_lb.vmssLB.id
#   name                = "health-probe"
#   protocol            = var.healthProbeProtocol
#   request_path        = var.healthProbePath
#   port                = var.healthProbePort
# }


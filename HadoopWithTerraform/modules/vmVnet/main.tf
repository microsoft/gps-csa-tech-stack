

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

# Create public IPs

resource "azurerm_public_ip" "vmpip" {
  name                = "${var.vmNamePrefix}-${count.index}-PIP"
  count               = var.public_ip ? var.vmcount : 0
  location            = var.rgLocation
  resource_group_name = var.rgName
  allocation_method   = "Dynamic"
}

# Create Network Security Group and rule
resource "azurerm_network_security_group" "mynsg" {
  name                = var.nsgName
  location            = var.rgLocation
  resource_group_name = var.rgName

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
   security_rule    {
    name                       = "SSHnew"
    priority                   = 1101
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "6666"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# Create network interface
resource "azurerm_network_interface" "vmnic" {
  name                = "${var.vmNamePrefix}-${count.index}-NIC"
  location            = var.rgLocation
  resource_group_name = var.rgName
  count               = var.vmcount
  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = data.azurerm_subnet.modSubnet.id
    private_ip_address_allocation = "Dynamic"

    public_ip_address_id = var.public_ip ? azurerm_public_ip.vmpip[count.index].id : null
  }
}

# Connect the security group to the network interface
resource "azurerm_network_interface_security_group_association" "example" {
  count                     = var.vmcount
  network_interface_id      = azurerm_network_interface.vmnic[count.index].id
  network_security_group_id = azurerm_network_security_group.mynsg.id
}

# Generate random text for a unique storage account name
resource "random_id" "randomId" {
  keepers = {
    # Generate a new ID only when a new resource group is defined
    resource_group = var.rgName
  }

  byte_length = 3
}

# Create storage account for boot diagnostics
# resource "azurerm_storage_account" "mystorageaccount" {
#   name                     = "${lower(var.vmNamePrefix)}diag${random_id.randomId.hex}"
#   location            = var.rgLocation
#   resource_group_name = var.rgName
#   account_tier             = "Standard"
#   account_replication_type = "LRS"
# }

data "azurerm_key_vault" "kvName" {
  name                = var.kvName
  resource_group_name = var.kvRG
}

data "azurerm_key_vault_secret" "sshpubkey" {
  name         = var.kvPubKeyName
  key_vault_id = data.azurerm_key_vault.kvName.id
}

data "azurerm_key_vault_secret" "sshprikey" {
  name         = var.kvPriKeyName
  key_vault_id = data.azurerm_key_vault.kvName.id
}

resource "local_file" "sshprikeyfile" {
      content  = data.azurerm_key_vault_secret.sshprikey.value
      filename = pathexpand("~/cert1.pem")
  }

# Create virtual machine
resource "azurerm_linux_virtual_machine" "VMs" {
  name                  = "${var.vmNamePrefix}-${count.index}"
  location            = var.rgLocation
  resource_group_name = var.rgName
  count                 = var.vmcount
  network_interface_ids = [azurerm_network_interface.vmnic[count.index].id]
  size                  = var.vmSize
  priority              = var.spot ? "Spot" : "Regular"
  eviction_policy       = var.spot ? "Deallocate" : null
  
  os_disk {
    name                 = "${var.vmNamePrefix}-${count.index}-OsDisk"
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }


  source_image_reference {
    publisher = "${var.image_publisher}"
    offer     = "${var.image_offer}"
    sku       = "${var.image_sku}"
    version   = "${var.image_version}"
  }

  computer_name                   = "${var.vmNamePrefix}-${count.index}"
  admin_username                  = var.userName
  disable_password_authentication = true

  admin_ssh_key {
    username   = var.userName
    public_key = data.azurerm_key_vault_secret.sshpubkey.value
  }


  provisioner "file" {
    content      = data.azurerm_key_vault_secret.sshprikey.value
    destination = "/home/${var.userName}/.ssh/id_rsa"
    
        connection {
      type        = "ssh"
      user        = var.userName
      private_key = data.azurerm_key_vault_secret.sshprikey.value
      host        = "${var.public_ip?self.public_ip_address:self.name}"
    }
  }

  #修改Ubuntu的SSH 端口
  provisioner "remote-exec" {
    # count = var.public_ip ? var.vmcount : 0
        connection {
      type        = "ssh"
      user        = var.userName
      private_key = data.azurerm_key_vault_secret.sshprikey.value
      host        = "${var.public_ip?self.public_ip_address:self.name}"
    }

    inline = [
      "sudo sed -i 's/#.*StrictHostKeyChecking ask/StrictHostKeyChecking no/g' /etc/ssh/ssh_config",
      "sudo sed -i '18a Port 6666'  /etc/ssh/sshd_config",
      "sudo sed -i '18a Port 22'  /etc/ssh/sshd_config",
      "sudo yum install -y policycoreutils",
      "sudo semanage port -a -t ssh_port_t -p tcp 6666",
      "sudo semanage port -m -t ssh_port_t -p tcp 6666",
      "sudo systemctl restart sshd"
    ]
  }

  # boot_diagnostics {
  #   storage_account_uri = azurerm_storage_account.mystorageaccount.primary_blob_endpoint
  # }

}
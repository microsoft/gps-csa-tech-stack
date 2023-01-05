resource "random_pet" "rg-name" {
  prefix = var.resource_group_name_prefix
}

resource "azurerm_resource_group" "rg" {
  name     = random_pet.rg-name.id
  location = var.resource_group_location
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

# Create public IPs

  resource "azurerm_public_ip" "myterraformpublicip" {
    name                = "${var.vm_name_prefix}-${count.index}-PIP"
    count = var.public_ip ? var.vmcount : 0
    location            = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
    allocation_method   = "Dynamic"
  }
# Create Network Security Group and rule
resource "azurerm_network_security_group" "myterraformnsg" {
  name                = "myNetworkSecurityGroup"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

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
}

# Create network interface
resource "azurerm_network_interface" "myterraformnic" {
  name                = "${var.vm_name_prefix}-${count.index}-NIC"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  count = var.vmcount
  ip_configuration {
    name                          = "myNicConfiguration"
    subnet_id                     = azurerm_subnet.myterraformsubnet.id
    private_ip_address_allocation = "Dynamic"
   
    public_ip_address_id = var.public_ip? azurerm_public_ip.myterraformpublicip[count.index].id : null
  }
}

# Connect the security group to the network interface
resource "azurerm_network_interface_security_group_association" "example" {
  count = var.vmcount
  network_interface_id      = azurerm_network_interface.myterraformnic[count.index].id
  network_security_group_id = azurerm_network_security_group.myterraformnsg.id
}

# Generate random text for a unique storage account name
resource "random_id" "randomId" {
  keepers = {
    # Generate a new ID only when a new resource group is defined
    resource_group = azurerm_resource_group.rg.name
  }

  byte_length = 8
}

# Create storage account for boot diagnostics
resource "azurerm_storage_account" "mystorageaccount" {
  name                     = "diag${random_id.randomId.hex}"
  location                 = azurerm_resource_group.rg.location
  resource_group_name      = azurerm_resource_group.rg.name
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

data "azurerm_key_vault" "kvexample" {
  name                = "kvexample888"
  resource_group_name = "examplerg"
}

data "azurerm_key_vault_secret" "sshkey" {
  name         = "pubkey-test"
  key_vault_id = data.azurerm_key_vault.kvexample.id
}

# Create virtual machine
resource "azurerm_linux_virtual_machine" "myterraformvm" {
  name                  = "${var.vm_name_prefix}-${count.index}"
  location              = azurerm_resource_group.rg.location
  resource_group_name   = azurerm_resource_group.rg.name
  count                = var.vmcount
  network_interface_ids = [azurerm_network_interface.myterraformnic[count.index].id]
  size                  = "Standard_DS1_v2"
  priority = var.spot ? "Spot" : "Regular"
  eviction_policy = var.spot ? "Deallocate" : null

  os_disk {
    name                 = "${var.vm_name_prefix}-${count.index}-OsDisk"
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  computer_name                   = "${var.vm_name_prefix}-${count.index}"
  admin_username                  = "azureuser"
  disable_password_authentication = true

  admin_ssh_key {
    username   = "azureuser"
    public_key = data.azurerm_key_vault_secret.sshkey.value
  }

  boot_diagnostics {
    storage_account_uri = azurerm_storage_account.mystorageaccount.primary_blob_endpoint
  }
}
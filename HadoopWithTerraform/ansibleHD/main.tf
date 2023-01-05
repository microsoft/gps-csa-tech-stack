
resource "azurerm_resource_group" "hdrg" {
  name     = "hdrg"
  location = "eastasia"
}

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


module "ansibleHost" {
  source       = "../modules/vmVnet"
  vmNamePrefix = "ansibleHost"
  vmcount      = 2
  vnetName     = module.hd-vnet.vnetName
  vnetRG       = azurerm_resource_group.hdrg.name
  subnetName   = module.hd-vnet.subnetName
  rgLocation   = azurerm_resource_group.hdrg.location
  rgName       = azurerm_resource_group.hdrg.name
  public_ip    = true
  spot         = true
  image_offer = "0001-com-ubuntu-server-focal"
  image_publisher = "Canonical"
  image_sku = "20_04-lts"
  kvName       = "kvexample888"
  kvRG         = "exampleRG"
  # kvLocation = "eastasia"
  kvKeyName = "pubkey-test"
  vmSize    = "Standard_D4S_v3"

  depends_on = [
    module.hd-vnet,
    azurerm_resource_group.hdrg,
  ]
}

resource "null_resource" "local-setup" {


  provisioner "local-exec" {
    command = <<EOT
    cd ~
    echo "[testgroup]" > hosts
    echo "${module.hd-master.public_ip_address}" >> hosts
    echo "[testgroup:vars]" >> hosts
    echo "ansible_user=azureuser" >> hosts
    echo "ansible_ssh_private_key_file=~/cert1.pem" >> hosts
    echo "ansible_ssh_port=6666" >> hosts
    echo "ansible_ssh_extra_args='-o StrictHostKeyChecking=no'" >> hosts
    echo "ansible_become=true" >> hosts
    echo "ansible_become_method=sudo" >> hosts
    echo "ansible_become_user=root" >> hosts
    cd -
    ansible-playbook -i /home/rade/hosts playbook.yml
    EOT
  }

}
  
module "hd-master" {
  source       = "../modules/vmVnet"
  vmNamePrefix = "hdmaster"
  vmcount      = 2
  vnetName     = module.hd-vnet.vnetName
  vnetRG       = azurerm_resource_group.hdrg.name
  subnetName   = module.hd-vnet.subnetName
  rgLocation   = azurerm_resource_group.hdrg.location
  rgName       = azurerm_resource_group.hdrg.name
  public_ip    = false
  spot         = true
  kvName       = "kvexample888"
  kvRG         = "exampleRG"
  # kvLocation = "eastasia"
  kvKeyName = "pubkey-test"
  vmSize    = "Standard_D4S_v3"

  depends_on = [
    module.hd-vnet,
    azurerm_resource_group.hdrg,
  ]
}


variable "hfile" {
  default = "hosts-hdmaster"
}

resource "null_resource" "local-setup2" {

  provisioner "local-exec" {
    command = <<EOT
    cd ~
    echo "[testgroup]" > ${var.hfile}
    echo "${module.hd-master.public_ip_address}" >> ${var.hfile}
    echo "[testgroup:vars]" >> ${var.hfile}
    echo "ansible_user=azureuser" >> ${var.hfile}
    echo "ansible_ssh_private_key_file=~/cert1.pem" >> ${var.hfile}
    echo "ansible_ssh_port=6666" >> ${var.hfile}
    echo "ansible_ssh_extra_args='-o StrictHostKeyChecking=no'" >> ${var.hfile}
    echo "ansible_become=true" >> ${var.hfile}
    echo "ansible_become_method=sudo" >> ${var.hfile}
    echo "ansible_become_user=root" >> ${var.hfile}
    cd -
    ansible-playbook -i /home/rade/${var.hfile} playbook.yml
    EOT
  }

  depends_on = [
    module.hd-master
  ]
}

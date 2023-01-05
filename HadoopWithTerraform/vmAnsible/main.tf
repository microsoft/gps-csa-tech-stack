
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


module "hd-master" {
  source       = "../modules/vmVnet"
  vmNamePrefix = "hdmaster"
  vmcount      = 1
  vnetName     = module.hd-vnet.vnetName
  vnetRG       = azurerm_resource_group.hdrg.name
  subnetName   = module.hd-vnet.subnetName
  rgLocation   = azurerm_resource_group.hdrg.location
  rgName       = azurerm_resource_group.hdrg.name
  public_ip    = true
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
    ansible-playbook -i hosts playbook.yml
    EOT
  }
}

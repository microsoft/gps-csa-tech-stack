
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
  vmcount      = 1
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
  kvPubKeyName = "pubkey-test"
  kvPriKeyName = "prikey-test"
  vmSize    = "Standard_D4S_v3"

  depends_on = [
    module.hd-vnet,
    azurerm_resource_group.hdrg,
  ]
}

resource "null_resource" "local-setup" {
  triggers = {
    always_run = "${timestamp()}"
  }

  provisioner "local-exec" {
    command = <<EOT
    cd ~
    chmod 400 cert1.pem
    echo "[testgroup]" > hosts
    echo "${module.ansibleHost.public_ip_address}" >> hosts
    echo "[testgroup:vars]" >> hosts
    echo "ansible_user=azureuser" >> hosts
    echo "ansible_ssh_private_key_file=/home/$USER/cert1.pem" >> hosts
    echo "ansible_ssh_port=6666" >> hosts
    echo "ansible_ssh_extra_args='-o StrictHostKeyChecking=no'" >> hosts
    echo "ansible_become=true" >> hosts
    echo "ansible_become_method=sudo" >> hosts
    echo "ansible_become_user=root" >> hosts
    cd -
    # ansible-playbook -i /home/$USER/hosts playbook.yml
    EOT
  }
}


data  "azurerm_resource_group" "hdrg" {
  name     = "hdrg"
  # location = "eastasia"
}

# data  "azurerm_virtual_network" "hdvnet" {
#   name   = "hdvnet"
#   # region     = data.azurerm_resource_group.hdrg.location
#   resource_group_name     = data.azurerm_resource_group.hdrg.name
#   # subnetName = "hdsubnet"
# }


module "hd-master" {
  source       = "../modules/vmVnet"
  vmNamePrefix = "hdmaster"
  vmcount      = 2
  vnetName     = "hdvnet"
  vnetRG       = data.azurerm_resource_group.hdrg.name
  nsgName = "hdmnsg"
  subnetName   = "hdsubnet"
  rgLocation   = data.azurerm_resource_group.hdrg.location
  rgName       = data.azurerm_resource_group.hdrg.name
  public_ip    = false
  spot         = true
  # image_offer = "0001-com-ubuntu-server-focal"
  # image_publisher = "Canonical"
  # image_sku = "20_04-lts"
  kvName       = "kvexample888"
  kvRG         = "exampleRG"
  # kvLocation = "eastasia"
  kvPubKeyName = "pubkey-test"
  kvPriKeyName = "prikey-test"
  vmSize    = "Standard_D4S_v3"

}

variable "hfile" {
  default = "hosts-hdmaster"
}

resource "null_resource" "local-setup" {
  triggers = {
    always_run = "${timestamp()}"
  }

  provisioner "local-exec" {
    command = <<EOT
    cd ~
    chmod 400 cert1.pem
    chmod 400 /home/$USER/.ssh/id_rsa
    echo "[testgroup]" > ${var.hfile}
    echo "[testgroup]" > ${var.hfile}
    %{ for n in module.hd-master.vmName ~}
    echo "${n}" >> ${var.hfile}
    %{ endfor ~}
    echo "[testgroup:vars]" >> ${var.hfile}
    echo "ansible_user=azureuser" >> ${var.hfile}
    echo "ansible_ssh_private_key_file=/home/$USER/cert1.pem" >> ${var.hfile}
    echo "ansible_ssh_extra_args='-o StrictHostKeyChecking=no'" >> ${var.hfile}
    echo "ansible_become=true" >> ${var.hfile}
    echo "ansible_become_method=sudo" >> ${var.hfile}
    echo "ansible_become_user=root" >> ${var.hfile}
    cd -
    ansible-playbook -i /home/$USER/${var.hfile} playbook.yml
    EOT
  }
}

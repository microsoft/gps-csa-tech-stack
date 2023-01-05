variable "rgName" {
  default     = "rg"
  description = "Prefix of the resource group name that's combined with a random ID so name is unique in your Azure subscription."
}

variable "rgLocation" {
  description = "Location of the resource group."
}

variable "spot" {
  type        = bool
  description = "value of the spot flag: true or false"
}

variable "public_ip" {
  type        = bool
  description = "value of the public ip flag: true or false"
}

variable "vmcount" {
  type        = number
  description = "count of VMs to create"
}

variable "vmNamePrefix" {
  default     = "vmtest-"
  description = "value of the vm name prefix"

}

variable "vnetName" {
  default     = "vnet"
  description = "value of the vnet name"
}

variable "subnetName" {
  default     = "subnet1"
  description = "value of the subnet name"

}

variable "vnetRG" {
  default     = "rg"
  description = "value of the vnet resource group"
  
}

variable "nsgName" {
  default = "nsghd"
  description = "name of nsg"
  
}
variable "kvName" {
  default     = "keyvault"
  description = "value of the keyvault name"
}

variable "kvRG" {
  default     = "rg"
  description = "value of the keyvault resource group"
}

variable "kvPubKeyName" {
  default     = "pubkey-test"
  description = "value of the keyvault key name"
  
}

variable "kvPriKeyName" {
  default     = "prikey-test"
  description = "value of the keyvault key name"
  
}

variable "vmSize" {
  default     = "Standard_D1_v3"
  description = "value of the vm size"
}

variable "userName" {
  default     = "azureuser"
  description = "value of the user name"
  
}

variable "image_publisher" {
  default = "OpenLogic"
  description = "VM publisher, Canonical, OpenLogic"
}

variable "image_offer" {
  default = "CentOS"
  description = " ubuntu 20.04 - 0001-com-ubuntu-server-focal, or CentOS"
  
}

variable "image_sku" {
  default = "7_9"
  description = "CentOS 7.9, or Ubuntu 20_04-lts"
}

variable "image_version" {
  default = "latest"
}
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

variable "kvName" {
  default     = "keyvault"
  description = "value of the keyvault name"
}

variable "kvRG" {
  default     = "rg"
  description = "value of the keyvault resource group"
}

variable "kvKeyName" {
  default     = "pubkey-test"
  description = "value of the keyvault key name"
  
}

variable "vmSize" {
  default     = "Standard_DS1_v2"
  description = "value of the vm size"
}

variable "healthPort" {
  default     = "80"
  description = "value of the health port"
}
  
variable "healthProbePath" {
  default     = "/"
  description = "value of the health probe path"
}

variable "healthProbeProtocol" {
  default     = "HTTP"
  description = "value of the health probe protocol"
}

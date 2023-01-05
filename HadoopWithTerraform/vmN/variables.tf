variable "resource_group_name_prefix" {
  default     = "rg"
  description = "Prefix of the resource group name that's combined with a random ID so name is unique in your Azure subscription."
}

variable "resource_group_location" {
  description = "Location of the resource group."
}

variable "spot" {
  type = bool
  description = "value of the spot flag: true or false"
}

variable "public_ip" {
  type = bool
  description = "value of the public ip flag: true or false"
}

variable "vmcount" {
  type = number
  description = "count of VMs to create"
}

variable "vm_name_prefix" {
  default = "vmtest-"
  description = "value of the vm name prefix"
  
}


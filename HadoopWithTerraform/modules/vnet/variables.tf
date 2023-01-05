
variable "vnetName" {
    default = "vnet"
    description = "Name of the virtual network."
  
}

variable "subnetName" {
    default = "subnet1"
    description = "Name of the subnet."
}

variable "addressSpace" {
    default = "10.0.0.0/16"
    description = "Address space of the virtual network."
}

variable "subnetAddressSpace" {
    default = "10.0.0.0/24"
    description = "Address space of the virtual network."
}

variable "rgName" {
    description = "Name of the resource group."
}

variable "region" {
  description = "value of the region/location"
}
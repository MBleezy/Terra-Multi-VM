variable "vm_names" {
  type    = list(string)
  default = ["Dev-Box-1", "Dev-Box-2", "Dev-Box-3", "Dev-Box-4", "Dev-Box-5"]
}

variable "location" {
  type    = string
  default = "east us"
}

variable "network" {
  type    = string
  default = "BleezNet"
}

variable "subnet" {
  type    = string
  default = "BleezSubnet"
}

variable "admin_password" {
  type    = string
  default = "TestPass#1"
}
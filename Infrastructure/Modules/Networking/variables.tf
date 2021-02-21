# Variables for VPC Module

variable "NAME" {
  type    = "string"
  default = "VPC-Test"
}

variable "CIDR" {
  type = "list"
}

variable "SUBNETS_NUMBER" {
  default = 2
}

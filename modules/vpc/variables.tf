variable "my_region" {
  description = "aws region"
  type    = string
}


##################################################
# VPC MODULE VARIABLES
##################################################

variable "vpc_owner" {
  description = "vpc owner"
  type    = string
}

variable "vpc_use" {
  description = "vpc use"
  type    = string
}

variable "vpc_cidr" {
  description = "cidr block for vpc"
  type    = string
}

variable "vpc_public_subnets" {
  description = "list of public subnets"
  type    = list(string)
}

variable "vpc_private_subnets" {
  description = "list of private subnets"
  type    = list(string)
}

variable "vpc_enable_nat_gateway" {
  description = "Enable NAT Gateways for Private Subnets Outbound Communication"
  type        = bool
}

variable "vpc_single_nat_gateway" {
  description = "Enable only single NAT Gateway in one Availability Zone to save costs during our demos"
  type        = bool
}
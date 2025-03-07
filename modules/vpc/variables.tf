# variable "vpc_region" {
#   description = "aws region"
#   type    = string
# }


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

variable "vpc_enable_dns_hostnames" {
  description = "enable dns hostnames"
  type = bool
}

variable "vpc_public_subnets_tags" {
  description = "tags for public subnet"
  type = map(any)
  default = {
    "kubernetes.io/role/elb" = "1"
  }
}

variable "vpc_private_subnets_tags" {
  description = "tags for public subnet"
  type = map(any)
  default = {
    "kubernetes.io/role/internal-elb" = 1
  }
}
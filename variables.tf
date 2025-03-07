variable "my_region" {
  description = "aws region"
  type        = string
}


#########################################
# VPC MODULE VARIABLES
#########################################
variable "vpc_owner" {
  description = "The owner of the VPC"
  type        = string
}

variable "vpc_use" {
  description = "The purpose of the VPC"
  type        = string
}

variable "vpc_cidr" {
  type = string
}

variable "vpc_availability_zones" {
  type = list(string)
}

variable "vpc_public_subnets" {
  type = list(string)
}

variable "vpc_private_subnets" {
  type = list(string)
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
  description = "Enable DNS hostnames in VPC"
  type        = bool
  default     = true
}

variable "vpc_public_subnets_tags" {
  description = "tags for public subnet"
  type        = map(any)
}

variable "vpc_private_subnets_tags" {
  description = "tags for public subnet"
  type        = map(any)
}

#########################################
# EKS MODULE VARIABLES
#########################################
variable "rolearn" {
  type = string
}

variable "eks_cluster_name" {
  type = string
}

variable "node_groups_instance_types" {
  type = list(string)
}
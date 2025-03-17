variable "aws_region" {
  description = "The AWS region to deploy the EFS CSI driver"
  type        = string
}

variable "cluster_name" {
  description = "The name of the EKS cluster"
  type        = string
}

variable "vpc_id" {
  description = "The VPC ID to deploy the EFS CSI driver"
  type        = string
}

variable "vpc_cidr_block" {
  description = "The CIDR block of the VPC"
  type        = string
}

variable "private_subnets" {
  description = "The private subnets to deploy the EFS CSI driver"
  type        = list(string)
}




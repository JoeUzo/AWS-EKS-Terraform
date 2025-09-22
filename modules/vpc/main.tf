module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.19.0"

  name = local.name_
  cidr = var.vpc_cidr

  azs             = local.azs
  public_subnets  = var.vpc_public_subnets
  private_subnets = var.vpc_private_subnets

  enable_nat_gateway = var.vpc_enable_nat_gateway
  single_nat_gateway = var.vpc_single_nat_gateway
  enable_dns_hostnames = var.vpc_enable_dns_hostnames
  
  tags = local.common_tags

  public_subnet_tags = var.vpc_public_subnets_tags
  private_subnet_tags = var.vpc_private_subnets_tags

}

locals {
  az_names = data.aws_availability_zones.available_azs.names
  azs      = slice(local.az_names, 0, min(3, length(local.az_names)))
}

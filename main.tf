module "vpc_module" {
  source = "./modules/vpc"
#   vpc_region = var.my_region
  vpc_owner              = var.vpc_owner
  vpc_use                = var.vpc_use
  vpc_cidr               = var.vpc_cidr
  vpc_public_subnets     = var.vpc_public_subnets
  vpc_private_subnets    = var.vpc_private_subnets
  vpc_enable_nat_gateway = var.vpc_enable_nat_gateway
  vpc_single_nat_gateway = var.vpc_single_nat_gateway
  vpc_enable_dns_hostnames = var.vpc_enable_dns_hostnames
  vpc_public_subnets_tags  = var.vpc_public_subnets_tags
  vpc_private_subnets_tags = var.vpc_private_subnets_tags
}

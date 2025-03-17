module "vpc_module" {
  source = "./modules/vpc"
  #   vpc_region = var.my_region
  vpc_owner                = var.vpc_owner
  vpc_use                  = var.vpc_use
  vpc_cidr                 = var.vpc_cidr
  vpc_public_subnets       = var.vpc_public_subnets
  vpc_private_subnets      = var.vpc_private_subnets
  vpc_enable_nat_gateway   = var.vpc_enable_nat_gateway
  vpc_single_nat_gateway   = var.vpc_single_nat_gateway
  vpc_enable_dns_hostnames = var.vpc_enable_dns_hostnames
  vpc_public_subnets_tags  = var.vpc_public_subnets_tags
  vpc_private_subnets_tags = var.vpc_private_subnets_tags
}


module "eks_module" {
  source = "./modules/eks-cluster"

  vpc_id                     = module.vpc_module.vpc_id
  cluster_name               = var.eks_cluster_name
  private_subnets            = module.vpc_module.private_subnets
  node_groups_instance_types = var.node_groups_instance_types
  rolearn                    = var.rolearn
}

module "efs_module" {
  source          = "./modules/efs"
  aws_region      = var.my_region
  cluster_name    = var.eks_cluster_name
  vpc_id          = module.vpc_module.vpc_id
  private_subnets = module.vpc_module.private_subnets
  vpc_cidr_block  = var.vpc_cidr
  oidc_provider   = module.eks_module.oidc_provider
}

module "add_ons_module" {
  source               = "./modules/add-ons"
  cluster_name         = var.eks_cluster_name
  grafana_password     = var.grafana_password
  domain               = var.domain
  cluster_ca           = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
  cluster_token        = data.aws_eks_cluster_auth.cluster.token
  cluster_endpoint     = data.aws_eks_cluster.cluster.endpoint
  grafana_username     = var.grafana_username
  eks_cluster_name     = var.eks_cluster_name
  create_app_ingresses = true
  ingress_map          = var.app_ingress
}


data "aws_eks_cluster" "cluster" {
  name       = var.eks_cluster_name
  depends_on = [module.eks_module]
}

data "aws_eks_cluster_auth" "cluster" {
  name       = var.eks_cluster_name
  depends_on = [module.eks_module]
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}

provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.cluster.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.cluster.token
  }
}

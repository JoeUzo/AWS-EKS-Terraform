module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.31"

  cluster_name = var.cluster_name
  cluster_version = "1.31"

  cluster_endpoint_public_access = true

  vpc_id = var.vpc_id
  subnet_ids = var.private_subnets
  control_plane_subnet_ids = var.private_subnets

  cluster_addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
    aws-ebs-csi-driver = {
      most_recent = true
    }
    
  }

  eks_managed_node_group_defaults = {
    iam_role_additional_policies = {
      AmazonEBSCSIDriverPolicy = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
    }
    ami_type = "AL2_x86_64"
    instance_types = var.node_groups_instance_types
  }

  eks_managed_node_groups = {
    group-01 = {
      name = "node-group-1"
      min_size = 1
      max_size = 10
      desired_size = 2
    }

    group-02 = {
      name = "node-group-2"
      min_size = 1
      max_size = 10
      desired_size = 2
    }
  }

  tags = {
    terraform = "true"
  }

}




data "aws_eks_cluster" "cluster" {
  name = var.cluster_name
}

data "aws_eks_cluster_auth" "cluster" {
  name = var.cluster_name
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}

resource "kubernetes_config_map" "aws_auth" {
  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
  }

  data = {
    mapRoles = yamlencode([
      {
        rolearn  = var.rolearn
        username = "admin"
        groups   = [
          "system:masters"
        ]
      }
    ])
  }
}

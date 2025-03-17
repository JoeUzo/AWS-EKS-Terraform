data "aws_iam_policy" "efs_csi_policy" {
  arn = "arn:aws:iam::aws:policy/AmazonEFSCSIDriverPolicy"
}

module "irsa-efs-csi" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version = "5.39.0"

  create_role                   = true
  role_name                     = "AmazonEKS_EFSCSIDriverRole-${module.eks.cluster_name}"
  provider_url                  = module.eks.oidc_provider
  role_policy_arns              = [data.aws_iam_policy.efs_csi_policy.arn]
  oidc_fully_qualified_subjects = ["system:serviceaccount:kube-system:efs-csi-controller-sa"]
}


# Create the service account for the EFS CSI driver
resource "kubernetes_service_account" "efs_csi_controller" {
  metadata {
    name      = "efs-csi-controller-sa"
    namespace = "kube-system"
    annotations = {
      "eks.amazonaws.com/role-arn" = module.irsa-efs-csi.iam_role_arn
    }
  }
}

# Deploy the AWS EFS CSI driver using Helm
resource "helm_release" "aws_efs_csi_driver" {
  name       = "aws-efs-csi-driver"
  namespace  = "kube-system"
  repository = "https://kubernetes-sigs.github.io/aws-efs-csi-driver/"
  chart      = "aws-efs-csi-driver"
  version    = "3.1.7"   # Adjust to a current stable version if needed

  # Instruct Helm not to create a service account because we provide our own
  values = [
    <<EOF
serviceAccount:
  create: false
  name: efs-csi-controller-sa
region: "${var.aws_region}"
EOF
  ]

  depends_on = [kubernetes_service_account.efs_csi_controller]
}


# Security Group for EFS (allows NFS traffic)
resource "aws_security_group" "efs" {
  name        = "${var.cluster_name}-efs-sg"
  description = "Security group for EFS"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr_block]  
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create the EFS file system
resource "aws_efs_file_system" "this" {
  creation_token    = "${var.cluster_name}-efs"
  performance_mode  = "generalPurpose"
  lifecycle_policy {
    transition_to_ia = "AFTER_14_DAYS"
  }
  tags = {
    Name = "${var.cluster_name}-efs"
  }
}

# Create mount targets in each private subnet
resource "aws_efs_mount_target" "this" {
  for_each       = toset(var.private_subnets)
  file_system_id = aws_efs_file_system.this.id
  subnet_id      = each.value
  security_groups = [
    aws_security_group.efs.id
  ]
}

# Create an EFS Access Point (used by dynamic provisioning)
resource "aws_efs_access_point" "this" {
  file_system_id = aws_efs_file_system.this.id

  posix_user {
    uid = 1000
    gid = 1000
  }

  root_directory {
    path = "/dynamic_provisioning"
    creation_info {
      owner_gid   = 1000
      owner_uid   = 1000
      permissions = "755"
    }
  }
}


resource "kubernetes_storage_class" "efs" {
  metadata {
    name = "efs-sc"
  }
  storage_provisioner = "efs.csi.aws.com"
  parameters = {
    provisioningMode = "efs-ap"
    fileSystemId     = aws_efs_file_system.this.id
    directoryPerms   = "700"
    gidRangeStart    = "1000"
    gidRangeEnd      = "2000"
    basePath         = "/dynamic_provisioning"
  }
}

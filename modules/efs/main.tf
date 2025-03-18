data "aws_iam_policy" "efs_csi_policy" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonEFSCSIDriverPolicy"
}

module "irsa-efs-csi" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version = "5.39.0"

  create_role                   = true
  role_name                     = "AmazonEKS_EFSCSIDriverRole-${var.cluster_name}"
  provider_url                  = var.oidc_provider
  role_policy_arns              = [data.aws_iam_policy.efs_csi_policy.arn]
  oidc_fully_qualified_subjects = ["system:serviceaccount:kube-system:efs-csi-controller-sa"]
}

# Create the service account for the EFS CSI driver with the required annotations/labels
resource "kubernetes_service_account" "efs_csi_controller" {
  metadata {
    name      = "efs-csi-controller-sa"
    namespace = "kube-system"
    annotations = {
      "eks.amazonaws.com/role-arn"    = module.irsa-efs-csi.iam_role_arn
      "meta.helm.sh/release-name"       = "aws-efs-csi-driver"
      "meta.helm.sh/release-namespace"    = "kube-system"
    }
    labels = {
      "app.kubernetes.io/managed-by"    = "Helm"
    }
  }
}

# Deploy the AWS EFS CSI driver using Helm
resource "helm_release" "aws_efs_csi_driver" {
  name       = "aws-efs-csi-driver"
  namespace  = "kube-system"
  repository = "https://kubernetes-sigs.github.io/aws-efs-csi-driver/"
  chart      = "aws-efs-csi-driver"
  version    = "3.1.7"

  # Pass controller pod annotations and disable service account creation
  values = [
    <<EOF
controller:
  podAnnotations:
    meta.helm.sh/release-name: "aws-efs-csi-driver"
    meta.helm.sh/release-namespace: "kube-system"
    app.kubernetes.io/managed-by: "Helm"
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
  creation_token   = "${var.cluster_name}-efs"
  performance_mode = "generalPurpose"
  lifecycle_policy {
    transition_to_ia = "AFTER_14_DAYS"
  }
  tags = {
    Name = "${var.cluster_name}-efs"
  }
}

# Create mount targets in each private subnet
resource "aws_efs_mount_target" "this" {
  count           = length(var.private_subnets)
  file_system_id  = aws_efs_file_system.this.id
  subnet_id       = var.private_subnets[count.index]
  security_groups = [aws_security_group.efs.id]
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

# Create a Kubernetes StorageClass for EFS dynamic provisioning
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

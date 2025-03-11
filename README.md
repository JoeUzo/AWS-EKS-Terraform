# PDF-gpt-infra

**PDF-gpt-infra** is an infrastructure-as-code repository that provisions an Amazon EKS cluster (with a supporting VPC) using Terraform. This repository is part of the overall PDF GPT ecosystem. For the application repository, please visit: [PDF-gpt--RAG-Application](https://github.com/JoeUzo/PDF-gpt--RAG-Application-).

## Table of Contents

- [Overview](#overview)
- [Repository Structure](#repository-structure)
- [Prerequisites](#prerequisites)
- [Setup and Configuration](#setup-and-configuration)
- [Terraform Variables Example](#terraform-variables-example)
- [Deployment](#deployment)
- [Accessing the Cluster](#accessing-the-cluster)
- [Contributing](#contributing)
- [License](#license)

## Overview

This repository uses Terraform to automatically provision an AWS Virtual Private Cloud (VPC) and an EKS cluster with managed node groups. The configuration includes:
- Creation of a VPC with public and private subnets.
- Tagging of subnets to designate public (for external resources) and private (for internal resources) usage.
- Provisioning of an EKS cluster with a customizable node group.
- Automatic mapping of the cluster creator (or a specified IAM role) to full administrative privileges via the aws‑auth ConfigMap.

## Repository Structure

```
PDF-gpt-infra/
├── modules/                # Reusable Terraform modules (e.g., VPC, EKS)
├── terraform/              # Main Terraform configuration files
│   ├── main.tf             # Primary Terraform configuration
│   ├── variables.tf        # Variable definitions
│   ├── outputs.tf          # Output definitions
│   └── terraform.tfvars    # Environment-specific variables (example provided below)
├── scripts/                # Helper scripts (e.g., updating kubeconfig)
├── README.md               # This file
└── ...                     # Other documentation and configuration files
```

## Prerequisites

- **Terraform:** Version 1.x (compatible with this repository)
- **AWS CLI v2:** Required for EKS token generation and managing your AWS resources
- **kubectl:** Version 1.18 or later
- **AWS Account:** With permissions to create VPCs, EKS clusters, and related IAM resources

## Setup and Configuration

1. **Clone the Repository:**
   ```bash
   git clone https://github.com/JoeUzo/PDF-gpt-infra.git
   cd PDF-gpt-infra
   ```

2. **Configure AWS Credentials:**
   Ensure your AWS CLI is configured. For example, set your default profile or use an alternative profile:
   ```bash
   export AWS_PROFILE=default
   ```

3. **Review and Update Variables:**
   Edit the Terraform variables file (`terraform/terraform.tfvars`) to suit your environment.

## Terraform Variables Example

Below is an example of a generic `terraform.tfvars` file. Update these settings as required for your setup.

```hcl
# Region where the resources will be created
my_region = "us-east-1"

# VPC Configuration
vpc_owner              = "ExampleOwner"
vpc_use                = "ExampleUse"
vpc_cidr               = "10.0.0.0/16"
vpc_availability_zones = ["us-east-2a", "us-east-2b", "us-east-2c"]

# Subnet CIDRs
vpc_public_subnets  = ["10.0.1.0/24", "10.0.2.0/24"]
vpc_private_subnets = ["10.0.3.0/24", "10.0.4.0/24"]

# NAT Gateway & DNS Hostnames
vpc_enable_nat_gateway   = true
vpc_single_nat_gateway   = true
vpc_enable_dns_hostnames = true

# Subnet Tagging (IMPORTANT for proper resource placement)
vpc_public_subnets_tags = {
  "kubernetes.io/role/elb" = "1"
}

vpc_private_subnets_tags = {
  "kubernetes.io/role/internal-elb" = "1"
}

# EKS Cluster Configuration
rolearn                    = "arn:aws:iam::<account-id>:role/Your-EKS-Role"
eks_cluster_name           = "your-eks-cluster"
node_groups_instance_types = ["m5.xlarge", "m5.large]
```

## Deployment

1. **Initialize Terraform:**
   Navigate to the Terraform directory and initialize:
   ```bash
   cd terraform
   terraform init
   ```

2. **Plan the Deployment:**
   Generate an execution plan:
   ```bash
   terraform plan
   ```

3. **Apply the Deployment:**
   Provision the infrastructure:
   ```bash
   terraform apply
   ```
   Confirm the changes when prompted.

4. **Update kubeconfig:**
   Once the cluster is created, update your kubeconfig to interact with the cluster:
   ```bash
   aws eks update-kubeconfig --name your-eks-cluster --region us-east-2 --profile default
   ```

## Accessing the Cluster

After deployment, you can interact with your EKS cluster using `kubectl`. For example, to view all nodes:
```bash
kubectl get nodes
```

> **Note:** By default, the cluster creator is mapped to full administrative privileges (via the aws‑auth ConfigMap) using the configuration option `enable_cluster_creator_admin_permissions = true`.

## Contributing

Contributions are welcome! Please fork the repository and submit pull requests with improvements or bug fixes. For significant changes, please open an issue to discuss your ideas first.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

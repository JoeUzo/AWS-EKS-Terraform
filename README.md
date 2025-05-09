# AWS-EKS-Terraform

**AWS-EKS-Terraform** is an infrastructure-as-code repository that provisions a complete AWS EKS-based Kubernetes platform for running containerized applications. This infrastructure includes an EKS cluster, VPC networking, persistent storage via EFS, monitoring with Prometheus and Grafana, and ingress controllers for external access.

## Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Repository Structure](#repository-structure)
- [Prerequisites](#prerequisites)
- [Setup and Configuration](#setup-and-configuration)
- [Terraform Variables](#terraform-variables)
- [Deployment](#deployment)
- [Accessing Your Applications](#accessing-your-applications)
- [Monitoring and Management](#monitoring-and-management)
- [Storage Management](#storage-management)
- [Contributing](#contributing)
- [License](#license)

## Overview

This repository automates the deployment of a production-ready Kubernetes infrastructure on AWS. Using a modular Terraform approach, it creates all necessary components, from networking to storage to observability, providing a complete platform for your containerized applications.

## Features

- **Networking**: Fully-configured VPC with public and private subnets across multiple availability zones
- **Kubernetes**: EKS cluster with managed node groups for simplified management
- **Observability**:
  - Prometheus for metrics collection and alerting
  - Grafana dashboards for visualization with preconfigured admin credentials
- **Ingress Management**:
  - NGINX ingress controller for HTTP/HTTPS traffic routing
  - Automatic integration with Route53 for DNS management
- **Storage**:
  - Amazon EFS for ReadWriteMany persistent storage
  - EFS CSI driver for dynamic provisioning
  - Storage class for Kubernetes PVC claims
- **Security**:
  - IAM roles for service accounts (IRSA)
  - Security groups configured for minimum required access
  - Private subnets for node groups

## Repository Structure

```
AWS-EKS-Terraform/
├── modules/                # Modular Terraform components
│   ├── add-ons/            # Kubernetes add-ons (Prometheus, Grafana, NGINX Ingress)
│   ├── efs/                # EFS storage configuration and CSI driver
│   ├── eks-cluster/        # EKS cluster configuration
│   └── vpc/                # VPC networking configuration
├── main.tf                 # Main Terraform configuration file
├── variables.tf            # Input variable definitions
├── outputs.tf              # Output definitions
├── terraform.tfvars.example # Example variables file
├── README.md               # This documentation
└── .gitignore              # Git ignore file
```

## Prerequisites

- **Terraform**: Version 1.9.x or later
- **AWS CLI**: Version 2.x configured with appropriate credentials
- **kubectl**: Version 1.27+ for Kubernetes management
- **AWS Account**: With permissions to create VPC, EKS, EFS, IAM roles, and Route53 resources
- **Domain Name**: Registered in Route53 for ingress configuration

## Setup and Configuration

1. **Clone the Repository**:
   ```bash
   git clone https://github.com/JoeUzo/AWS-EKS-Terraform.git
   cd AWS-EKS-Terraform
   ```

2. **Configure AWS Credentials**:
   ```bash
   aws configure
   # Or set environment variables
   export AWS_ACCESS_KEY_ID="your-access-key"
   export AWS_SECRET_ACCESS_KEY="your-secret-key"
   export AWS_REGION="us-east-2"
   ```

3. **Create terraform.tfvars File**:
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   # Edit the file with your specific values
   ```

4. **Initialize Terraform**:
   ```bash
   terraform init
   ```

## Terraform Variables

Key variables you'll need to configure:

| Variable | Description | Example |
|----------|-------------|---------|
| `my_region` | AWS region for deployment | `"us-east-2"` |
| `vpc_cidr` | CIDR block for the VPC | `"10.0.0.0/16"` |
| `vpc_public_subnets` | List of public subnet CIDRs | `["10.0.1.0/24", "10.0.2.0/24"]` |
| `vpc_private_subnets` | List of private subnet CIDRs | `["10.0.3.0/24", "10.0.4.0/24"]` |
| `eks_cluster_name` | Name of the EKS cluster | `"my-eks-cluster"` |
| `node_groups_instance_types` | EC2 instance types for nodes | `["t3.medium"]` |
| `grafana_username` | Grafana admin username | `"admin"` |
| `grafana_password` | Grafana admin password | `"StrongPassword123!"` |
| `domain` | Domain name for ingress | `"example.com"` |
| `app_ingress` | Map of applications to expose | See [Application Ingress Configuration](#application-ingress-configuration) |

### Application Ingress Configuration

The `app_ingress` variable is a map where each key is a subdomain and each value is a list containing:
1. The Kubernetes service name
2. The service port
3. The path

Example:
```hcl
app_ingress = {
  "app" = ["my-app-service", 8080, "/"]
}
```

This creates an ingress at `app.example.com` pointing to the `my-app-service` on port 8080.

## Deployment

1. **Plan the Deployment**:
   ```bash
   terraform plan -out=tfplan
   ```

2. **Apply the Configuration**:
   ```bash
   terraform apply tfplan
   ```

3. **Update Kubeconfig**:
   ```bash
   aws eks update-kubeconfig --name <your-cluster-name> --region <your-region>
   ```

4. **Verify Deployment**:
   ```bash
   kubectl get nodes
   kubectl get pods -A
   ```

## Accessing Your Applications

After deployment, your applications will be accessible at the configured domain names, for example:

- Your Application: `https://app.yourdomain.com`
- Grafana Dashboard: `https://grafana.yourdomain.com` (use the credentials from terraform.tfvars)

## Monitoring and Management

### Accessing Grafana

1. Navigate to `https://grafana.yourdomain.com`
2. Log in with your configured credentials
3. Explore the pre-configured dashboards for monitoring your cluster and applications

### Working with EFS Storage

Your EFS file system is automatically configured with:

- A storage class named `efs-sc`
- Dynamic provisioning for persistent volumes

To create a persistent volume claim for your application:

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: app-data
  namespace: app
spec:
  accessModes:
    - ReadWriteMany
  storageClassName: efs-sc
  resources:
    requests:
      storage: 10Gi
```

## Troubleshooting

For common issues, please check:

1. **Ingress Not Working**:
   - Verify DNS records in Route53
   - Check NGINX ingress controller logs: `kubectl logs -n ingress deploy/nginx-ingress-controller`

2. **Storage Issues**:
   - Ensure EFS mount targets are in the correct subnets
   - Check CSI driver logs: `kubectl logs -n kube-system deploy/efs-csi-controller`

3. **Node Group Problems**:
   - Examine node conditions: `kubectl describe nodes`
   - Review autoscaling group in AWS console

## Contributing

Contributions are welcome! Please fork the repository and submit pull requests with improvements or bug fixes. For significant changes, please open an issue first to discuss what you would like to change.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

For the application repository, please visit: [PDF-gpt--RAG-Application](https://github.com/JoeUzo/PDF-gpt--RAG-Application-)

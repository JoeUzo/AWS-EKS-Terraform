terraform {
  required_version = "~> 1.9"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.89"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.36"
    }

    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.17"
    }
  }

  backend "s3" {
    bucket         = "placeholder-bucket"
    key            = "placeholder-key"
    dynamodb_table = "placeholder-lock"
    region         = "us-east-2"
  }

}

provider "aws" {
  region = var.my_region
}
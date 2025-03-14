variable "cluster_name" {
    description = "The name of the EKS cluster."
    type = string
}

variable "grafana_password" {
    description = "The password for the Grafana user."
    type = string
}

variable "domain" {
    description = "The domain name of the EKS cluster."
    type = string
}

variable "cluster_ca" {
    description = "The CA certificate of the EKS cluster."
    type = string
}

variable "cluster_token" {
    description = "The token of the EKS cluster."
    type = string
}

variable "cluster_endpoint" {
    description = "The endpoint of the EKS cluster."
    type = string
}

variable "grafana_username" {
    description = "The username for the Grafana user."
    type = string
    default = "admin"
}

variable "eks_cluster_name" {
    description = "The name of the EKS cluster."
    type = string
}

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

# variable "cluster_ca" {
#     description = "The CA certificate of the EKS cluster."
#     type = string
# }

# variable "cluster_token" {
#     description = "The token of the EKS cluster."
#     type = string
# }

# variable "cluster_endpoint" {
#     description = "The endpoint of the EKS cluster."
#     type = string
# }

variable "grafana_username" {
    description = "The username for the Grafana user."
    type = string
    default = "admin"
}

variable "eks_cluster_name" {
    description = "The name of the EKS cluster."
    type = string
}

variable "lb_additional_tags" {
  description = "Additional tags for the load balancer as a map. Example: { Name = \"nginx-ingress\", Environment = \"production\" }"
  type        = map(string)
  default     = {
    Name        = "nginx-ingress"
    Terraform   = "true"
  }
}

locals {
  lb_additional_tags_string = join("\\,", [for k, v in var.lb_additional_tags : "${k}=${v}"])
}

variable "create_app_ingresses" {
  description = "Create ingresses if true"
  type        = bool
  default     = false
}

variable "ingress_map" {
  description = "Map where the key is the host prefix (e.g. \"app\") and the value is a list with two items: [service_name, port_number, path]."
  type        = map(list(any))
#   example     = {
#     app = ["app-service", 80, "/"]
#   }
  default = {}
}


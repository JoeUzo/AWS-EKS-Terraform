# provider "kubernetes" {
#     host = var.cluster_endpoint
#     cluster_ca_certificate = var.cluster_ca
#     token = var.cluster_token
# }

# provider "helm" {
#   kubernetes {
#     host = var.cluster_endpoint
#     cluster_ca_certificate = var.cluster_ca
#     token = var.cluster_token
#   }
# }


# data "aws_eks_cluster" "cluster" {
#   name = var.cluster_name
# }

# data "aws_eks_cluster_auth" "cluster" {
#   name = var.cluster_name
# }

# provider "kubernetes" {
#   host                   = data.aws_eks_cluster.cluster.endpoint
#   cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
#   token                  = data.aws_eks_cluster_auth.cluster.token
# }

# provider "helm" {
#   kubernetes {
#     host                   = data.aws_eks_cluster.cluster.endpoint
#     cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
#     token                  = data.aws_eks_cluster_auth.cluster.token
#   }
# }



resource "kubernetes_namespace" "monitoring" {
  metadata {
    name = "monitoring"
  }
}

resource "kubernetes_namespace" "ingress" {
  metadata {
    name = "ingress"
  }
}

resource "helm_release" "nginx_ingress" {
  name = "nginx-ingress"
  namespace = kubernetes_namespace.ingress.metadata[0].name
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart = "ingress-nginx"
  version = "4.12.0"
  timeout = 600

  set {
    name  = "controller.admissionWebhooks.enabled"
    value = "false"
  }
}

resource "helm_release" "prometheus" {
  name       = "prometheus"
  namespace  = kubernetes_namespace.monitoring.metadata[0].name
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "prometheus"
  version    = "27.5.1"

  set {
    name  = "server.persistence.enabled"
    value = "true"
  }

  set {
    name  = "server.persistence.storageClass"
    value = "gp2"  # Use your default StorageClass name here
  }

  set {
    name  = "server.persistence.size"
    value = "20Gi"  # Adjust as needed for your requirements
  }
}


resource "helm_release" "grafana" {
  name = "grafana"
  namespace = kubernetes_namespace.monitoring.metadata[0].name
  repository = "https://grafana.github.io/helm-charts"
  chart = "grafana"
  version = "8.10.3"
  timeout = 600

  set {
    name = "admin.password"
    value = var.grafana_password
  }
}

# resource "kubernetes_ingress" "grafana" {
#   metadata {
#     name = "grafana-ingress"
#     namespace = kubernetes_namespace.monitoring.metadata[0].name
#     annotations = {
#       "kubernetes.io/ingress.class" = "nginx"
#       "nginx.ingress.kubernetes.io/rewrite-target" = "/"
#     }
#   }
#   spec {
#     rule {
#       host = "grafana.${var.domain}"
#       http {
#         path {
#           path = "/"
#           backend {
#             service_name = helm_release.grafana.name
#             service_port = 80
#           }
#         }
#       }
#     }
#   }
# }


resource "kubernetes_ingress_v1" "grafana" {
  metadata {
    name      = "grafana-ingress"
    namespace = kubernetes_namespace.monitoring.metadata[0].name
    annotations = {
      "kubernetes.io/ingress.class"                = "nginx"
      "nginx.ingress.kubernetes.io/rewrite-target" = "/"
    }
  }

  spec {
    rule {
      host = "grafana.${var.domain}"
      http {
        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = helm_release.grafana.name
              port {
                number = 80
              }
            }
          }
        }
      }
    }
  }
}

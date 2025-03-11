provider "kubernetes" {
    host = var.cluster_endpoint
    cluster_ca_certificate = var.cluster_ca
    token = var.cluster_token
}

provider "helm" {
  kubernetes {
    host = var.cluster_endpoint
    cluster_ca_certificate = var.cluster_ca
    token = var.cluster_token
  }
}


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
}

resource "helm_release" "prometheus" {
  name = "prometheus"
  namespace = kubernetes_namespace.monitoring.metadata[0].name
  repository = "https://prometheus-community.github.io/helm-charts"
  chart = "prometheus"
  version = "27.5.1"
  timeout = 600
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

resource "kubernetes_ingress" "grafana" {
  metadata {
    name = "grafana-ingress"
    namespace = kubernetes_namespace.monitoring.metadata[0].name
    annotations = {
      "kubernetes.io/ingress.class" = "nginx"
      "nginx.ingress.kubernetes.io/rewrite-target" = "/"
    }
  }
  spec {
    rule {
      host = "grafana.${var.domain}"
      http {
        path {
          path = "/"
          backend {
            service_name = helm_release.grafana.name
            service_port = 80
          }
        }
      }
    }
  }
}





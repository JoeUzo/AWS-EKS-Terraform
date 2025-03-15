# Namespaces
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

resource "kubernetes_namespace" "app" {
  metadata {
    name = "app"
  }
}

# Prometheus
resource "helm_release" "prometheus" {
  name       = "prometheus"
  namespace  = kubernetes_namespace.monitoring.metadata[0].name
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "prometheus"
  version    = "27.5.1"

  set {
    name  = "server.persistentVolume.storageClass"
    value = "gp2"
  }
  
  set {
    name  = "alertmanager.persistence.storageClass"
    value = "gp2"
  }
}


# Grafana
resource "helm_release" "grafana" {
  name = "grafana"
  namespace = kubernetes_namespace.monitoring.metadata[0].name
  repository = "https://grafana.github.io/helm-charts"
  chart = "grafana"
  version = "8.10.3"

  set {
    name = "adminUser"
    value = var.grafana_username
  }
  set {
    name = "adminPassword"
    value = var.grafana_password
  }
}

# Ingress for nginx
resource "helm_release" "nginx_ingress" {
  name       = "nginx-ingress"
  namespace  = kubernetes_namespace.ingress.metadata[0].name
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  version    = "4.12.0"

  set {
    name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-type"
    value = "nlb"
  }
  
  set {
    name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-scheme"
    value = "internet-facing"
  }
  
  set {
    name  = "controller.admissionWebhooks.enabled"
    value = "false"
  }

  # Add tags to the AWS Load Balancer
  set {
    name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-additional-resource-tags"
    value = local.lb_additional_tags_string
  }
}


# Ingress for grafana
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


# Route53 for grafana
data "aws_route53_zone" "existing" {
  name = var.domain
}

data "aws_lb" "nginx_ingress" {
  tags = var.lb_additional_tags
  depends_on = [ helm_release.nginx_ingress ]
}

resource "aws_route53_record" "grafana" {
  zone_id = data.aws_route53_zone.existing.zone_id
  name    = "grafana.${var.domain}"
  type    = "A"

  alias {
    name                   = data.aws_lb.nginx_ingress.dns_name
    zone_id                = data.aws_lb.nginx_ingress.zone_id
    evaluate_target_health = true
  }
}


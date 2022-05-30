locals {
  alertmanager_host = "alertmanager.${var.host}"
  grafana_host      = "newgrafana.${var.host}"
  prometheus_host   = "prometheus.${var.host}"
}

resource "kubernetes_namespace" "monitoring" {
  metadata {
    name = "monitoring"
  }
}

resource "helm_release" "prometheus" {
  name             = "kube-prometheus-stack"
  repository       = "https://prometheus-community.github.io/helm-charts"
  chart            = "kube-prometheus-stack"
  namespace        = kubernetes_namespace.monitoring.metadata[0].name
  version          = "v35.2.0"
  atomic           = true

  values = [
    file("../kubernetes/releases/kube-prometheus-stack.yaml")
  ]

  set {
    name  = "alertmanager.ingress.hosts[0]"
    value = local.alertmanager_host
  }

  set {
    name  = "alertmanager.ingress.tls[0].hosts[0]"
    value = local.alertmanager_host
  }

  set {
    name  = "alertmanager.ingress.annotations.nginx\\.ingress\\.kubernetes\\.io/auth-url"
    value = local.auth_url
  }

  set {
    name  = "alertmanager.ingress.annotations.nginx\\.ingress\\.kubernetes\\.io/auth-signin"
    value = local.auth_signin
  }

  set {
    name  = "grafana.ingress.hosts[0]"
    value = local.grafana_host
  }

  set {
    name  = "grafana.ingress.tls[0].hosts[0]"
    value = local.grafana_host
  }

  set {
    name  = "prometheus.ingress.hosts[0]"
    value = local.prometheus_host
  }

  set {
    name  = "prometheus.ingress.tls[0].hosts[0]"
    value = local.prometheus_host
  }

  set {
    name  = "prometheus.ingress.annotations.nginx\\.ingress\\.kubernetes\\.io/auth-url"
    value = local.auth_url
  }

  set {
    name  = "prometheus.ingress.annotations.nginx\\.ingress\\.kubernetes\\.io/auth-signin"
    value = local.auth_signin
  }

  depends_on = [
    kubernetes_namespace.monitoring
  ]
}

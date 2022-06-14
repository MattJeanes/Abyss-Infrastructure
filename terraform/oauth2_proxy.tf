locals {
  auth_host   = "auth.${var.host}"
  auth_url    = "http://${helm_release.oauth2_proxy.name}.${helm_release.oauth2_proxy.namespace}.svc.cluster.local/oauth2/auth"
  auth_signin = "https://${local.auth_host}/oauth2/start?rd=$scheme://$host$request_uri"
}

resource "kubernetes_namespace" "oauth2_proxy" {
  metadata {
    name = "oauth2-proxy"
  }
}

resource "helm_release" "oauth2_proxy" {
  # https://artifacthub.io/packages/helm/oauth2-proxy/oauth2-proxy
  name             = "oauth2-proxy"
  repository       = "https://oauth2-proxy.github.io/manifests"
  chart            = "oauth2-proxy"
  namespace        = kubernetes_namespace.oauth2_proxy.metadata[0].name
  version          = "6.2.1"
  atomic           = true

  values = [
    file("../kubernetes/releases/oauth2-proxy.yaml")
  ]

  set {
    name  = "config.clientID"
    value = var.oauth2_client_id
  }

  set {
    name  = "config.clientSecret"
    value = var.oauth2_client_secret
  }

  set {
    name  = "config.cookieSecret"
    value = var.oauth2_cookie_secret
  }

  set {
    name  = "authenticatedEmailsFile.restricted_access"
    value = var.email
  }

  set {
    name  = "ingress.hosts[0]"
    value = local.auth_host
  }

  set {
    name  = "ingress.tls[0].hosts[0]"
    value = local.auth_host
  }

  set {
    name  = "extraArgs.whitelist-domain"
    value = ".${var.host}"
  }

  set {
    name  = "extraArgs.cookie-domain"
    value = ".${var.host}"
  }

  depends_on = [
    kubernetes_namespace.oauth2_proxy
  ]
}

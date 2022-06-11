resource "kubernetes_namespace" "certmanager" {
  metadata {
    name = "cert-manager"
  }
}

resource "helm_release" "certmanager" {
  name             = "cert-manager"
  repository       = "https://charts.jetstack.io"
  chart            = "cert-manager"
  namespace        = kubernetes_namespace.certmanager.metadata[0].name
  version          = "v1.8.0"
  atomic           = true

  values = [
    file("../kubernetes/releases/cert-manager.yaml")
  ]

  depends_on = [
    kubernetes_namespace.certmanager
  ]
}

resource "helm_release" "certificates" {
  name      = "certificates"
  chart     = "../kubernetes/certificates"
  namespace = kubernetes_namespace.certmanager.metadata[0].name
  version   = "1.0.0"
  atomic    = true

  set {
    name  = "letsEncrypt.email"
    value = var.email
  }

  depends_on = [
    helm_release.certmanager
  ]
}

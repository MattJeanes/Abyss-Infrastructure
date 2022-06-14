resource "kubernetes_namespace" "vpa" {
  metadata {
    name = "vpa"
  }
}

resource "helm_release" "vpa" {
  # https://artifacthub.io/packages/helm/fairwinds-stable/vpa
  name             = "vpa"
  repository       = "https://charts.fairwinds.com/stable"
  chart            = "vpa"
  namespace        = kubernetes_namespace.vpa.metadata[0].name
  version          = "1.4.0"
  atomic           = true

  values = [
    file("../kubernetes/releases/vpa.yaml")
  ]

  depends_on = [
    kubernetes_namespace.vpa,
    helm_release.prometheus
  ]
}

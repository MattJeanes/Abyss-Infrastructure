resource "kubernetes_namespace" "nginx" {
  metadata {
    name = "ingress-nginx"
  }
}

resource "helm_release" "nginx" {
  # https://artifacthub.io/packages/helm/ingress-nginx/ingress-nginx
  name             = "ingress-nginx"
  repository       = "https://kubernetes.github.io/ingress-nginx"
  chart            = "ingress-nginx"
  namespace        = kubernetes_namespace.nginx.metadata[0].name
  version          = "4.1.4"
  atomic           = true

  values = [
    file("../kubernetes/releases/ingress-nginx.yaml")
  ]

  set {
    name  = "controller.service.loadBalancerIP"
    value = azurerm_public_ip.abyss_public.ip_address
  }

  depends_on = [
    kubernetes_namespace.nginx
  ]
}

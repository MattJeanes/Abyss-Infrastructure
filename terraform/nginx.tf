resource "helm_release" "nginx" {
  name             = "ingress-nginx"
  repository       = "https://kubernetes.github.io/ingress-nginx"
  chart            = "ingress-nginx"
  namespace        = "ingress-nginx"
  version          = "v4.1.0"
  atomic           = true
  create_namespace = true

  values = [
    file("../kubernetes/releases/ingress-nginx.yaml")
  ]

  set {
    name  = "controller.service.loadBalancerIP"
    value = azurerm_public_ip.abyss_public.ip_address
  }
}

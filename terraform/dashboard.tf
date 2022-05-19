resource "helm_release" "dashboard" {
  name             = "kubernetes-dashboard"
  repository       = "https://kubernetes.github.io/dashboard"
  chart            = "kubernetes-dashboard"
  namespace        = "dashboard"
  version          = "v5.4.1"
  atomic           = true
  create_namespace = true

  values = [
    file("../kubernetes/releases/kubernetes-dashboard.yaml")
  ]

  set {
    name  = "ingress.hosts[0]"
    value = var.dashboard_host
  }

  set {
    name  = "ingress.tls[0].hosts[0]"
    value = var.dashboard_host
  }

  provisioner "local-exec" {
    command     = "WaitKubeCertificate.ps1 -Name 'dashboard-tls' -Namespace 'dashboard'"
    interpreter = ["pwsh", "-Command"]
    working_dir = "../scripts"
  }
}

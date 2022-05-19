resource "helm_release" "prometheus" {
  name             = "kube-prometheus-stack"
  repository       = "https://prometheus-community.github.io/helm-charts"
  chart            = "kube-prometheus-stack"
  namespace        = "monitoring"
  version          = "v35.2.0"
  atomic           = true
  create_namespace = true

  values = [
    file("../kubernetes/releases/kube-prometheus-stack.yaml")
  ]
}

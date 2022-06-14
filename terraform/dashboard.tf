locals {
  dashboard_host = "kubedashboard.${var.host}"
}

resource "kubernetes_namespace" "dashboard" {
  metadata {
    name = "dashboard"
  }
}

resource "helm_release" "dashboard" {
  # https://artifacthub.io/packages/helm/k8s-dashboard/kubernetes-dashboard
  name       = "kubernetes-dashboard"
  repository = "https://kubernetes.github.io/dashboard"
  chart      = "kubernetes-dashboard"
  namespace  = kubernetes_namespace.dashboard.metadata[0].name
  version    = "5.7.0"
  atomic     = true

  values = [
    file("../kubernetes/releases/kubernetes-dashboard.yaml")
  ]

  set {
    name  = "ingress.hosts[0]"
    value = local.dashboard_host
  }

  set {
    name  = "ingress.tls[0].hosts[0]"
    value = local.dashboard_host
  }

  set {
    name  = "ingress.annotations.nginx\\.ingress\\.kubernetes\\.io/configuration-snippet"
    value = "proxy_set_header Authorization \"Bearer ${data.kubernetes_secret.dashboard.data.token}\";"
  }

  set {
    name  = "ingress.annotations.nginx\\.ingress\\.kubernetes\\.io/auth-url"
    value = local.auth_url
  }

  set {
    name  = "ingress.annotations.nginx\\.ingress\\.kubernetes\\.io/auth-signin"
    value = local.auth_signin
  }

  provisioner "local-exec" {
    command     = "./WaitKubeCertificate.ps1 -Name 'dashboard-tls' -Namespace 'dashboard'"
    interpreter = ["pwsh", "-Command"]
    working_dir = "../scripts"
  }

  depends_on = [
    null_resource.aks_login,
    kubernetes_namespace.dashboard
  ]
}

resource "kubernetes_service_account" "dashboard" {
  metadata {
    name      = "admin-user"
    namespace = kubernetes_namespace.dashboard.metadata[0].name
  }
}

resource "kubernetes_cluster_role_binding" "dashboard" {
  metadata {
    name = "admin-user"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-admin"
  }
  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.dashboard.metadata[0].name
    namespace = kubernetes_namespace.dashboard.metadata[0].name
  }

  depends_on = [
    kubernetes_service_account.dashboard
  ]
}

data "kubernetes_service_account" "dashboard" {
  metadata {
    name      = kubernetes_service_account.dashboard.metadata[0].name
    namespace = kubernetes_namespace.dashboard.metadata[0].name
  }

  depends_on = [
    kubernetes_service_account.dashboard
  ]
}

data "kubernetes_secret" "dashboard" {
  metadata {
    name      = data.kubernetes_service_account.dashboard.default_secret_name
    namespace = kubernetes_namespace.dashboard.metadata[0].name
  }
}

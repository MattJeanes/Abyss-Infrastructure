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

resource "kubernetes_manifest" "cluster_issuer_letsencrypt_staging" {
  manifest = {
    "apiVersion" = "cert-manager.io/v1"
    "kind"       = "ClusterIssuer"
    "metadata" = {
      "name"      = "letsencrypt-staging"
    }
    "spec" = {
      "acme" = {
        "server" = "https://acme-staging-v02.api.letsencrypt.org/directory"
        "email"  = var.email
        "privateKeySecretRef" = {
          "name" = "letsencrypt-staging"
        }
        "solvers" = [
          {
            "http01" = {
              "ingress" = {
                "class" = "nginx"
              }
            }
          }
        ]
      }
    }
  }

  depends_on = [
    helm_release.certmanager
  ]
}

resource "kubernetes_manifest" "cluster_issuer_letsencrypt_prod" {
  manifest = {
    "apiVersion" = "cert-manager.io/v1"
    "kind"       = "ClusterIssuer"
    "metadata" = {
      "name"      = "letsencrypt-prod"
    }
    "spec" = {
      "acme" = {
        "server" = "https://acme-v02.api.letsencrypt.org/directory"
        "email"  = var.email
        "privateKeySecretRef" = {
          "name" = "letsencrypt-prod"
        }
        "solvers" = [
          {
            "http01" = {
              "ingress" = {
                "class" = "nginx"
              }
            }
          }
        ]
      }
    }
  }

  depends_on = [
    helm_release.certmanager
  ]
}

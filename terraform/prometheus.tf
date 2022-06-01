locals {
  alertmanager_host = "alertmanager.${var.host}"
  grafana_host      = "newgrafana.${var.host}"
  prometheus_host   = "prometheus.${var.host}"
}

resource "azurerm_managed_disk" "prometheus" {
  name                 = "prometheus"
  location             = azurerm_resource_group.abyss.location
  resource_group_name  = azurerm_resource_group.abyss.name
  storage_account_type = "StandardSSD_LRS"
  create_option        = "Empty"
  disk_size_gb         = 4
}

resource "kubernetes_persistent_volume" "prometheus" {
  metadata {
    name = "prometheus"
  }
  spec {
    capacity = {
      storage = "4Gi"
    }
    access_modes                     = ["ReadWriteOnce"]
    persistent_volume_reclaim_policy = "Retain"
    storage_class_name               = "managed-csi"
    persistent_volume_source {
      csi {
        driver        = "disk.csi.azure.com"
        read_only     = false
        volume_handle = azurerm_managed_disk.prometheus.id
        volume_attributes = {
          "fsType" = "ext4"
        }
      }
    }
  }
}

resource "azurerm_managed_disk" "alertmanager" {
  name                 = "alertmanager"
  location             = azurerm_resource_group.abyss.location
  resource_group_name  = azurerm_resource_group.abyss.name
  storage_account_type = "StandardSSD_LRS"
  create_option        = "Empty"
  disk_size_gb         = 4
}

resource "kubernetes_persistent_volume" "alertmanager" {
  metadata {
    name = "alertmanager"
  }
  spec {
    capacity = {
      storage = "4Gi"
    }
    access_modes                     = ["ReadWriteOnce"]
    persistent_volume_reclaim_policy = "Retain"
    storage_class_name               = "managed-csi"
    persistent_volume_source {
      csi {
        driver        = "disk.csi.azure.com"
        read_only     = false
        volume_handle = azurerm_managed_disk.alertmanager.id
        volume_attributes = {
          "fsType" = "ext4"
        }
      }
    }
  }
}

resource "kubernetes_namespace" "monitoring" {
  metadata {
    name = "monitoring"
  }
}

resource "helm_release" "prometheus" {
  name       = "kube-prometheus-stack"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  namespace  = kubernetes_namespace.monitoring.metadata[0].name
  version    = "v35.2.0"
  atomic     = true

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
    name  = "alertmanager.alertmanagerSpec.storage.volumeClaimTemplate.spec.volumeName"
    value = kubernetes_persistent_volume.alertmanager.metadata[0].name
  }

  set {
    name  = "alertmanager.alertmanagerSpec.storage.volumeClaimTemplate.spec.resources.requests.storage"
    value = kubernetes_persistent_volume.alertmanager.spec[0].capacity.storage
  }

  set {
    name  = "alertmanager.alertmanagerSpec.storage.volumeClaimTemplate.spec.accessModes[0]"
    value = tolist(kubernetes_persistent_volume.alertmanager.spec[0].access_modes)[0]
  }

  set {
    name  = "alertmanager.alertmanagerSpec.storage.volumeClaimTemplate.spec.storageClassName"
    value = kubernetes_persistent_volume.alertmanager.spec[0].storage_class_name
  }

  set {
    name  = "alertmanager.config.global.pagerduty_url"
    value = var.pagerduty_url
  }

  set {
    name  = "alertmanager.config.receivers[0].pagerduty_configs[0].routing_key"
    value = var.pagerduty_integration_key
  }

  set {
    name  = "alertmanager.config.receivers[1].webhook_configs[0].url"
    value = var.dead_mans_snitch_webhook_url
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
    name  = "grafana.adminPassword"
    value = var.grafana_admin_password
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

  set {
    name  = "prometheus.prometheusSpec.storageSpec.volumeClaimTemplate.spec.volumeName"
    value = kubernetes_persistent_volume.prometheus.metadata[0].name
  }

  set {
    name  = "prometheus.prometheusSpec.storageSpec.volumeClaimTemplate.spec.resources.requests.storage"
    value = kubernetes_persistent_volume.prometheus.spec[0].capacity.storage
  }

  set {
    name  = "prometheus.prometheusSpec.storageSpec.volumeClaimTemplate.spec.accessModes[0]"
    value = tolist(kubernetes_persistent_volume.prometheus.spec[0].access_modes)[0]
  }

  set {
    name  = "prometheus.prometheusSpec.storageSpec.volumeClaimTemplate.spec.storageClassName"
    value = kubernetes_persistent_volume.prometheus.spec[0].storage_class_name
  }

  depends_on = [
    kubernetes_namespace.monitoring
  ]
}

resource "azurerm_managed_disk" "teamspeak" {
  name                 = "teamspeak"
  location             = azurerm_resource_group.abyss.location
  resource_group_name  = azurerm_resource_group.abyss.name
  storage_account_type = "StandardSSD_LRS"
  create_option        = "Empty"
  disk_size_gb         = 4
}

resource "kubernetes_persistent_volume" "teamspeak" {
  metadata {
    name = "teamspeak"
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
        volume_handle = azurerm_managed_disk.teamspeak.id
        volume_attributes = {
          "fsType" = "ext4"
        }
      }
    }
  }
}

resource "kubernetes_persistent_volume_claim" "teamspeak" {
  metadata {
    name = "teamspeak"
  }
  spec {
    access_modes = kubernetes_persistent_volume.teamspeak.spec[0].access_modes
    resources {
      requests = {
        storage = kubernetes_persistent_volume.teamspeak.spec[0].capacity.storage
      }
    }
    volume_name        = kubernetes_persistent_volume.teamspeak.metadata.0.name
    storage_class_name = kubernetes_persistent_volume.teamspeak.spec[0].storage_class_name
  }
}

resource "helm_release" "teamspeak" {
  # https://artifacthub.io/packages/helm/k8s-at-home/teamspeak
  name             = "teamspeak"
  repository       = "https://k8s-at-home.com/charts"
  chart            = "teamspeak"
  namespace        = "default"
  version          = "0.5.2"
  atomic           = true

  values = [
    file("../kubernetes/releases/teamspeak.yaml")
  ]

  set {
    name  = "service.main.loadBalancerIP"
    value = azurerm_public_ip.abyss_public.ip_address
  }

  set {
    name  = "service.udp.loadBalancerIP"
    value = azurerm_public_ip.abyss_public.ip_address
  }

  set {
    name = "env.TS3SERVER_SERVERADMIN_PASSWORD"
    value = var.teamspeak_serveradmin_password
  }

  set {
    name = "env.TS3SERVER_DB_PASSWORD"
    value = var.teamspeak_database_password
  }

  depends_on = [
    helm_release.mariadb,
    kubernetes_persistent_volume_claim.teamspeak
  ]
}
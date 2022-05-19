resource "azurerm_managed_disk" "mariadb" {
  name                 = "mariadb"
  location             = azurerm_resource_group.abyss.location
  resource_group_name  = azurerm_resource_group.abyss.name
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = "1"
  tags = {
    environment = azurerm_resource_group.abyss.name
  }
}

resource "kubernetes_persistent_volume" "mariadb" {
  metadata {
    name = "mariadb"
  }
  spec {
    capacity = {
      storage = "1Gi"
    }
    access_modes                     = ["ReadWriteOnce"]
    persistent_volume_reclaim_policy = "Retain"
    storage_class_name               = "managed-csi"
    persistent_volume_source {
      csi {
        driver        = "disk.csi.azure.com"
        read_only     = false
        volume_handle = azurerm_managed_disk.mariadb.id
        volume_attributes = {
          "fsType" = "ext4"
        }
      }
    }
  }
}

resource "kubernetes_persistent_volume_claim" "mariadb" {
  metadata {
    name = "mariadb"
  }
  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = "1Gi"
      }
    }
    volume_name        = kubernetes_persistent_volume.mariadb.metadata.0.name
    storage_class_name = "managed-csi"
  }
}

resource "helm_release" "mariadb" {
  name       = "mariadb"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "mariadb"
  namespace  = "default"
  version    = "11.0.4"
  atomic     = true

  values = [
    file("../kubernetes/releases/mariadb.yaml")
  ]

  set {
    name  = "auth.rootPassword"
    value = var.mariadb_root_password
  }

  depends_on = [
    azurerm_role_assignment.aks_abyss_diskaccess
  ]
}

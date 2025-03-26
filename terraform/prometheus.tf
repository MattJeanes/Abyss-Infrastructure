resource "azurerm_managed_disk" "prometheus" {
  provider             = azurerm.old
  name                 = "prometheus"
  location             = azurerm_resource_group.abyss.location
  resource_group_name  = azurerm_resource_group.abyss.name
  storage_account_type = "StandardSSD_LRS"
  create_option        = "Empty"
  disk_size_gb         = 8

  lifecycle {
    prevent_destroy = true
  }
}

output "prometheus_disk_id" {
  value     = azurerm_managed_disk.prometheus.id
  sensitive = true
}

resource "azurerm_managed_disk" "alertmanager" {
  provider             = azurerm.old
  name                 = "alertmanager"
  location             = azurerm_resource_group.abyss.location
  resource_group_name  = azurerm_resource_group.abyss.name
  storage_account_type = "StandardSSD_LRS"
  create_option        = "Empty"
  disk_size_gb         = 4

  lifecycle {
    prevent_destroy = true
  }
}

output "alertmanager_disk_id" {
  value     = azurerm_managed_disk.alertmanager.id
  sensitive = true
}

resource "azurerm_storage_share" "abyss_grafana" {
  provider           = azurerm.old
  name               = "grafana"
  storage_account_id = azurerm_storage_account.abyss.id
  quota              = 1

  lifecycle {
    prevent_destroy = true
  }
}

resource "azurerm_managed_disk" "prometheus" {
  name                 = "prometheus"
  location             = azurerm_resource_group.abyss.location
  resource_group_name  = azurerm_resource_group.abyss.name
  storage_account_type = "StandardSSD_LRS"
  create_option        = "Empty"
  disk_size_gb         = 4
}

output "prometheus_disk_id" {
  value = azurerm_managed_disk.prometheus.id
  sensitive = true
}

resource "azurerm_managed_disk" "alertmanager" {
  name                 = "alertmanager"
  location             = azurerm_resource_group.abyss.location
  resource_group_name  = azurerm_resource_group.abyss.name
  storage_account_type = "StandardSSD_LRS"
  create_option        = "Empty"
  disk_size_gb         = 4
}

output "alertmanager_disk_id" {
  value = azurerm_managed_disk.alertmanager.id
  sensitive = true
}

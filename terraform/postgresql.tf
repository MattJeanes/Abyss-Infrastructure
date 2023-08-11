resource "azurerm_managed_disk" "postgresql" {
  name                 = "postgresql"
  location             = azurerm_resource_group.abyss.location
  resource_group_name  = azurerm_resource_group.abyss.name
  storage_account_type = "StandardSSD_LRS"
  create_option        = "Empty"
  disk_size_gb         = 8

  lifecycle {
    prevent_destroy = true
  }
}

output "postgresql_disk_id" {
  value     = azurerm_managed_disk.postgresql.id
  sensitive = true
}

resource "azurerm_role_assignment" "postgresql_disk_backup_reader" {
  scope                = azurerm_managed_disk.postgresql.id
  role_definition_name = "Disk Backup Reader"
  principal_id         = azurerm_data_protection_backup_vault.main.identity[0].principal_id
}

resource "azurerm_data_protection_backup_instance_disk" "postgresql" {
  name                         = azurerm_managed_disk.postgresql.name
  disk_id                      = azurerm_managed_disk.postgresql.id
  location                     = azurerm_data_protection_backup_vault.main.location
  vault_id                     = azurerm_data_protection_backup_vault.main.id
  snapshot_resource_group_name = azurerm_resource_group.snapshots.name
  backup_policy_id             = azurerm_data_protection_backup_policy_disk.main.id

  depends_on = [
    azurerm_role_assignment.postgresql_disk_backup_reader
  ]
}

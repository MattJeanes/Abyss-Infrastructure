resource "azurerm_resource_group" "snapshots" {
  provider = azurerm.old
  name     = "abyss_snapshots"
  location = "northeurope"

  lifecycle {
    prevent_destroy = true
  }
}

resource "azurerm_data_protection_backup_vault" "main" {
  provider            = azurerm.old
  name                = "backup-vault"
  resource_group_name = azurerm_resource_group.abyss.name
  location            = azurerm_resource_group.abyss.location
  datastore_type      = "VaultStore"
  redundancy          = "LocallyRedundant"
  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_role_assignment" "snapshots_disk_snapshot_contributor" {
  provider             = azurerm.old
  scope                = azurerm_resource_group.snapshots.id
  role_definition_name = "Disk Snapshot Contributor"
  principal_id         = azurerm_data_protection_backup_vault.main.identity[0].principal_id
}

resource "azurerm_data_protection_backup_policy_disk" "main" {
  provider = azurerm.old
  name     = "disk-backup-policy"
  vault_id = azurerm_data_protection_backup_vault.main.id

  backup_repeating_time_intervals = ["R/2022-01-01T07:00:00+00:00/P1D"]
  default_retention_duration      = "P7D"

  depends_on = [
    azurerm_role_assignment.snapshots_disk_snapshot_contributor
  ]
}

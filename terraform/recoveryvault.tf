resource "azurerm_recovery_services_vault" "vault" {
  provider            = azurerm.old
  name                = "recovery-vault"
  location            = azurerm_resource_group.abyss.location
  resource_group_name = azurerm_resource_group.abyss.name
  sku                 = "Standard"
  storage_mode_type   = "LocallyRedundant"
}

resource "azurerm_backup_policy_file_share" "vault" {
  provider            = azurerm.old
  name                = "recovery-vault-policy"
  resource_group_name = azurerm_resource_group.abyss.name
  recovery_vault_name = azurerm_recovery_services_vault.vault.name

  backup {
    frequency = "Daily"
    time      = "07:00"
  }

  retention_daily {
    count = 7
  }
}

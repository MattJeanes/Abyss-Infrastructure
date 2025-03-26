resource "azurerm_storage_share" "abyss_teamspeak" {
  name               = "teamspeak"
  storage_account_id = azurerm_storage_account.abyss.id
  quota              = 20

  lifecycle {
    prevent_destroy = true
  }
}

resource "azurerm_backup_protected_file_share" "abyss_teamspeak" {
  resource_group_name       = azurerm_resource_group.abyss.name
  recovery_vault_name       = azurerm_recovery_services_vault.vault.name
  source_storage_account_id = azurerm_backup_container_storage_account.abyss.storage_account_id
  source_file_share_name    = azurerm_storage_share.abyss_teamspeak.name
  backup_policy_id          = azurerm_backup_policy_file_share.vault.id
}

resource "azurerm_storage_share" "abyss_teamspeak_alt" {
  name               = "teamspeak-alt"
  storage_account_id = azurerm_storage_account.abyss.id
  quota              = 20

  lifecycle {
    prevent_destroy = true
  }
}

resource "azurerm_storage_share" "abyss_sinusbot" {
  name               = "sinusbot"
  storage_account_id = azurerm_storage_account.abyss.id
  quota              = 10

  lifecycle {
    prevent_destroy = true
  }
}

resource "azurerm_backup_protected_file_share" "abyss_sinusbot" {
  resource_group_name       = azurerm_resource_group.abyss.name
  recovery_vault_name       = azurerm_recovery_services_vault.vault.name
  source_storage_account_id = azurerm_backup_container_storage_account.abyss.storage_account_id
  source_file_share_name    = azurerm_storage_share.abyss_sinusbot.name
  backup_policy_id          = azurerm_backup_policy_file_share.vault.id
}

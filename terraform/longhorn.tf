resource "azurerm_storage_container" "abyss_longhorn" {
  provider              = azurerm.old
  name                  = "longhorn"
  storage_account_id    = azurerm_storage_account.abyss.id
  container_access_type = "private"

  lifecycle {
    prevent_destroy = true
  }
}

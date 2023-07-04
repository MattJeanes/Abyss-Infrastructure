resource "azurerm_storage_share" "abyss_youtransfer" {
  name                 = "youtransfer"
  storage_account_name = azurerm_storage_account.abyss.name
  quota                = 1

  lifecycle {
    prevent_destroy = true
  }
}

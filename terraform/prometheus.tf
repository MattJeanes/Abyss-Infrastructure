resource "azurerm_storage_share" "abyss_grafana" {
  name               = "grafana"
  storage_account_id = azurerm_storage_account.abyss.id
  quota              = 1

  lifecycle {
    prevent_destroy = true
  }
}

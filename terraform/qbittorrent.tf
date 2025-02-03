resource "azurerm_storage_share" "abyss_qbittorrent_config" {
  name               = "qbittorrent-config"
  storage_account_id = azurerm_storage_account.abyss.id
  quota              = 1

  lifecycle {
    prevent_destroy = true
  }
}

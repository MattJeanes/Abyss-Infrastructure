resource "azurerm_storage_share" "abyss_qbittorrent_config" {
  name                 = "qbittorrent-config"
  storage_account_name = azurerm_storage_account.abyss.name
  quota                = 1

  lifecycle {
    prevent_destroy = true
  }
}

resource "azurerm_storage_share" "abyss_qbittorrent_downloads" {
  name                 = "qbittorrent-downloads"
  storage_account_name = azurerm_storage_account.abyss.name
  quota                = 100

  lifecycle {
    prevent_destroy = true
  }
}

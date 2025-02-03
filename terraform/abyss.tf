resource "azurerm_storage_share" "abyss_models" {
  name               = "models"
  storage_account_id = azurerm_storage_account.abyss.id
  quota              = 1

  lifecycle {
    prevent_destroy = true
  }
}

resource "azurerm_storage_share" "abyss_gpt" {
  name               = "gpt"
  storage_account_id = azurerm_storage_account.abyss.id
  quota              = 10

  lifecycle {
    prevent_destroy = true
  }
}

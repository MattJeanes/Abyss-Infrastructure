resource "azurerm_storage_account" "abyss" {
  name                     = "abyss"
  resource_group_name      = azurerm_resource_group.abyss.name
  location                 = azurerm_resource_group.abyss.location
  account_kind             = "StorageV2"
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_share" "abyss_models" {
  name                 = "models"
  storage_account_name = azurerm_storage_account.abyss.name
  quota                = "1"
}

resource "azurerm_storage_share" "abyss_gpt" {
  name                 = "gpt"
  storage_account_name = azurerm_storage_account.abyss.name
  quota                = "10"
}

resource "kubernetes_secret" "name" {
  metadata {
    name = "azure-storage-account"
  }

  data = {
    azurestorageaccountname = azurerm_storage_account.abyss.name
    azurestorageaccountkey  = azurerm_storage_account.abyss.primary_access_key
  }

  type = "Opaque"
}

resource "azurerm_resource_group" "abyss" {
  provider = azurerm.old
  name     = "abyss"
  location = "northeurope"

  lifecycle {
    prevent_destroy = true
  }
}

output "resource_group_name" {
  value = azurerm_resource_group.abyss.name
}

output "resource_group_location" {
  value = azurerm_resource_group.abyss.location
}

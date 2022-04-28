resource "azurerm_resource_group" "abyss" {
  name     = "abyss"
  location = "northeurope"

  lifecycle {
    prevent_destroy = true
  }
}

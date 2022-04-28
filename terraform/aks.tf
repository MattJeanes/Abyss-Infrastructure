resource "azurerm_kubernetes_cluster" "abyss" {
  name = "abyss"
  resource_group_name = azurerm_resource_group.abyss.name
  location = azurerm_resource_group.abyss.location
}
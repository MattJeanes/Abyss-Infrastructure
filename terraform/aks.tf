resource "azurerm_kubernetes_cluster" "abyss" {
  name = "abyss"
  resource_group_name = azurerm_resource_group.abyss.name
  location = azurerm_resource_group.abyss.location
  dns_prefix = "abyss-dns"

  identity {
    type = "SystemAssigned"
  }

  default_node_pool {
    name       = "default"
    enable_auto_scaling = true
    min_count = 1
    max_count = 5
    vm_size    = "Standard_B2s"
  }
}
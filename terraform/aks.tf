resource "azurerm_kubernetes_cluster" "abyss" {
  name                = "abyss"
  resource_group_name = azurerm_resource_group.abyss.name
  location            = azurerm_resource_group.abyss.location
  dns_prefix          = "abyss-dns"

  identity {
    type = "SystemAssigned"
  }

  default_node_pool {
    name                = "agentpool"
    enable_auto_scaling = true
    min_count           = 1
    max_count           = 5
    vm_size             = "Standard_B2s"
    vnet_subnet_id      = azurerm_subnet.abyss_aks.id
  }

  aci_connector_linux {
    subnet_name = "aci"
  }
}

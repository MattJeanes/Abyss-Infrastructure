resource "azurerm_virtual_network" "abyss" {
  name                = "abyss-vnet"
  resource_group_name = azurerm_resource_group.abyss.name
  location            = azurerm_resource_group.abyss.location
  address_space       = ["10.0.0.0/8"]
}

resource "azurerm_subnet" "abyss_default" {
  name                 = "default"
  virtual_network_name = azurerm_virtual_network.abyss.name
  resource_group_name  = azurerm_virtual_network.abyss.resource_group_name
  address_prefixes     = ["10.0.0.0/24"]
}

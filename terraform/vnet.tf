resource "azurerm_virtual_network" "abyss" {
  provider            = azurerm.old
  name                = "abyss-vnet"
  resource_group_name = azurerm_resource_group.abyss.name
  location            = azurerm_resource_group.abyss.location
  address_space       = ["10.0.0.0/8"]
}

resource "azurerm_subnet" "abyss_default" {
  provider             = azurerm.old
  name                 = "default"
  virtual_network_name = azurerm_virtual_network.abyss.name
  resource_group_name  = azurerm_virtual_network.abyss.resource_group_name
  address_prefixes     = ["10.0.0.0/24"]
}

resource "azurerm_subnet" "abyss_aks" {
  provider             = azurerm.old
  name                 = "aks"
  virtual_network_name = azurerm_virtual_network.abyss.name
  resource_group_name  = azurerm_virtual_network.abyss.resource_group_name
  address_prefixes     = ["10.1.0.0/16"]
}

resource "azurerm_subnet" "abyss_aci" {
  provider             = azurerm.old
  name                 = "aci"
  virtual_network_name = azurerm_virtual_network.abyss.name
  resource_group_name  = azurerm_virtual_network.abyss.resource_group_name
  address_prefixes     = ["10.2.0.0/16"]

  delegation {
    name = "aciDelegation"

    service_delegation {
      name = "Microsoft.ContainerInstance/containerGroups"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/action"
      ]
    }
  }
}

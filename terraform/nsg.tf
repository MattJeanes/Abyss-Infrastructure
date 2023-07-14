resource "azurerm_network_security_group" "abyss" {
  name                = "abyss-nsg"
  resource_group_name = azurerm_resource_group.abyss.name
  location            = azurerm_resource_group.abyss.location
}

resource "azurerm_network_security_rule" "abyss_home" {
  network_security_group_name = azurerm_network_security_group.abyss.name
  resource_group_name         = azurerm_network_security_group.abyss.resource_group_name

  name                       = "Home"
  priority                   = 300
  direction                  = "Inbound"
  access                     = "Allow"
  protocol                   = "*"
  source_address_prefix      = var.home_ip
  source_port_range          = "*"
  destination_address_prefix = "*"
  destination_port_range     = "*"
}

resource "azurerm_network_security_rule" "abyss_http" {
  network_security_group_name = azurerm_network_security_group.abyss.name
  resource_group_name         = azurerm_network_security_group.abyss.resource_group_name

  name                       = "HTTP"
  priority                   = 310
  direction                  = "Inbound"
  access                     = "Allow"
  protocol                   = "Tcp"
  source_address_prefix      = "*"
  source_port_range          = "*"
  destination_address_prefix = "*"
  destination_port_range     = "80"
}

resource "azurerm_network_security_rule" "abyss_https" {
  network_security_group_name = azurerm_network_security_group.abyss.name
  resource_group_name         = azurerm_network_security_group.abyss.resource_group_name

  name                       = "HTTPS"
  priority                   = 320
  direction                  = "Inbound"
  access                     = "Allow"
  protocol                   = "Tcp"
  source_address_prefix      = "*"
  source_port_range          = "*"
  destination_address_prefix = "*"
  destination_port_range     = "443"
}

resource "azurerm_network_security_rule" "abyss_teamspeak" {
  network_security_group_name = azurerm_network_security_group.abyss.name
  resource_group_name         = azurerm_network_security_group.abyss.resource_group_name

  name                       = "TeamSpeak"
  priority                   = 340
  direction                  = "Inbound"
  access                     = "Allow"
  protocol                   = "*"
  source_address_prefix      = "*"
  source_port_range          = "*"
  destination_address_prefix = "*"
  destination_port_ranges    = ["9987", "10011", "30033"]
}

resource "azurerm_network_security_rule" "abyss_teamspeak_alt" {
  network_security_group_name = azurerm_network_security_group.abyss.name
  resource_group_name         = azurerm_network_security_group.abyss.resource_group_name

  name                       = "TeamSpeak Alt"
  priority                   = 341
  direction                  = "Inbound"
  access                     = "Allow"
  protocol                   = "*"
  source_address_prefix      = "*"
  source_port_range          = "*"
  destination_address_prefix = "*"
  destination_port_ranges    = ["9988", "10012", "30034"]
}

resource "azurerm_network_security_rule" "abyss_qbittorrent" {
  network_security_group_name = azurerm_network_security_group.abyss.name
  resource_group_name         = azurerm_network_security_group.abyss.resource_group_name

  name                       = "qBittorrent"
  priority                   = 342
  direction                  = "Inbound"
  access                     = "Allow"
  protocol                   = "*"
  source_address_prefix      = "*"
  source_port_range          = "*"
  destination_address_prefix = "*"
  destination_port_range    = "6881"
}

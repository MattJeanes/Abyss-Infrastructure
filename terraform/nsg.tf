resource "azurerm_network_security_group" "abyss" {
  name                = "abyss-nsg"
  resource_group_name = azurerm_resource_group.abyss.name
  location            = azurerm_resource_group.abyss.location
}

resource "azurerm_network_security_rule" "abyss_ssh" {
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

resource "azurerm_network_security_rule" "abyss_postgresql" {
  network_security_group_name = azurerm_network_security_group.abyss.name
  resource_group_name         = azurerm_network_security_group.abyss.resource_group_name

  name                       = "PostgreSQL"
  priority                   = 330
  direction                  = "Inbound"
  access                     = "Allow"
  protocol                   = "Tcp"
  source_address_prefix      = azurerm_public_ip.abyss_public.ip_address
  source_port_range          = "*"
  destination_address_prefix = "*"
  destination_port_range     = "5432"
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

resource "azurerm_network_security_rule" "abyss_mariadb" {
  network_security_group_name = azurerm_network_security_group.abyss.name
  resource_group_name         = azurerm_network_security_group.abyss.resource_group_name

  name                       = "MariaDB"
  priority                   = 350
  direction                  = "Inbound"
  access                     = "Allow"
  protocol                   = "Tcp"
  source_address_prefix      = azurerm_public_ip.abyss_public.ip_address
  source_port_range          = "*"
  destination_address_prefix = "*"
  destination_port_range     = "3306"
}

resource "azurerm_network_security_rule" "abyss_mongodb" {
  network_security_group_name = azurerm_network_security_group.abyss.name
  resource_group_name         = azurerm_network_security_group.abyss.resource_group_name

  name                       = "MongoDB"
  priority                   = 360
  direction                  = "Inbound"
  access                     = "Allow"
  protocol                   = "Tcp"
  source_address_prefix      = azurerm_public_ip.abyss_public.ip_address
  source_port_range          = "*"
  destination_address_prefix = "*"
  destination_port_range     = "27017"
}

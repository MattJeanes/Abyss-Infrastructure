locals {
  servers = {
    "server-1" = {
      name         = "abyss-server-1",
      dns_name     = "arma"
      vm_size      = "Standard_D2s_v3",
      os_type      = "Linux",
      disk_size_gb = 64
      source_image_reference = {
        publisher = "Canonical"
        offer     = "UbuntuServer"
        sku       = "18.04-LTS"
      }
      network_security_rules = {
        "arma" = {
          name                       = "ARMA"
          priority                   = 310
          protocol                   = "Tcp"
          source_address_prefix      = "*"
          destination_port_range     = "2302-2306"
          destination_address_prefix = "*"
        }
      }
    }
    "server-3" = {
      name         = "abyss-server-3",
      dns_name     = "gamenight"
      vm_size      = "Standard_D2s_v3",
      os_type      = "Linux",
      disk_size_gb = 30,
      source_image_reference = {
        publisher = "canonical",
        offer     = "0001-com-ubuntu-server-focal",
        sku       = "20_04-lts",
      }
      network_security_rules = {
        "gmod" = {
          name                       = "GMod"
          priority                   = 310
          protocol                   = "*"
          source_address_prefix      = "*"
          destination_port_range     = "27015"
          destination_address_prefix = "*"
        }
      }
    }
    "server-4" = {
      name         = "abyss-server-4",
      dns_name     = "spaceengineers"
      vm_size      = "Standard_D2ds_v5",
      os_type      = "Windows",
      disk_size_gb = 32,
      source_image_reference = {
        publisher = "MicrosoftWindowsServer",
        offer     = "WindowsServer",
        sku       = "2019-Datacenter",
      }
      network_security_rules = {
        "space_engineers" = {
          name                       = "SpaceEngineers"
          priority                   = 310
          protocol                   = "Udp"
          source_address_prefix      = "*"
          destination_port_range     = "27016"
          destination_address_prefix = "*"
        }
        "http" = {
          name                       = "HTTP"
          priority                   = 320
          protocol                   = "*"
          source_address_prefix      = "*"
          destination_port_ranges    = ["80", "443"]
          destination_address_prefix = "*"
        }
      }
    }
    "server-5" = {
      name         = "abyss-server-5",
      dns_name     = "satisfactory"
      vm_size      = "Standard_D4ads_v5",
      os_type      = "Linux",
      disk_size_gb = 30,
      source_image_reference = {
        publisher = "canonical",
        offer     = "0001-com-ubuntu-server-focal",
        sku       = "20_04-lts",
      }
      network_security_rules = {
        "satisfactory" = {
          name                       = "Satisfactory"
          priority                   = 310
          protocol                   = "Udp"
          source_address_prefix      = "*"
          destination_port_ranges    = ["7777", "15000", "15777"]
          destination_address_prefix = "*"
        }
        "http" = {
          name                       = "HTTP"
          priority                   = 320
          protocol                   = "*"
          source_address_prefix      = "*"
          destination_port_ranges    = ["80", "443"]
          destination_address_prefix = "*"
        }
      }
    }
    "server-6" = {
      name         = "abyss-server-6",
      dns_name     = "cs2"
      vm_size      = "Standard_D2ds_v5",
      os_type      = "Linux",
      disk_size_gb = 64,
      source_image_reference = {
        publisher = "canonical",
        offer     = "0001-com-ubuntu-server-jammy",
        sku       = "22_04-lts-gen2",
      }
      network_security_rules = {
        "cs2" = {
          name                       = "CS2"
          priority                   = 310
          protocol                   = "*"
          source_address_prefix      = "*"
          destination_port_ranges    = ["27005", "27015"]
          destination_address_prefix = "*"
        }
        "http" = {
          name                       = "HTTP"
          priority                   = 320
          protocol                   = "*"
          source_address_prefix      = "*"
          destination_port_ranges    = ["80", "443"]
          destination_address_prefix = "*"
        }
      }
    }
    "server-7" = {
      name         = "abyss-server-7",
      dns_name     = "7daystodie"
      vm_size      = "Standard_D2ds_v5",
      os_type      = "Linux",
      disk_size_gb = 32,
      source_image_reference = {
        publisher = "canonical",
        offer     = "0001-com-ubuntu-server-jammy",
        sku       = "22_04-lts-gen2",
      }
      network_security_rules = {
        "7daystodie" = {
          name                       = "7DaysToDie"
          priority                   = 310
          protocol                   = "*"
          source_address_prefix      = "*"
          destination_port_range     = "26900-26902"
          destination_address_prefix = "*"
        }
        "http" = {
          name                       = "HTTP"
          priority                   = 320
          protocol                   = "*"
          source_address_prefix      = "*"
          destination_port_ranges    = ["80", "443"]
          destination_address_prefix = "*"
        }
      }
    }
  }
  nsg_rules = flatten([
    for server_key, server in local.servers : [
      for rule_key, rule in local.servers[server_key].network_security_rules : {
        server_key = server_key
        rule_key   = rule_key
        rule       = local.servers[server_key].network_security_rules[rule_key]
      }
    ]
  ])
}

resource "azurerm_public_ip" "servers" {
  for_each = local.servers

  name                = "${each.value.name}-ip"
  location            = azurerm_resource_group.abyss.location
  resource_group_name = azurerm_resource_group.abyss.name
  sku                 = "Basic"
  allocation_method   = "Dynamic"
}

resource "azurerm_network_security_group" "servers" {
  for_each = local.servers

  name                = "${each.value.name}-nsg"
  location            = azurerm_resource_group.abyss.location
  resource_group_name = azurerm_resource_group.abyss.name
}

resource "azurerm_network_security_rule" "servers_remote_access" {
  for_each = local.servers

  network_security_group_name = azurerm_network_security_group.servers[each.key].name
  resource_group_name         = azurerm_resource_group.abyss.name

  name                       = each.value.os_type == "Windows" ? "RDP" : "SSH"
  priority                   = 300
  direction                  = "Inbound"
  access                     = "Allow"
  protocol                   = "Tcp"
  source_port_range          = "*"
  destination_port_range     = each.value.os_type == "Windows" ? "3389" : "22"
  source_address_prefix      = var.home_ip
  destination_address_prefix = "*"
}

resource "azurerm_network_security_rule" "servers_rules" {
  for_each = { for rule in local.nsg_rules : "${rule.server_key}_${rule.rule_key}" => rule }

  network_security_group_name = azurerm_network_security_group.servers[each.value.server_key].name
  resource_group_name         = azurerm_resource_group.abyss.name

  name                         = each.value.rule.name
  priority                     = each.value.rule.priority
  direction                    = "Inbound"
  access                       = "Allow"
  protocol                     = each.value.rule.protocol
  source_port_range            = "*"
  source_address_prefix        = try(each.value.rule.source_address_prefix, null)
  source_address_prefixes      = try(each.value.rule.source_address_prefixes, null)
  destination_port_range       = try(each.value.rule.destination_port_range, null)
  destination_port_ranges      = try(each.value.rule.destination_port_ranges, null)
  destination_address_prefix   = try(each.value.rule.destination_address_prefix, null)
  destination_address_prefixes = try(each.value.rule.destination_address_prefixes, null)
}

resource "azurerm_network_interface" "servers" {
  for_each = local.servers

  name                = "${each.value.name}-nic"
  location            = azurerm_resource_group.abyss.location
  resource_group_name = azurerm_resource_group.abyss.name

  enable_accelerated_networking = true

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.abyss_default.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.servers[each.key].id
  }
}

resource "azurerm_network_interface_security_group_association" "servers" {
  for_each = local.servers

  network_interface_id      = azurerm_network_interface.servers[each.key].id
  network_security_group_id = azurerm_network_security_group.servers[each.key].id
}

resource "azurerm_linux_virtual_machine" "servers" {
  for_each = { for key, val in local.servers : key => val if val.os_type == "Linux" }

  lifecycle {
    prevent_destroy = true
  }

  name                = each.value.name
  location            = azurerm_resource_group.abyss.location
  resource_group_name = azurerm_resource_group.abyss.name

  size = each.value.vm_size

  network_interface_ids = [
    azurerm_network_interface.servers[each.key].id
  ]

  disable_password_authentication = true

  os_disk {
    name                 = "${each.value.name}-osdisk"
    disk_size_gb         = each.value.disk_size_gb
    storage_account_type = "StandardSSD_LRS"
    caching              = "ReadWrite"
  }

  admin_username = "matt"

  admin_ssh_key {
    username   = "matt"
    public_key = var.ssh_public_key
  }

  boot_diagnostics {
    storage_account_uri = azurerm_storage_account.abyss.primary_blob_endpoint
  }

  source_image_reference {
    publisher = each.value.source_image_reference.publisher
    offer     = each.value.source_image_reference.offer
    sku       = each.value.source_image_reference.sku
    version   = "latest"
  }
}

resource "azurerm_windows_virtual_machine" "servers" {
  for_each = { for key, val in local.servers : key => val if val.os_type == "Windows" }

  lifecycle {
    prevent_destroy = true
  }

  name                = each.value.name
  location            = azurerm_resource_group.abyss.location
  resource_group_name = azurerm_resource_group.abyss.name

  size = each.value.vm_size

  network_interface_ids = [
    azurerm_network_interface.servers[each.key].id
  ]

  os_disk {
    disk_size_gb         = each.value.disk_size_gb
    storage_account_type = "StandardSSD_LRS"
    caching              = "ReadWrite"
  }

  admin_username = "abyss"
  admin_password = var.windows_server_password

  boot_diagnostics {
    storage_account_uri = azurerm_storage_account.abyss.primary_blob_endpoint
  }

  source_image_reference {
    publisher = each.value.source_image_reference.publisher
    offer     = each.value.source_image_reference.offer
    sku       = each.value.source_image_reference.sku
    version   = "latest"
  }
}

resource "cloudflare_record" "servers" {
  for_each = local.servers

  lifecycle {
    ignore_changes = [
      value
    ]
  }

  zone_id = var.cloudflare_zone_id
  name    = each.key
  type    = "A"
  value   = coalesce(azurerm_public_ip.servers[each.key].ip_address, "192.0.2.0") # IPv4 reserved test address
  ttl     = 60
  proxied = false
}

resource "cloudflare_record" "servers_cname" {
  for_each = { for key, val in local.servers : key => val if val.dns_name != null }

  zone_id = var.cloudflare_zone_id
  name    = each.value.dns_name
  type    = "CNAME"
  value   = cloudflare_record.servers[each.key].hostname
  ttl     = 1
  proxied = false
}

resource "azurerm_kubernetes_cluster" "abyss" {
  name                = "abyss"
  resource_group_name = azurerm_resource_group.abyss.name
  location            = azurerm_resource_group.abyss.location
  dns_prefix          = "abyss-dns"
  kubernetes_version  = var.kubernetes_version

  identity {
    type = "SystemAssigned"
  }

  linux_profile {
    admin_username = "ubuntu"

    ssh_key {
      key_data = var.ssh_public_key
    }
  }

  default_node_pool {
    name                 = "agentpool"
    enable_auto_scaling  = true
    node_count           = 1
    min_count            = 1
    max_count            = 5
    vm_size              = "Standard_B2s"
    vnet_subnet_id       = azurerm_subnet.abyss_aks.id
    orchestrator_version = var.kubernetes_version
  }

  aci_connector_linux {
    subnet_name = "aci"
  }

  network_profile {
    network_plugin     = "azure"
    load_balancer_sku  = "basic"
    dns_service_ip     = "10.250.0.10"
    docker_bridge_cidr = "172.17.0.1/16"
    service_cidr       = "10.250.0.0/16"
    load_balancer_profile {
      outbound_ip_address_ids = [azurerm_public_ip.abyss_public.id]
    }
  }

  lifecycle {
    ignore_changes = [
      default_node_pool[0].node_count
    ]
  }
}

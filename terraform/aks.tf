resource "azurerm_kubernetes_cluster" "abyss" {
  name                = "abyss"
  resource_group_name = azurerm_resource_group.abyss.name
  location            = azurerm_resource_group.abyss.location
  dns_prefix          = "abyss"
  kubernetes_version  = var.kubernetes_version

  lifecycle {
    ignore_changes = [
      default_node_pool[0].node_count
    ]
  }

  identity {
    type = "SystemAssigned"
  }

  linux_profile {
    admin_username = "ubuntu"

    ssh_key {
      key_data = var.ssh_public_key
    }
  }

  auto_scaler_profile {
    scale_down_utilization_threshold = "0.2"
  }

  default_node_pool {
    name                 = "agentpool"
    enable_auto_scaling  = false
    node_count           = 2
    max_pods             = 50
    vm_size              = "Standard_D2as_v5"
    os_disk_size_gb      = 64
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
    service_cidr       = "10.250.0.0/16"
  }
}

resource "azurerm_role_assignment" "aks_abyss_networkcontributor" {
  scope                = azurerm_resource_group.abyss.id
  role_definition_name = "Network Contributor"
  principal_id         = azurerm_kubernetes_cluster.abyss.identity[0].principal_id
}


resource "azurerm_role_assignment" "aks_abyss_diskaccess" {
  scope                = azurerm_resource_group.abyss.id
  role_definition_name = azurerm_role_definition.diskaccess.name
  principal_id         = azurerm_kubernetes_cluster.abyss.identity[0].principal_id
}

data "azurerm_user_assigned_identity" "aks_abyss_agentpool" {
  name                = "${azurerm_kubernetes_cluster.abyss.name}-agentpool"
  resource_group_name = azurerm_kubernetes_cluster.abyss.node_resource_group
  depends_on = [
    azurerm_kubernetes_cluster.abyss,
  ]
}

resource "azurerm_role_assignment" "aks_abyss_agentpool_diskaccess" {
  scope                = azurerm_resource_group.abyss.id
  role_definition_name = azurerm_role_definition.diskaccess.name
  principal_id         = data.azurerm_user_assigned_identity.aks_abyss_agentpool.principal_id
}

resource "azurerm_role_assignment" "aks_abyss_aci_network_contributor_subnet" {
  scope                = azurerm_subnet.abyss_aci.id
  role_definition_name = "Network Contributor"
  principal_id         = azurerm_kubernetes_cluster.abyss.aci_connector_linux[0].connector_identity[0].object_id
}

resource "azurerm_subnet_network_security_group_association" "aks_abyss" {
  subnet_id                 = azurerm_subnet.abyss_aks.id
  network_security_group_id = azurerm_network_security_group.abyss.id
}

resource "azurerm_subnet_network_security_group_association" "aks_abyss_aci" {
  subnet_id                 = azurerm_subnet.abyss_aci.id
  network_security_group_id = azurerm_network_security_group.abyss.id
}

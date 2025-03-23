resource "azurerm_kubernetes_cluster" "abyss" {
  name                      = "abyss"
  resource_group_name       = azurerm_resource_group.abyss.name
  location                  = azurerm_resource_group.abyss.location
  dns_prefix                = "abyss"
  automatic_upgrade_channel = "rapid"

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
    auto_scaling_enabled = false
    node_count           = 1
    max_pods             = 110
    vm_size              = "Standard_E2as_v5"
    os_sku               = "AzureLinux"
    os_disk_size_gb      = 64
    vnet_subnet_id       = azurerm_subnet.abyss_aks.id
  }

  aci_connector_linux {
    subnet_name = "aci"
  }

  network_profile {
    network_plugin    = "azure"
    load_balancer_sku = "basic"
    dns_service_ip    = "10.250.0.10"
    service_cidr      = "10.250.0.0/16"
  }

  maintenance_window_auto_upgrade {
    day_of_week = "Monday"
    frequency   = "Weekly"
    interval    = 1
    duration    = 4
    start_date  = "2025-02-11T00:00:00Z"
    start_time  = "10:00"
    utc_offset  = "+00:00"
  }

  maintenance_window_node_os {
    day_of_week  = "Tuesday"
    frequency    = "Weekly"
    interval     = 1
    duration     = 4
    start_date   = "2025-03-18T00:00:00Z"
    start_time   = "10:00"
    utc_offset   = "+00:00"
  }
}

resource "azurerm_role_assignment" "aks_abyss_networkcontributor" {
  scope                = azurerm_resource_group.abyss.id
  role_definition_name = "Network Contributor"
  principal_id         = azurerm_kubernetes_cluster.abyss.identity[0].principal_id
}


resource "azurerm_role_assignment" "aks_abyss_diskaccess" {
  scope                = azurerm_resource_group.abyss.id
  role_definition_name = azurerm_role_definition.diskaccess_old.name
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
  role_definition_name = azurerm_role_definition.diskaccess_old.name
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
